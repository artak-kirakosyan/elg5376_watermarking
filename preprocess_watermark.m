
function watermark = preprocess_watermark(raw_watermark)
    %normalize the values, and reshape into 1D array
    watermark = imbinarize(raw_watermark, graythresh(raw_watermark));
    dim = size(watermark);
    watermark = reshape(watermark, 1, dim(1)*dim(2));
end