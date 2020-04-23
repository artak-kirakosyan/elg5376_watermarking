function snr = calculate_SNR_path(path_1,path_2)
    % calculate SNR values of 2 audio files
    [signal_1,~] = audioread(path_1);
    [signal_2,~] = audioread(path_2);
    
    snr = 10*log10(sumsqr(signal_1)/sumsqr(signal_1-signal_2));
end
