close all
clc
Normal = 0;
Diagnosed=0;
%
for i = 1:10
    I = imread(['ok' num2str(i) '.ppm']);     % Görüntü okundu
    I_crop = imcrop(I,[95, 95, 500, 410]);    % Görüntü kırpıldı
    I2 = rgb2gray(I_crop);                    % Görüntü gray level görüntüye dönüştürüldü
    I_adjusted = imadjust(I2, [0.2 0.7], [0 1], 0.8);   % Görüntünün yoğunluğu ayarlandı.
    I_contrast = adapthisteq(I_adjusted, 'numTiles', [8 8], 'nBins', 28);   %Görüntünün kontrastı ayarlandı
    meanfilt = fspecial('average', [90, 90]);     % Average filter tanımlandı
    mask_mean = imfilter(I_contrast, meanfilt);   % Görüntü average filtreden geçirildi.
    mask_mean2 = imsubtract(mask_mean, I_contrast);  % Average filtreden geçirilen kontrastı ayarlanmış görüntü, filtreden çkartılarak kenar tespiti...
    ...yapıldı
    mask_binarize = imbinarize(mask_mean2, 'adaptive', 'ForegroundPolarity','dark','Sensitivity',0.6);  % Görüntü siyah-beyaz 'a çevrildi.
    bw = bwareaopen(mask_binarize, 100);  % Görüntü açıldı. ( Görüntüdeki küçük nesneler çıkartıldı. Böylece elimizde damarları...
    ...gösteren daha net görüntü kaldı. ) / Gürültüden temizlendi
    se = strel('disk',2);   % Morphologic işlemler için yapılandırma elemanı tanımlandı.
    bw = imclose(bw,se);    % Görüntü kapatıldı
    CC = bwconncomp(bw);    % Connected graph components...
    ... Bir struct' da görüntünün özelliklerini tutuyoruz. (Connectivity, ImageSize, NumObjects, PixelIdxList)

    numPixels = cellfun(@numel, CC.PixelIdxList);  % Objeleri piksel sayılarına göre indexleyerek sıralıyor.
    [biggest, idx] = max(numPixels);  % En fazla piksel sayısına sahip (en büyük obje) objeyi buluyor.
    bw(CC.PixelIdxList{idx}) = 0;     % En büyük objeyi siliyor.
    cc_1 =bwconncomp(bw, 26);  % En büyük objesi silinmiş objeyi içeren görüntüyü, bağlanabilirlik özelliği 26 olacak şekilde tekrar oluşturuyor ve...
    ...bu görüntünün özelliklerini bir struct' a topluyor.
    RemoveVessels = bwpropfilt(bw, 'Eccentricity', [0, .9]);  % Siyah-beyaz level görüntüden obje çıkartır. Görüntüde hala damar varsa bunlar kaldırılır.
    figure(i)    % figure oluşturuldu
    subplot(3,2,1) % subplot oluşturuldu
    imshow(I_crop, 'Border', 'tight')
    title({'Cropped Image','Imcrop filter on original Image'})
    subplot(3,2,2)
    imshow(I2, 'Border', 'tight')
    title({'Grayscale Image','rgb2gray and',' imcrop filter applied'})
    subplot(3,2,3)
    imshow(I_adjusted, 'Border', 'tight')
    title({'Contrasted Image','Imadjust Filter'})
    subplot(3,2,4)
    imshow(bw)
    title({'Close and Fill Gaps','Imclose Filter'})
    % Plot the image with most blood vessels removed.
    subplot(3,2,[5 6])
    imshow(RemoveVessels)
    title({'bwpropfilt Filter','Final Filtered Image'})
    centroid_dataV = regionprops(RemoveVessels,'Centroid');  % Görüntüdeki balonculkar ve bunların merkezleri elde edildi ve bu bilgi bir struct' da tutuldu.
    NumberBlobs = length(centroid_dataV);    % Struct'ın uzunluğuna (eleman sayısı) elde edildi.
    if NumberBlobs <= 5    % Baloncuk sayısı 5 'e eşit veya daha küçükse göz sağlıklı.
        fprintf('%d possible spots identified at ok #%d.ppm. Eye is normal\n', NumberBlobs, i);
        Normal = Normal+1;
    else                   % Baloncuk sayısı 5 'ten büyükse göz hastalıklıdır.
        Diagnosed = Diagnosed +1;
        fprintf('%d possible spots identified in ok #%d.ppm. Diabetic Retinopathy Symptoms Detected\n', NumberBlobs, i);
    end
    i=i+1;
end

% Aynı işlemleri hastalıklı retina fotoğrafları için tekrarla.
for i = 1:10
    I = imread(['dr' num2str(i) '.ppm']);     % Görüntü okundu
    I_crop = imcrop(I,[95, 95, 500, 410]);    % Görüntü kırpıldı
    I2 = rgb2gray(I_crop);                    % Görüntü gral level görüntüye dönüştürüldü
    I_adjusted = imadjust(I2, [0.2 0.7], [0 1], 0.8);   % Görüntünün yoğunluğu ayarlandı.
    I_contrast = adapthisteq(I_adjusted, 'numTiles', [8 8], 'nBins', 28);   %Görüntünün kontrastı ayarlandı
    meanfilt = fspecial('average', [90, 90]);     % Average filter tanımlandı
    mask_mean = imfilter(I_contrast, meanfilt);   % Görüntü average filtreden geçirildi.
    mask_mean2 = imsubtract(mask_mean, I_contrast);  % Average filtreden geçirilen kontrastı ayarlanmış görüntü, filtreden çkartılarak kenar tespiti...
    ...yapıldı
    mask_binarize = imbinarize(mask_mean2, 'adaptive', 'ForegroundPolarity','dark','Sensitivity',0.6);  % Görüntü siyah-beyaz 'a çevrildi.
    bw = bwareaopen(mask_binarize, 100);  % Görüntü açıldı. ( Görüntüdeki küçük nesneler çıkartıldı. Böylece elimizde damarları...
    ...gösteren daha net görüntü kaldı. ) / Gürültüden temizlendi
    se = strel('disk',2);   % Morphologic işlemler için yapılandırma elemanı tanımlandı.
    bw = imclose(bw,se);    % Görüntü kapatıldı
    CC = bwconncomp(bw);    % Connected graph components  / Bir struct' da görüntünün özelliklerini tutuyoruz. (Connectivity, ImageSize, NumObjects, PixelIdxList)
    numPixels = cellfun(@numel, CC.PixelIdxList);  % Objeleri piksel sayılarına göre indexleyerek sıralıyor.
    [biggest, idx] = max(numPixels);    % En fazla piksel sayısına sahip (en büyük obje) objeyi buluyor.
    bw(CC.PixelIdxList{idx}) = 0;       % En büyük objeyi siliyor.
    cc_1 =bwconncomp(bw, 26);           % En büyük objesi silinmiş objeyi içeren görüntüyü, bağlanabilirlik özelliği 26 olacak şekilde tekrar oluşturuyor ve...
    ...bu görüntünün özelliklerini bir struct' a topluyor.
    RemoveVessels = bwpropfilt(bw, 'Eccentricity', [0, .9]);  % Siyah-beyaz level görüntüden obje çıkartır. Görüntümüzde hala damar yapısı varsa bunları kaldırır.
    figure(i+10)    % figure oluşturuldu
    subplot(3,2,1)  % subplot oluşturuldu
    imshow(I_crop, 'Border', 'tight')
    title({'Cropped Image','Imcrop filter on original Image'})
    subplot(3,2,2)
    imshow(I2, 'Border', 'tight')
    title({'Grayscale Image','rgb2gray and',' imcrop filter applied'})
    subplot(3,2,3)
    imshow(I_adjusted, 'Border', 'tight')
    title({'Contrasted Image','Imadjust Filter'})
    subplot(3,2,4)
    imshow(bw)
    title({'Close and Fill Gaps','Imclose Filter'})
    % Plot the image with most blood vessels removed.
    subplot(3,2,[5 6])
    imshow(RemoveVessels)
    title({'bwpropfilt Filter','Final Filtered Image'})
    centroid_dataV = regionprops(RemoveVessels,'Centroid');   % Görüntüdeki balonculkar ve bunların merkezleri elde edildi ve bu bilgi bir struct' da tutuldu.
    NumberBlobs = length(centroid_dataV);      % Struct'ın uzunluğuna (eleman sayısı) elde edildi.               
    if NumberBlobs <= 5        % Baloncuk sayısı 5 'e eşit veya daha küçükse göz sağlıklı.
        fprintf('%d possible spots identified at dr #%d.ppm. Eye is normal\n', NumberBlobs, i+10);
        Normal = Normal+1;     % Baloncuk sayısı 5 'ten büyükse göz hastalıklıdır.
    else
        Diagnosed = Diagnosed +1;
        fprintf('%d possible spots identified in dr #%d.ppm. Diabetic Retinopathy Symptoms Detected\n', NumberBlobs, i+10);
    end
    i=i+1;
    
end
