%% Load model
load('..\..\Models\efficientnet_dr_matlab.mat');

%% Load some validation images
[~, imdsVal] = loadAPTOSData();

% Pick 6 sample images (different classes)
idx = [10, 50, 100, 200, 300, 400];   % change if needed
imgs = imdsVal.Files(idx);
trueLabels = imdsVal.Labels(idx);

figure('Name','Grad-CAM Results', 'Position', [100 100 1200 800]);

for i = 1:6
    img = readimage(imdsVal, idx(i));
    
    % Predict
    [label, scores] = classify(trainedNet, img);
    conf = max(scores) * 100;
    
    % Grad-CAM
    scoreMap = gradCAM(trainedNet, img, label);
    
    % Plot
    subplot(2,3,i);
    imshow(img);
    hold on;
    imagesc(scoreMap, 'AlphaData', 0.45);
    colormap jet;
    title({string(trueLabels(i)) + " → " + string(label); ...
           sprintf('Confidence: %.1f%%', conf)}, 'FontSize', 10);
    axis off;
end

sgtitle('Grad-CAM Explainability - Sample Predictions');