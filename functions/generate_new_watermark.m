function generate_new_watermark(path_to_watermark, watermark_size)
    new_img = rand(watermark_size) > 0.5;
    imwrite(new_img, path_to_watermark);
end