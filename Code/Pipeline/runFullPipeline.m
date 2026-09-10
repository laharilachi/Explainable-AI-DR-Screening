function runFullPipeline(imagePath)
% Full Pipeline: Quality → Enhance → Classify → Grad-CAM

    % Load model
    load('..\..\Models\efficientnet_dr_matlab.mat');
    
    % Read image
    img = imread(imagePath);
    
    % 1. Quality Assessment + Enhancement
    [enhancedImg, status, feedback] = qualityAndEnhance(img);
    
    fprintf('Quality Status : %s\n', status);
    fprintf('Feedback       : %s\n\n', feedback);
    
    if status == "Bad"
        figure;
        imshow(img);
        title('Bad Quality - Please Recapture');
        return;
    end
    
    % 2. Classification
    [label, scores] = classify(trainedNet, enhancedImg);
    confidence = max(scores) * 100;
    
    fprintf('Predicted Grade : %s\n', string(label));
    fprintf('Confidence      : %.1f%%\n\n', confidence);
    
    % 3. Grad-CAM
    scoreMap = gradCAM(trainedNet, enhancedImg, label);
    
    % 4. Display Results
    figure('Name','Full Pipeline Result', 'Position', [100 100 1400 500]);
    
    subplot(1,3,1);
    imshow(img);
    title('Original Image');
    
    subplot(1,3,2);
    imshow(enhancedImg);
    title(['Enhanced (' + status + ')']);
    
    subplot(1,3,3);
    imshow(enhancedImg);
    hold on;
    imagesc(scoreMap, 'AlphaData', 0.5);
    colormap jet;
    title({string(label); sprintf('Confidence: %.1f%%', confidence)});
    colorbar;
    
    sgtitle('SIH26038 - Explainable AI DR Screening Pipeline');
end