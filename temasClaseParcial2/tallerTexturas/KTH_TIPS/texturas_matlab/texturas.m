%% Análisis de Texturas en 10 Imágenes
clc; clear; close all;

% Carpeta con las imágenes
folder = 'KTH_TIPS\aluminium_foil\';

% Seleccionamos las primeras 10 imágenes PNG
files = dir(fullfile(folder, '*.png'));
files = files(1:10); % Tomar solo 10 imágenes

% Tabla para guardar resultados
resultados = table;

for k = 1:length(files)
    % Leer imagen
    filename = fullfile(folder, files(k).name);
    I = imread(filename);
    if size(I,3) == 3
        I = rgb2gray(I);
    end

    % Mostrar la imagen
    figure;
    imshow(I); title(['Imagen ' num2str(k) ': ' files(k).name]);

    %% 1. GLCM
    GLCM = graycomatrix(I,'Offset',[0 1]); 
    stats = graycoprops(GLCM,{'Contrast','Correlation','Energy','Homogeneity'});

    %% 2. LBP
    lbpFeatures = extractLBPFeatures(I,'CellSize',[32 32]); 
    % Se puede usar el histograma como descriptor
    lbpHist = histcounts(lbpFeatures, 20);

    %% 3. Gabor
    wavelength = 4;  
    orientation = [0 45 90 135]; 
    gaborArray = gabor(wavelength,orientation);
    gaborMag = imgaborfilt(I,gaborArray);

    % Energía promedio de las respuestas de Gabor
    gaborEnergy = zeros(1, length(gaborArray));
    for i = 1:length(gaborArray)
        gaborEnergy(i) = mean2(gaborMag(:,:,i).^2);
    end

    %% 4. Wavelet
    [cA,cH,cV,cD] = dwt2(I,'db1'); 
    waveletEnergy = [sum(cA(:).^2), sum(cH(:).^2), sum(cV(:).^2), sum(cD(:).^2)];

    %% Guardar resultados en tabla
    resultados = [resultados; 
        table({files(k).name}, stats.Contrast, stats.Correlation, ...
        stats.Energy, stats.Homogeneity, {lbpHist}, {gaborEnergy}, {waveletEnergy}, ...
        'VariableNames', {'Imagen','Contrast','Correlation','Energy','Homogeneity','LBP','Gabor','Wavelets'})];
end

%% Mostrar resultados finales
disp(resultados);

% Guardar en Excel
writetable(resultados, 'Resultados_Texturas.xlsx');
