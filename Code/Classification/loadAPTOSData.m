function [imdsTrain, imdsVal] = loadAPTOSData()

    % ========== PATH ==========
    dataDir = "C:\Users\Lahari\SIH26038-Explainable-AI-DR-Screenings\Datasets\APTOS2019\colored_images";
    % ==========================

    % Load all images with labels from folder names
    imds = imageDatastore(dataDir, ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');

    % Display class distribution
    disp("Class distribution:");
    countEachLabel(imds)

    % Split into Train (80%) and Validation (20%)
    [imdsTrain, imdsVal] = splitEachLabel(imds, 0.8, 'randomized');

    % Apply preprocessing
    imdsTrain.ReadFcn = @(f) preprocessImage(imread(f));
    imdsVal.ReadFcn   = @(f) preprocessImage(imread(f));

    disp("Train images: " + numel(imdsTrain.Files));
    disp("Val images  : " + numel(imdsVal.Files));
end