%add gaussian noise
function add_gaus_noise(source_file_path, target_file_path, strength)
    [audio, fs] = audioread(source_file_path);
    noiced = awgn(audio, strength, 'measured');
    audiowrite(target_file_path, noiced, fs);
end
