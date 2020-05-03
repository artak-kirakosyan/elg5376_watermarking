function attack_the_audio(attack_type, audio_path_wtmkd, audio_path_attacked)

% this line is used when there is no attack
add_no_attack(audio_path_wtmkd, audio_path_attacked);

% Robustness test A. Additive White Gaussian Noise
% this line adds white gaussian noise(15DB) to the file and writes the result
% into extract_path
%add_gaus_noise(watermarked_file_path, extract_path, 15);

% Robustness test: Downsampling
%downsample_and_upsample(watermarked_file_path, extract_path, 11025);

%quantize_signal(watermarked_file_path, extract_path);

% Robustness test D. Low-pass filtering
% this line filters the signal with given cut-off frequency and writes
% the filtered signal into extract_path file
% filter_the_signal(watermarked_file_path, extract_path, 4000);
end