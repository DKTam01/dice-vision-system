%{
Authors:    Daniel Kee Tam
Assignment: EGR 103 
Changed:    May 1 2025 (Added blue-background removal & relaxed shape thresholds)
History:    Mar  5 2025 - Initial version.
            May  1 2025 - HSV masking & shape filtering added.
            May  2 2025 - Shape thresholds relaxed to avoid under-counting.
Purpose:    Capture an image of a dice, isolate the dice region, count the black pips,
            filter out blue shadows.
%}

%% Step 1: Capture Original Image
camList = webcamlist;
usbIdx  = find(contains(camList,'USB'),1);
if isempty(usbIdx)
    error('No USB camera found. Please check your connection.'); 
end

cam = webcam(camList{usbIdx});
fmts = cam.AvailableResolutions;
ix   = find(contains(fmts,'RGB24')|contains(fmts,'MJPG'),1);
if ~isempty(ix)
    cam.Resolution = fmts{ix}; 
end

raw = snapshot(cam);
if size(raw,3) == 1
    raw = repmat(raw,[1,1,3]); 
end

%% Step 2: Initialize Dashboard & Crop
figure('Name', 'Dice Vision System Dashboard', 'Position', [100, 100, 1000, 600]);

% 2.1 Crop to Dice Region
roi4dice     = [192, 158, 200, 174];
croppedImage = imcrop(raw, roi4dice);

subplot(2,3,1);
imshow(croppedImage);
title('1. Cropped Original');

%% Step 3: Grayscale Conversion
grayImage = rgb2gray(croppedImage);

subplot(2,3,2);
imshow(grayImage);
title('2. Grayscale');

%% Step 4: Threshold, Invert & Blue HSV Mask
level       = graythresh(grayImage);
binaryImage = imbinarize(grayImage, level);
binaryImage = imcomplement(binaryImage);

% Remove Blue-Background Shadows
hsvImage = rgb2hsv(croppedImage);
hue  = hsvImage(:,:,1);
sat  = hsvImage(:,:,2);
blueMask = (hue>=0.55 & hue<=0.75) & (sat>=0.2);
binaryImage(blueMask) = 0;

subplot(2,3,3);
imshow(binaryImage);
title('3. Threshold & Blue Mask');

%% Step 5: Morphological Cleanup
cleanedImage = bwareaopen(binaryImage, 50);
filledImage  = imfill(cleanedImage, 'holes');

subplot(2,3,4);
imshow(filledImage);
title('4. Morphological Cleanup');

%% Step 6: Detect & Filter by Relaxed Shape Metrics
stats = regionprops('table', filledImage, ...
    'Centroid','BoundingBox','Area','Eccentricity','Solidity');

% Relaxed thresholds
minArea     =  80;    % allow a few smaller dots
maxArea     = 400;    % allow a few larger/merged blobs
maxEcc      =  0.9;   % permit more elongation
minSolidity =  0.6;   % permit a bit more raggedness

keepIdx = stats.Area >= minArea & stats.Area <= maxArea ...
        & stats.Eccentricity <= maxEcc ...
        & stats.Solidity    >= minSolidity;

filteredStats = stats(keepIdx,:);
numPips       = height(filteredStats);
disp("Number of dice pips detected: " + numPips);

%% Step 7: Visualize Final Detections
subplot(2,3,[5 6]); % Make the final result larger
imshow(croppedImage);
title(sprintf('Final Detection: %d Pips', numPips));
hold on;
for k = 1:numPips
    rectangle('Position', filteredStats.BoundingBox(k,:), ...
              'EdgeColor','r','LineWidth',2);
    plot( filteredStats.Centroid(k,1), filteredStats.Centroid(k,2), ...
          'r+','MarkerSize',10,'LineWidth',2);
end
hold off;

%% Step 8: Keep Dashboard Open Until User Acknowledges
disp('Press any key in the command window to close the visualization...');
pause; 
close all;
clear cam; % Release the webcam hardware