function [Pd, Pfa, Pmiss] = calculateDetectionProbabilities( ...
    metricsCurrent, numFalseAlarmOpportunitiesPerSlot, Nslot)

% metricsCurrent is an M x 1 structure array with fields:
%   correct_count : 1 x Nthreshold vector
%   false_count   : 1 x Nthreshold vector
%   missed_count  : 1 x Nthreshold vector

    if ~isstruct(metricsCurrent)
        error('metricsCurrent must be a structure array.');
    end

    requiredFields = {'correct_count_SSB', 'false_count_SSB', 'missed_count_SSB'};

    if ~all(isfield(metricsCurrent, requiredFields))
        error(['metricsCurrent must contain the fields correct_count, ', ...
               'false_count, and missed_count.']);
    end

    numSlots = Nslot; %numel(metricsCurrent);

    if numSlots == 0
        error('metricsCurrent does not contain any slots.');
    end

    if numFalseAlarmOpportunitiesPerSlot <= 0
        error('numFalseAlarmOpportunitiesPerSlot must be positive.');
    end

    %% Convert structure fields into M x Nthreshold matrices

    correctMatrix = vertcat(metricsCurrent.correct_count_SSB);
    falseMatrix   = vertcat(metricsCurrent.false_count_SSB);
    missedMatrix  = vertcat(metricsCurrent.missed_count_SSB);

    %% Check dimensions

    if ~isequal(size(correctMatrix), ...
                size(falseMatrix), ...
                size(missedMatrix))

        error(['Correct, false, and missed count vectors must have ', ...
               'the same dimensions.']);
    end

    %% Empirical probabilities

    Pd = sum(correctMatrix,1) ./ numSlots;

    Pfa = sum(falseMatrix,1) ./ (numSlots * numFalseAlarmOpportunitiesPerSlot);

    Pmiss = 1 - Pd;

    %Pfa = sum(falseMatrix, 1) ./ ...
    %    (numSlots * numFalseAlarmOpportunitiesPerSlot);

    %% Remaining code stays unchanged
end


function outputMatrix = cellVectorsToMatrix(inputCells)
% Convert an M x 1 cell array of equal-length vectors into an
% M x Nthreshold numeric matrix.

    if isempty(inputCells)
        error('The input cell array is empty.');
    end

    vectorLengths = cellfun(@numel, inputCells);

    if any(vectorLengths ~= vectorLengths(1))
        error('All threshold vectors must have the same length.');
    end

    outputMatrix = cell2mat(cellfun( ...
        @(x) reshape(x, 1, []), ...
        inputCells, ...
        'UniformOutput', false));
end