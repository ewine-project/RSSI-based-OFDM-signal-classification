close all;
clear all;
clc;

%% init files
% train files
trainfiles = [dir('../dataset/IMEC/gentbrugge/wf_*.bin');dir('../dataset/IMEC/gentbrugge/dvbt_*.bin');dir('../dataset/IMEC/gentbrugge/lte_*.bin');
    dir('../dataset/IMEC/igent/wf_*.bin');dir('../dataset/IMEC/igent/dvbt_*.bin');dir('../dataset/IMEC/igent/lte_*.bin');
    dir('../dataset/IMEC/merelbeke/wf_*.bin');dir('../dataset/IMEC/merelbeke/dvbt_*.bin');dir('../dataset/IMEC/merelbeke/lte_*.bin');
    dir('../dataset/IMEC/rabot/wf_*.bin');dir('../dataset/IMEC/rabot/dvbt_*.bin');dir('../dataset/IMEC/rabot/lte_*.bin');
    dir('../dataset/IMEC/reep/wf_*.bin');dir('../dataset/IMEC/reep/dvbt_*.bin');dir('../dataset/IMEC/reep/lte_*.bin');
    dir('../dataset/IMEC/uz/wf_*.bin');dir('../dataset/IMEC/uz/dvbt_*.bin');dir('../dataset/IMEC/uz/lte_*.bin');
    ];

% test files
testfiles = [dir('../dataset/TCD/lte-*.bin');dir('../dataset/TCD/wifi-*.bin');];

%%
% calculate features
featureAmount = 20 + 4 + 1 + 2 + 2; % 20 peak measurements, 1 min, 1 max, amount of peaks, width first peak 1 label, stdev histo & data, mean & median data
RSSI_per_histogram = 256;

trainFeatureVectors = read_files_features(trainfiles,1,'_',featureAmount, false, RSSI_per_histogram); % files, msps, filedelimiter, featureAmount, is_10msps, RSSI_per_histogram, [addNoise]
testFeatureVectors = read_files_features(testfiles,10,'-',featureAmount, true, RSSI_per_histogram); % files, msps, filedelimiter, featureAmount, is_10msps, RSSI_per_histogram, [addNoise]
totalFeatureVectors = cat(1,trainFeatureVectors, testFeatureVectors);

%%
% write results to excel
xlswrite("traindata.xlsx", trainFeatureVectors);
xlswrite("testdata.xlsx", testFeatureVectors);
xlswrite("totaldata.xlsx", totalFeatureVectors); % remove extra header line in file!
disp("Wrote excels");               

%%
% feature selection
positions = [2,3,4,5,9,10,11,12,13,20,21,22,24,26,27,29];
trainFeatureVectors = featureSelector(positions, trainFeatureVectors);
testFeatureVectors = featureSelector(positions, testFeatureVectors);
totalFeatureVectors = featureSelector(positions, totalFeatureVectors);
%%

% start training nn
disp("Start training net ...");
tic;
[trainInput, trainTarget] =  createInputTarget(trainFeatureVectors); % transform featurevector to Matlab NN readable format (strip header and convert labels to binary notation)
%[trainInput, trainTarget] = createInputTarget(totalFeatureVectors); % full training

net = NeuralNetTrainer(trainInput, trainTarget); % train network
toc


% start testing nn
disp("Start testing net ...");
tic;
[testInput, testTarget] =  createInputTarget(testFeatureVectors, dodvbt); % transform featurevector to Matlab NN readable format (strip header and convert labels to binary notation)
 NeuralNetTester(net, testInput, testTarget);
toc