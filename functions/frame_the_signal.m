function frames = frame_the_signal(input_signal,number_of_frames)
    % takes in the input signal and divides it into number_of_frames frames.
    frame_length = length(input_signal)/number_of_frames;
    frames = zeros(1, frame_length, number_of_frames);
    for i =1:number_of_frames
        frames(:,:,i) = input_signal((i-1)*frame_length + 1: i*frame_length);
    end
end