clear;
clc;

oldpath = path;
path(oldpath, "functions");

%Control parameters
watermark_path = "watermarks/uottawa.png";
audio_dir = "test_audios";

results_dir = "results/";
sub_matrix_size = 4;
wavelet_name = "haar";
%intensiveness value
intensiveness = 0.4;
%frame length values
frame_length = 1024;
attacks = ["no_attack"];

if exist(results_dir, 'dir')
    rmdir(results_dir, 's');
end
mkdir(results_dir);

audio_files_struct = dir(fullfile(audio_dir, '*.wav'));
audio_paths = [];
audio_names = [];

for i=1:length(audio_files_struct)
    audio_name = string(audio_files_struct(i).name);
    audio_paths = [audio_paths; audio_dir + "/" + audio_name];
    audio_names = [audio_names; audio_name.replace(".wav", "")];
end

num_of_attacks = length(attacks);
num_of_audios = length(audio_paths);

watermark = preprocess_watermark(watermark_path);


for attack_name = attacks
    
    experimental_results = strings(num_of_audios + 1, 6);
    experimental_results(1, :) = ["Audio name", "SNR", "NC_old", "NC", "BER_old", "BER"];
    curr_res_dir = results_dir + attack_name + "/";
    mkdir(results_dir, attack_name);
    
    for file_index = 1:num_of_audios
    
        audio_path = audio_paths(file_index);
        audio_name = audio_names(file_index);
        copyfile(audio_path, curr_res_dir);
        
        audio_path_wtmkd = curr_res_dir + audio_name + "_wtmkd.wav";
        extr_info_path = curr_res_dir + audio_name + "_ext_info.mat";
    
        audio_path_attacked = curr_res_dir + audio_name + "_attacked.wav";
        
        extracted_wtmk_path = curr_res_dir + audio_name + "_wtmk_extr.png";
        extracted_wtmk_path_old = curr_res_dir + audio_name + "_wtmk_extr_old.png";
    
        embedd(audio_path, ...
            audio_path_wtmkd, ...
            extr_info_path, ...
            watermark, ...
            sub_matrix_size, ...
            wavelet_name, ...
            intensiveness, ...
            frame_length);

        snr = calculate_SNR_path(audio_path, audio_path_wtmkd);
        attack_the_audio(attack_name, audio_path_wtmkd, audio_path_attacked);
        

        extracted_watermark_old = extract_old(audio_path_attacked, ...
                                              extr_info_path, ...
                                              sub_matrix_size, ...
                                              wavelet_name);
        extracted_watermark = extract(audio_path_attacked, ...
                                      extr_info_path, ...
                                      sub_matrix_size, ...
                                      wavelet_name);

        nc_old = calculate_NC(extracted_watermark_old, watermark);
        ber_old = calculate_ber(extracted_watermark_old, watermark);

        nc = calculate_NC(extracted_watermark, watermark);
        ber = calculate_ber(extracted_watermark, watermark);

        write_image(extracted_watermark, extracted_wtmk_path);
        write_image(extracted_watermark_old, extracted_wtmk_path_old);

        current_results = [audio_name, snr, nc_old, nc, ber_old, ber];
        experimental_results(file_index + 1, :) = current_results;
    end
    save(curr_res_dir +attack_name, "experimental_results");
end
