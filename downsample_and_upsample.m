function [] = downsample_and_upsample(source_file_path, target_file_path, resampling_rate)
    [audio, fs_old] = audioread(source_file_path);
    resampled = resample(audio, resampling_rate, fs_old);
    audiowrite(target_file_path, resampled, resampling_rate);
    [resampled_read, fs] = audioread(target_file_path);
    resampled_new = resample(resampled_read, fs_old, fs);
    audiowrite(target_file_path, resampled_new, fs_old);
end