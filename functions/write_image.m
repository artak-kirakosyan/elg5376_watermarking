function write_image(watermark, path)
    s = size(watermark);
    s = sqrt(s(2));
    imwrite(reshape(watermark, s, s), path);
end