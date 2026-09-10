function out = preprocessImage(img)
    % Resize to 224x224
    img = imresize(img, [224 224]);

    % Convert to LAB color space
    lab = rgb2lab(img);

    % Apply CLAHE on L channel
    lab(:,:,1) = adapthisteq(lab(:,:,1)/100, 'ClipLimit', 0.02, 'NumTiles', [8 8]) * 100;

    % Convert back to RGB
    out = lab2rgb(lab);
    out = im2double(out);
end