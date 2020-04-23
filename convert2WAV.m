function convert2WAV(filename, extract_path)


[audioSignal, frequency] = audioread(filename);

audiowrite(extract_path, audioSignal, frequency);

end