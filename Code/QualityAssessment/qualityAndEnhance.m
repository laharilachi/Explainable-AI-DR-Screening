function [enhancedImg, status, feedback] = qualityAndEnhance(img)
% Image Quality Assessment + Enhancement for Fundus Images

    img = im2double(img);
    gray = rgb2gray(img);

    % 1. Blur detection (Laplacian variance)
    lapVar = var(im2double(imfilter(gray, fspecial('laplacian'))), 0, 'all');

    % 2. Illumination check
    meanInt = mean(gray(:));
    stdInt  = std(gray(:));

    % 3. Decision
    if lapVar < 0.0015
        status = "Bad";
        feedback = "Image is too blurry. Please recapture.";
        enhancedImg = img;
        return;
    elseif meanInt < 0.15 || meanInt > 0.85 || stdInt < 0.08
        status = "Borderline";
        feedback = "Illumination issue detected. Enhancing...";
    else
        status = "Good";
        feedback = "Image quality is acceptable.";
    end

    % Enhancement (CLAHE)
    lab = rgb2lab(img);
    lab(:,:,1) = adapthisteq(lab(:,:,1)/100, 'ClipLimit', 0.02, 'NumTiles', [8 8]) * 100;
    enhancedImg = lab2rgb(lab);
    enhancedImg = im2double(enhancedImg);
end