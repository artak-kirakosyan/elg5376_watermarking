function attack_the_audio(attack_type, audio_path_wtmkd, audio_path_attacked)

attack_list = attack_type.split(" ");

switch attack_list(1)
    case "filter"
        cut_off_freq = str2num(attack_list(2));
        filter_the_signal(audio_path_wtmkd, audio_path_attacked, cut_off_freq);
    case "gauss"
        noise_power = str2num(attack_list(2));
        add_gaus_noise(audio_path_wtmkd, audio_path_attacked, noise_power);
    case "downsample"
        new_fs = str2num(attack_list(2));
        downsample_and_upsample(audio_path_wtmkd, audio_path_attacked, new_fs);
    case "quantize"
        quantize_signal(audio_path_wtmkd, audio_path_attacked);
    otherwise
        % this line is used when there is no attack
        add_no_attack(audio_path_wtmkd, audio_path_attacked);
end
end