%%
clear;
clc;

% original_audio_files = ["pop_watermarked_64", "pop_watermarked_128", "pop_watermarked_256", ...
%     "classic_watermarked_64", "classic_watermarked_128", "classic_watermarked_256", ...
%     "jazz_watermarked_64", "jazz_watermarked_128", "jazz_watermarked_256", ...
%     "blues_watermarked_64", "blues_watermarked_128", "blues_watermarked_256", ...
%     "piano_watermarked_64", "piano_watermarked_128", "piano_watermarked_256"];
original_audio_files = ["pop", "classic", "jazz", "blues", "piano"];

watermark_path = './testing/uottawa.png';

wavelet_name = "haar";
sub_matrix_size = 4;

raw_watermark = imread(watermark_path);
watermark = preprocess_watermark(raw_watermark);

%intensiveness value
intensiveness = 0.4;
%frame length values
frame_length = 8192;
i=1;
experimental_results = ["Audio name","SNR","NC_old","NC","BER_old","BER"];

% result_files_for_MP3=["popresults.mat", "popresults.mat", "popresults.mat", ...
%     "classicresults.mat", "classicresults.mat", "classicresults.mat", ...
%     "jazzresults.mat", "jazzresults.mat", "jazzresults.mat", ...
%     "bluesresults.mat", "bluesresults.mat", "bluesresults.mat", ...
%     "pianoresults.mat", "pianoresults.mat", "pianoresults.mat"];
%%
for file = original_audio_files
    % source_file_path - file to be watermarked
    % watermarked_file_path - write to this file after watermarking
    % extract_path - this audio will be used for extraction(add attacks to
    % watermarked_file_path and write the result to extract_path.   
    [source_file_path, watermarked_file_path, extract_path, extracted_watermark_path, ...
        old_extracted_watermark_path, result_file_path] = create_paths(file, "wav");
    embedd(source_file_path, watermarked_file_path, result_file_path, watermark, sub_matrix_size, ...
    wavelet_name, intensiveness, frame_length);
    snr = calculate_SNR_path(source_file_path, watermarked_file_path);

    %MP3 conversion
%     convert2WAV(source_file_path, extract_path);
%     result_file_path=result_files_for_MP3(i);
%     snr=0;
    
    % this line is used when there is no attack
    %add_no_attack(watermarked_file_path, extract_path);
    
    % Robustness test A. Additive White Gaussian Noise
    % this line adds white gaussian noise(15DB) to the file and writes the result
    % into extract_path
    add_gaus_noise(watermarked_file_path, extract_path, 15);
    
    % Robustness test: Downsampling
    %downsample_and_upsample(watermarked_file_path, extract_path, 11025);

    %quantize_signal(watermarked_file_path, extract_path);
    
    % Robustness test D. Low-pass filtering
    % this line filters the signal with given cut-off frequency and writes
    % the filtered signal into extract_path file
    % filter_the_signal(watermarked_file_path, extract_path, 4000);
    
    extracted_watermark_old = extract_old(extract_path, result_file_path, sub_matrix_size, wavelet_name);
    extracted_watermark = extract(extract_path, result_file_path, sub_matrix_size, wavelet_name);
    
    nc_old = calculate_NC(extracted_watermark_old, watermark);
    ber_old = calculate_ber(extracted_watermark_old, watermark);
    nc = calculate_NC(extracted_watermark, watermark);
    ber = calculate_ber(extracted_watermark, watermark);
    write_image(extracted_watermark,extracted_watermark_path);
    write_image(extracted_watermark_old,old_extracted_watermark_path);
    current_results = [file,snr,nc_old,nc,ber_old,ber];
    experimental_results = [experimental_results;current_results];
    
    i=i+1;
    
end