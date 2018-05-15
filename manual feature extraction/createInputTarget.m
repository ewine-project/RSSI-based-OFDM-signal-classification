function [trainInput, trainTarget] = createInputTarget(features)
% strip header
% strip last column
trainInput = str2double(features(2:end,:));
trainInput = trainInput(:,1:end-1);

% create training target
classes=3;
trainTarget = zeros(length(trainInput),classes);
for i = 1:length(trainTarget)
    if(features(i+1,end) == 'wf')
        trainTarget(i,1) = 1;
    elseif(features(i+1,end) == 'lte')
        trainTarget(i,2) = 1;
    elseif(features(i+1,end) == 'dvbt')
        trainTarget(i,3) = 1;
    end
end