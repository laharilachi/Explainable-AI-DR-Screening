function processImage()
% File-based processing for Streamlit

    inputFolder  = fullfile(fileparts(mfilename('fullpath')), '..', 'temp_input');
    outputFolder = fullfile(fileparts(mfilename('fullpath')), '..', 'temp_output');

    % Clear previous output
    if exist(outputFolder, 'dir')
        delete(fullfile(outputFolder, '*.*'));
    else
        mkdir(outputFolder);
    end

    % Find image in input folder
    imgFiles = dir(fullfile(inputFolder, '*.png'));
    if isempty(imgFiles)
        imgFiles = dir(fullfile(inputFolder, '*.jpg'));
    end
    if isempty(imgFiles)
        imgFiles = dir(fullfile(inputFolder, '*.jpeg'));
    end

    if isempty(imgFiles)
        error('No image found in temp_input folder');
    end

    imgPath = fullfile(inputFolder, imgFiles(1).name);
    img = imread(imgPath);

    % Load model
    modelPath = fullfile(fileparts(mfilename('fullpath')), '..', 'Models', 'efficientnet_dr_matlab.mat');
    load(modelPath);   % loads trainedNet

    % Add paths
    addpath(fullfile(fileparts(mfilename('fullpath')), 'QualityAssessment'));
    addpath(fullfile(fileparts(mfilename('fullpath')), 'Classification'));

    % 1. Quality + Enhance
    [enhanced, status, feedback] = qualityAndEnhance(img);

    % 2. Classification
    [label, scores] = classify(trainedNet, enhanced);
    confidence = max(scores) * 100;

    % 3. Grad-CAM
    scoreMap = gradCAM(trainedNet, enhanced, label);

    % Save Enhanced Image
    imwrite(enhanced, fullfile(outputFolder, 'enhanced.png'));

    % Save Grad-CAM overlay
    figure('Visible','off');
    imshow(enhanced);
    hold on;
    imagesc(scoreMap, 'AlphaData', 0.5);
    colormap jet;
    axis off;
    saveas(gcf, fullfile(outputFolder, 'gradcam.png'));
    close;

    % Save results as text
    fid = fopen(fullfile(outputFolder, 'results.txt'), 'w');
    fprintf(fid, '%s\n', string(label));
    fprintf(fid, '%.1f\n', confidence);
    fprintf(fid, '%s\n', status);
    fprintf(fid, '%s\n', feedback);
    fclose(fid);

    disp('Processing completed successfully!');
end