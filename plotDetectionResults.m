clear;
close all;
clc;

%% User configuration

%snrVec = -10:2:10;               % SNR values corresponding to the files
snrVec = [-4 -2 0 2]; %-6:2:4; 
maxPfa = 1e-5;                   % Maximum allowed false-alarm probability

% Example file naming:
% results_SNR_m10.mat
% results_SNR_m08.mat
% ...

K = 15;
approach = "HypTest"; %  PeakDet
addpath Results
filePattern = "Results/PSSsyncNTN_"+approach+"_SCS_30_CFO_100_seqlen_240_SNR%.2f_chanLMS_K"+K+"_S5.mat";
%filePattern = "Results/PSSsyncNTN_"+approach+"_SCS_30_CFO_100_seqlen_240_SNR%.2f.mat";

techniqueNames = {
    'Technique 1'
    'Technique 2'
    'Technique 3'
    'Technique 4'
};



%% Allocate outputs

numSNR = numel(snrVec);
numTechniques = numel(techniqueNames);

PdSelected = nan(numSNR, numTechniques);
PfaSelected = nan(numSNR, numTechniques);
selectedThresholdIndex = nan(numSNR, numTechniques);

% Optional diagnostic quantities
thresholdValueSelected = nan(numSNR, numTechniques);
numSlots = nan(numSNR, numTechniques);

%% Loop over SNR files

for iSNR = 1:numSNR

    snrCurrent = snrVec(iSNR);

    % Modify this line if the SNR-to-filename mapping is different.
    fileName = sprintf(filePattern, round(snrCurrent));

    if ~isfile(fileName)
        warning('File not found: %s. Skipping SNR = %.2f dB.', ...
            fileName, snrCurrent);
        continue;
    end

    loadedData = load(fileName);

    if ~isfield(loadedData, 'metricsTech')
        warning('Variable metricsTech not found in file: %s.', fileName);
        continue;
    end

    metricsTech = loadedData.metricsTech;
    Nslot = loadedData.L;
    synch_mode = loadedData.synch_mode;

    % Number of false-alarm opportunities per slot.
    %
    % Set to 1 if false_count is:
    %   - a binary indication that at least one false detection occurred, or
    %   - the total false alarm metric is intended per slot.
    %
    % Set to the actual number of non-preamble locations tested per slot if
    % false_count counts false detections over several correlation positions.
    if synch_mode == 1
        numFalseAlarmOpportunitiesPerSlot = 3089;
    else
        numFalseAlarmOpportunitiesPerSlot = 1;
    end

    if numel(metricsTech) ~= numTechniques
        error(['File %s contains %d techniques, while %d technique ', ...
               'names have been defined.'], ...
               fileName, numel(metricsTech), numTechniques);
    end

    %% Process each technique

    for iTech = 1:numTechniques

        metricsCurrent = metricsTech{iTech};

        if ~isstruct(metricsCurrent)
            error('metricsTech{%d} must contain a structure array.', iTech);
        end

        [Pd(iSNR, iTech,:), Pfa(iSNR, iTech,:), Pmiss(iSNR, iTech,:)] = calculateDetectionProbabilities( ...
            metricsCurrent, numFalseAlarmOpportunitiesPerSlot, Nslot);

        numSlots(iSNR, iTech) = numel(metricsCurrent);

        % Thresholds satisfying the false-alarm constraint
        feasibleIndices = find(Pfa(iSNR, iTech, :) <= maxPfa);

        if isempty(feasibleIndices)
            warning(['No threshold satisfies P_FA <= %.3g for SNR = ', ...
                     '%.2f dB, technique %d.'], ...
                     maxPfa, snrCurrent, iTech);
            continue;
        end

        % Among feasible thresholds, choose the one with maximum Pd
        [maxPd, idx] = max(Pd(feasibleIndices));

        candidateIndices = feasibleIndices(idx); %feasibleIndices(Pd(feasibleIndices) == maxPd);

        % Tie-break rule:
        % if multiple thresholds give the same Pd, choose the one with
        % the lowest Pfa.
        [~, localIndex] = min(Pfa(iSNR, iTech, candidateIndices));
        bestThresholdIndex = candidateIndices(localIndex);

        PdSelected(iSNR, iTech) = Pd(iSNR, iTech, bestThresholdIndex);
        PfaSelected(iSNR, iTech) = Pfa(iSNR, iTech, bestThresholdIndex);
        selectedThresholdIndex(iSNR, iTech) = bestThresholdIndex;

        % If threshold values are not explicitly stored, the threshold
        % index is used as the threshold identifier.
        thresholdValueSelected(iSNR, iTech) = bestThresholdIndex;

        % Optional consistency check
        detectionConsistencyError = ...
            abs(Pd(iSNR, iTech, bestThresholdIndex) + Pmiss(iSNR, iTech, bestThresholdIndex) - 1);

        % if detectionConsistencyError > 1e-10
        %     warning(['P_D + P_miss is not equal to 1 for SNR = %.2f dB, ', ...
        %              'technique %d, threshold index %d. Error = %.3g.'], ...
        %              snrCurrent, iTech, bestThresholdIndex, ...
        %              detectionConsistencyError);
        % end
    end
end

%% Plot probability of correct detection versus SNR

figure;
colors = lines(numTechniques);
markers = {'o', 's'};
for iTech = 1:2 %numTechniques
    semilogy(snrVec, 1-PdSelected(:, iTech), '-o', 'Color', colors(iTech, :), 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', techniqueNames{iTech}); hold on;
    %plot(snrVec, PdSelected(:, iTech), '-o', 'Color', colors(iTech, :), 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', techniqueNames{iTech});
end
hold off;
grid on;
box on;
xlabel('SNR [dB]');
ylabel('Probability of missed detection, P_D');
title(sprintf('Correct detection probability with P_{FA} \\leq %.3g', maxPfa));
%ylim([0 1]);
legend('Location', 'best');
ylim([1e-4 1])
xlim([min(snrVec) max(snrVec)])

%% ROC curve for Pmd vs Pfa

%{
figure;
for iSNR = 1:numSNR
    for iTech = 1:2 %numTechniques
        PdTemp = squeeze(Pd(iSNR, iTech, :)); PfaTemp = squeeze(Pfa(iSNR, iTech, :));
        loglog(PfaTemp, 1-PdTemp, '-', 'Marker', markers{iTech}, 'Color', colors(iTech, :), 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', techniqueNames{iTech}); hold on;
    end
end
grid on;
box on;

xlabel('P_{FalseAlarm}');
ylabel('P_{MissedDetection}');
title('False-alarm probability at the selected threshold');
legend('Location', 'best');
xlim([1e-8 1e0])
ylim([1e-6 1e0])
%}

%% Optional plot of the actual selected Pfa

%%{
figure;
for iTech = 1:2 %numTechniques
    semilogy(snrVec, PfaSelected(:, iTech), '-o', 'Color', colors(iTech, :), 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', techniqueNames{iTech}); hold on;
end

grid on;
box on;

yline(maxPfa, '--k', ...
    sprintf('Maximum P_{FA} = %.3g', maxPfa), ...
    'LabelHorizontalAlignment', 'left');

xlabel('SNR [dB]');
ylabel('Selected false-alarm probability, P_{FA}');
title('False-alarm probability at the selected threshold');
legend('Location', 'best');
xlim([min(snrVec) max(snrVec)])
%} 

%% Optional display of the selected operating points

for iTech = 1:numTechniques

    resultsTable = table( ...
        snrVec(:), ...
        PdSelected(:, iTech), ...
        PfaSelected(:, iTech), ...
        selectedThresholdIndex(:, iTech), ...
        'VariableNames', { ...
            'SNR_dB', ...
            'Pd', ...
            'Pfa', ...
            'ThresholdIndex'});

    fprintf('\n%s\n', techniqueNames{iTech});
    disp(resultsTable);
end