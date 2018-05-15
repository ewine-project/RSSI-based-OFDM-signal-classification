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
    dir('../dataset/TCD/lte-*.bin');dir('../dataset/TCD/wifi-*.bin');
    ];

strsplitter = '_';
% test files
% testfiles = [dir('../dublin/lte-*.bin');dir('../dublin/wifi-*.bin');];
output=[];
targets=[];
count_files = 0;
used_files = {};
%% 
samples = 256; % RSSI (test 500 2500 5000)
IQ_per_RSSI = 16; % (16 * 256 = 4096)
%%
for fileindex = 1 : length(trainfiles)
    % load file
    disp(trainfiles(fileindex).name);
    fid2=fopen(trainfiles(fileindex).name);

    if(fid2 == -1)
        disp('Failed opening file');
        continue;
    end
    
    if(strfind(trainfiles(fileindex).name,"-"))
        strsplitter='-';
    end
    
    splitfname = strsplit(trainfiles(fileindex).name,strsplitter);
    type = splitfname(1);
    if type == "wifi" 
        type="wf";
    end

    %% 
    %Specify the type of I and Q samples, here we used as 'short' 
    raw2=fread(fid2,inf,'float');
    fclose(fid2);
    raw21=raw2';    
    
    % Seperating the I and Q channels
    raw3 = reshape(raw21,2,length(raw21)/2) ; % make two rows with n/2 columns
    q_sample = raw3(2,:) ; % q sample is in second row (IQ)
    i_sample = raw3(1,:) ; % i sample is in first row  (IQ)
    complex_sample = i_sample + 1i.*q_sample ; % make complex number 1i = imaginary unit array, multiply each q sample.
    
    % read RSSI
    if(strsplitter == '-')    
        b = resample(complex_sample, 1,10); % downsample
        rssiarr = rssi_array_t(b,IQ_per_RSSI,0); % obtain the rssi array
    else
        rssiarr = rssi_array_t(complex_sample,IQ_per_RSSI, 0);
    end
   
    disp(length(rssiarr));
    arrlength = floor(length(rssiarr)/samples); % RSSI
    
    % chop last part off
    chop = length(rssiarr) - samples * arrlength;
    disp(chop)
    rssiarr = rssiarr(:,1:end-chop);
    
    raw3 = reshape(rssiarr, samples, arrlength); % RSSI
    
    %output = cat(3,output ,raw3); % IQ
    output = cat(2,output ,raw3); % RSSI
    if(type == "wf")
        C    = zeros(3, arrlength);
        C(1,:) = 1;
        C(2,:) = 0;
        C(3,:) = 0;
    elseif(type == "lte")
        C    = zeros(3, arrlength);
        C(1,:) = 0;
        C(2,:) = 1;
        C(3,:) = 0;
    elseif(type == "dvbt")
        C    = zeros(3, arrlength);
        C(1,:) = 0;
        C(2,:) = 0;
        C(3,:) = 1;
    end
       
    targets = cat(2,targets,C);
  
    count_files = count_files + 1;
    used_files = [used_files, trainfiles(fileindex).name];
end


trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

tic;
hiddenLayerSize = [  150 50 ] ; % 15
net = patternnet(hiddenLayerSize, trainFcn);

net.input.processFcns = {'removeconstantrows','mapstd','processpca'};

net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 0/100;

net.performFcn = 'crossentropy';  % Cross-Entropy

net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotconfusion', 'plotroc'};

sizsje = size(output);
shapedx = reshape(output,samples, sizsje(2) );
[net,tr] = train(net, shapedx,targets);

toc;
