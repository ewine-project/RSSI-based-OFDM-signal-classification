function [net]=NeuralNetTrainer(trainInput, trainTarget)

x = trainInput';
t = trainTarget';

% Training Function
trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenLayerSize = [25 10] ; 
net = patternnet(hiddenLayerSize, trainFcn);

% processing parameters
net.input.processFcns = {'removeconstantrows','mapminmax','processpca'};
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 60/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 20/100;

% Performance Function
net.performFcn = 'crossentropy';  % Cross-Entropy

% Plot Functions
net.plotFcns = {'plotperform','plotconfusion'};    
    
% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind)

% Recalculate Training, Validation and Test Performance
trainTargets = t .* tr.trainMask{1};
valTargets = t .* tr.valMask{1};
testTargets = t .* tr.testMask{1};
trainPerformance = perform(net,trainTargets,y);
valPerformance = perform(net,valTargets,y);
testPerformance = perform(net,testTargets,y);
