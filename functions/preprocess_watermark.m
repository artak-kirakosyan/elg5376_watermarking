function watermark = preprocess_watermark(watermark_path)
    raw_watermark = imread(watermark_path);
    %normalize the values, and reshape into 1D array
    min_ = min(raw_watermark, [], 'all');
    max_ = max(raw_watermark, [], 'all');
    mid = (min_ + max_)/2;
    watermark = raw_watermark > mid;
    dim = size(watermark);
    watermark = reshape(watermark, 1, dim(1)*dim(2));
end