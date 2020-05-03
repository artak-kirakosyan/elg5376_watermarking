function add_no_attack(source_file_path, target_file_path)
    [audio, fs] = audioread(source_file_path);
    audiowrite(target_file_path, audio, fs);
end