function NeuralNetTester(net, testInput, testTarget)
% Test the Network
y = net(testInput');

e = gsubtract(testTarget',y);
performance = perform(net,testTarget',y);
tind = vec2ind(testTarget');
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind)

figure, plotconfusion(testTarget',y)