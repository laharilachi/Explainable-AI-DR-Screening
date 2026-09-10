%% Load Data
[imdsTrain, imdsVal] = loadAPTOSData();

%% Augmentation
augmenter = imageDataAugmenter( ...
    'RandRotation', [-20 20], ...
    'RandXReflection', true, ...
    'RandYReflection', true);

auimdsTrain = augmentedImageDatastore([224 224], imdsTrain, 'DataAugmentation', augmenter);
auimdsVal   = augmentedImageDatastore([224 224], imdsVal);

%% Load Network
net = efficientnetb0;
numClasses = numel(categories(imdsTrain.Labels));
lgraph = layerGraph(net);

%% Replace Final Layers
% Remove last 3 layers
lgraph = removeLayers(lgraph, { ...
    'efficientnet-b0|model|head|dense|MatMul', ...
    'Softmax', ...
    'classification'});

% New layers
newLayers = [
    fullyConnectedLayer(numClasses, 'Name', 'fc_new', ...
        'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10)
    softmaxLayer('Name', 'softmax_new')
    classificationLayer('Name', 'classoutput')
];

lgraph = addLayers(lgraph, newLayers);

% Only connect the first new layer to the network
lgraph = connectLayers(lgraph, ...
    'efficientnet-b0|model|head|global_average_pooling2d|GlobAvgPool', 'fc_new');

%% Training Options
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-4, ...
    'MaxEpochs', 6, ...
    'MiniBatchSize', 16, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', auimdsVal, ...
    'ValidationFrequency', 50, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

%% Train
trainedNet = trainNetwork(auimdsTrain, lgraph, options);

%% Save
save(fullfile("..\..\Models", "efficientnet_dr_matlab.mat"), "trainedNet");
disp("Model saved successfully!");