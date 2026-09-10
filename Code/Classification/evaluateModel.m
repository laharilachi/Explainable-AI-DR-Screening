%% Load trained model
load('..\..\Models\efficientnet_dr_matlab.mat');

%% Load validation data
[~, imdsVal] = loadAPTOSData();

%% Predict
[predLabels, scores] = classify(trainedNet, imdsVal);

%% Overall Accuracy
acc = mean(predLabels == imdsVal.Labels);
fprintf('\nValidation Accuracy: %.2f%%\n\n', acc*100);

%% Confusion Matrix
figure('Name','Confusion Matrix');
cm = confusionchart(imdsVal.Labels, predLabels);
cm.Title = 'Confusion Matrix - Validation Set';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

%% Class-wise Metrics
classes = categories(imdsVal.Labels);
confMat = confusionmat(imdsVal.Labels, predLabels);

fprintf('Class-wise Metrics:\n');
fprintf('%-18s %-12s %-12s\n', 'Class', 'Sensitivity', 'Specificity');
fprintf('-----------------------------------------------\n');

for i = 1:numel(classes)
    TP = confMat(i,i);
    FP = sum(confMat(:,i)) - TP;
    FN = sum(confMat(i,:)) - TP;
    TN = sum(confMat(:)) - TP - FP - FN;
    
    sensitivity = TP / (TP + FN + eps);
    specificity = TN / (TN + FP + eps);
    
    fprintf('%-18s %-12.2f%% %-12.2f%%\n', classes{i}, sensitivity*100, specificity*100);
end

%% Referable DR Metrics
referable = ["Moderate","Severe","Proliferate_DR"];
trueRef = ismember(imdsVal.Labels, referable);
predRef = ismember(predLabels, referable);

TP = sum(trueRef & predRef);
FP = sum(~trueRef & predRef);
FN = sum(trueRef & ~predRef);
TN = sum(~trueRef & ~predRef);

sens = TP / (TP + FN + eps);
spec = TN / (TN + FP + eps);

fprintf('\n============================================\n');
fprintf('Referable DR Sensitivity : %.2f%%\n', sens*100);
fprintf('Referable DR Specificity : %.2f%%\n', spec*100);
fprintf('============================================\n');