function filter_the_signal(source_file_path, target_file_path, cut_off_freq)
    % design a butterworth filter of 10th order and pass the audio through it, then write
    % to another file
    [audio, fs] = audioread(source_file_path);
    %fc = cut_off_freq;
    %[b,a] = butter(10, 2*fc/fs);
    %filtered = filter(b, a, audio);
    %audiowrite(target_file_path, filtered, fs);
    
    %%
    filtered = lowpass(audio, cut_off_freq, fs);
    audiowrite(target_file_path, filtered, fs);
end