function featureVectors = read_files_features(files, msps, strsplitter,  featureAmount, is_10msps, RSSI_per_histogram, addNoise)

featureVectors = strings([0,featureAmount]);

%%
% header
hInt = 20; % histogram intervals

for i = 1 : hInt
    featureVectors(1,i)= strcat("n ",int2str(i)); 
end
    featureVectors(1,hInt+1)="min";
    featureVectors(1,hInt+2)="max";
    featureVectors(1,hInt+3)="peaks";
    featureVectors(1,hInt+4)="widthhpeak";
    featureVectors(1,hInt+5)="stdstat";
    featureVectors(1,hInt+6)="stddata";
    featureVectors(1,hInt+7)="avgdata";
    featureVectors(1,hInt+8)="mediandata";
    featureVectors(1,featureAmount)="type";
%%

tic;
for fileindex = 1 : length(files)
    % load file
    disp(files(fileindex).name);
    fid2=fopen(files(fileindex).name);

    splitfname = strsplit(files(fileindex).name,strsplitter);
    type = splitfname(1);
    if type == "wifi" 
        type="wf";
    end
    
    %% 
    %Specify the type of I and Q samples, here we used as 'short' 
    raw2=fread(fid2,inf,'float');
    fclose(fid2);
    raw21=raw2';

    %% 
    % Seperating the I and Q channels
    raw3 = reshape(raw21,2,length(raw21)/2) ; % make two rows with n/2 columns
    q_sample = raw3(2,:) ; % q sample is in second row (IQ)
    i_sample = raw3(1,:) ; % i sample is in first row  (IQ)
    complex_sample = i_sample + 1i.*q_sample ; % make complex number 1i = imaginary unit array, multiply each q sample.

    %%
    % Get RSSI array
    samples = 256; % RSSI (test 500 2500 5000)
    IQ_per_RSSI = 16; % (16 * 256 = 4096)
     
    if(is_10msps)       
        b = resample(complex_sample, 1,10);
        rssiarr = rssi_array_t(b,IQ_per_RSSI,0);
    else
        rssiarr = rssi_array_t(complex_sample,IQ_per_RSSI*msps, 0); 
    end
    
    %%
    % Init output feature vectors
    histograms = floor(length(rssiarr) / RSSI_per_histogram); 
    output = strings([11,featureAmount]);
        
    % each histogram adds a feature vector
    for counter = 1 : histograms
        % calculate interval boundaries
        from = floor((counter-1)*length(rssiarr)/histograms+1);
        till = floor((counter)*length(rssiarr)/histograms);
        
        % get min-max normalized histogram (contains 20 features, according to position of peaks in histogram)
        [stat,interval, cdfstat, minrssi, maxrssi] = hist_normalization(rssiarr(1,from:till),20,1);

        % fill in feature vector
        output(counter,1:20) = string(stat);
        output(counter,21) = minrssi; % min. boundary
        output(counter,22) = maxrssi; % max. boundary
        [peaks,indices,w,p] = findpeaks(stat); 
        output(counter,23) = length(indices); % amount of peaks
        % highest peak width
        [Max,MIndex] = max(peaks);
        output(counter,24) = w(MIndex);
        
        % stdev & mean & meadian
        output(counter, 25) = std(stat);
        output(counter, 26) = std(rssiarr(1,from:till));
        output(counter, 27) = mean(rssiarr(1,from:till));
        output(counter, 28) = median(rssiarr(1,from:till));
        
        % output(counter,24) = w(1);
        output(counter,featureAmount)=type; % class label of featurevector
    end
    
    % save feature vector
    featureVectors = [featureVectors ; output];       
    fprintf("Progress: %.2d\n",round(fileindex/length(files)*100)); % report progress in percentage
    %%
end

toc