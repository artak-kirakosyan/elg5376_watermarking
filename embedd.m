function embedd(source_file_path, watermarked_file_path, result_file_path, watermark, sub_matrix_size, wavelet_name, intensiveness, frame_length)
    
    % if watermark has 60% ones, then inverted watermark will be used
    if sum(watermark) >= 0.6 * length(watermark)
        watermark = ~watermark;
        inverted = 1;
    else
        inverted = 0;
    end

    % read audio file
    [audio,fs] = audioread(source_file_path);
    
    % pass audio and all necessary information to add the watermark
    [watermarked_audio, u_matrices, v_matrices, watermark_tail, audio_tail, number_of_watermarks] = embedding_manager(audio, watermark, intensiveness, sub_matrix_size, wavelet_name, frame_length);
    % disp("Finished embedding the watermark");
    
    % write watermarked audio into file
    audiowrite(watermarked_file_path,watermarked_audio, fs);
    %disp("Finished writing watermarked audio");
    
    % add all results needed in extraction stage and write to file
    results = {u_matrices, v_matrices, watermark_tail, audio_tail, number_of_watermarks, inverted, intensiveness};
    save(result_file_path, 'results');
    % disp("Finished writing extraction info");
    disp("Embedding done!");
    disp("**************");
end

function [final_watermarked_audio,u_matrices, v_matrices, watermark_tail, audio_tail, number_of_watermarks] = embedding_manager(audio, watermark, intensiveness, sub_matrix_size, wavelet_name, frame_length)
    audio_shape = size(audio);
    if audio_shape(2) == 1
        % reshaping audio from column to raw for easy analysis
        audio = reshape(audio, 1, length(audio));
        two_channel_audio = 0;
    else
        if audio_shape(2) == 2
            audio = reshape(audio, 1, audio_shape(1)*audio_shape(2));
            two_channel_audio = 1;
        else
            error("Too many channels, please provide one or 2 channel audio");
        end
    end
    % keep length of audio in variable
    audio_length = length(audio);

    % this number shows the number of bits which will be encoded in one
    % frame
    bits_per_frame = sub_matrix_size^2 - sub_matrix_size;
    
    % check if watermark needs more bits, add necessary 0's in the end
    watermark_reminder = rem(length(watermark), bits_per_frame);
    if watermark_reminder ~= 0
        watermark_tail = bits_per_frame - watermark_reminder;
        watermark = [watermark, zeros(1,watermark_tail)];
    else
        watermark_tail = 0;
    end
    
    % check how many frames will be needed to embedd one full watermark
    frames_per_watermark = length(watermark)/bits_per_frame;
    
    % frame the watermark to have bits_per_frame elements per
    % watermark frame
    watermark_frames = frame_the_signal(watermark, frames_per_watermark);
    
    % detect how many samples are needed to embed one full watermark
    samples_per_watermark = frame_length * frames_per_watermark;
  
    if(samples_per_watermark > audio_length)
        error("Can't embed the watermark. Use longer audio or shorter watermark");
        %frames_per_watermark=floor(audio_length/frame_length);
        %samples_per_watermark = frame_length * frames_per_watermark;
    end
    
    % calculate how many full watermarks will be embedded and how many
    % total frames will be proceed during embedding
    number_of_watermarks = floor(audio_length / samples_per_watermark);
    number_of_iterations = number_of_watermarks * frames_per_watermark;

    % preallocate memory for u and v matrices
    u_matrices = zeros(sub_matrix_size, sub_matrix_size, number_of_iterations);
    v_matrices = zeros(sub_matrix_size, sub_matrix_size, number_of_iterations);
    
    % check the size of the audio which will not be used for embedding
    if number_of_iterations ~= audio_length / frame_length
        audio_tail = audio(number_of_iterations*frame_length+1: audio_length);
        audio = audio(1:number_of_iterations*frame_length);
    else
        audio_tail = 0;
    end
    
    % preallocate memory for watermarked_frames
    watermarked_frames = zeros(1,frame_length, number_of_iterations);
    
    % iterate over frames and embed bits into frames
    for index = 1:number_of_iterations
        
        % detect the beggining and the end of the current frame
        start = (index-1)*frame_length + 1;
        stop = start + frame_length -1;
        current_frame = audio(start:stop);
        
        % take necessary bits of the watermark to embed
        current_bits = watermark_frames(:,:,rem(index-1,frames_per_watermark)+1);
        
        % pass all current info to a function, which embedds into 1 frame 
        % and returns results
        [watermarked_frame, U1_matrix, V1_matrix] = embedd_one_frame(current_frame, current_bits, sub_matrix_size, intensiveness, wavelet_name);
        
        % add u and v matrices to final result to be used in extraciton
        u_matrices(:,:,index) = U1_matrix;
        v_matrices(:,:,index) = V1_matrix;
        
        % append current frame to final one
        watermarked_frames(:,:,index) = watermarked_frame;
    end
    
    % reshape the result, append the tail and reshape to initial form
    final_watermarked_audio = reshape(watermarked_frames, 1, frame_length * number_of_iterations);
    final_watermarked_audio = [final_watermarked_audio, audio_tail];
    
    if two_channel_audio == 1
        final_watermarked_audio = reshape(final_watermarked_audio, length(final_watermarked_audio)/2, 2);
    else
        final_watermarked_audio = reshape(final_watermarked_audio, length(final_watermarked_audio), 1);
    end
    
    % keep only the number of unused samples of audio to be used in
    % extraction
    audio_tail = length(audio_tail);
end

function [watermarked_frame, U1_matrix, V1_matrix] = embedd_one_frame(current_frame, current_bits, sub_matrix_size, intensiveness, wavelet_name)
    % use 4-level DWT on current frame to extract sub-bands and form the
    % D_matrix
    [A4, D1, D2, D3, D4, L] = four_level_dwt(current_frame, wavelet_name);
    d_matrix = form_D_matrix(D1, D2, D3, D4);
    
    % use SVD to decompose D_matrix and take the neccessary sub_matrix
    % for embedding purposes
    [U_matrix, S, V_matrix] = svd(d_matrix);
    
    S_matrix = S(1:sub_matrix_size, 1:sub_matrix_size);
    
    % form the w_matrix using the current bits
    current_w = form_W_matrix(sub_matrix_size, current_bits);

    % embed watermarks into S_matrix
    s_embedded = S_matrix + intensiveness * current_w;
    
    % keep these U1 and V1 as they will be used for the extraction
    [U1_matrix, S1, V1_matrix] = svd(s_embedded);

    % insert watermarked values into big S_matrix
    for row = 1:sub_matrix_size
        for col = 1:sub_matrix_size
        S(row, col) = S1(row, col);
        end
    end

    % collect embedded watermarked sub-band matrix
    D_watermarked = U_matrix * S * transpose(V_matrix);
    
    % extract new sub-bands from matrix and for a new array to use in
    % inverse DWT
    [D1, D2, D3, D4] = extract_watermarked_sub_bands(D_watermarked);
    C = [A4, D4, D3, D2, D1];
    watermarked_frame = waverec(C,L,wavelet_name);
end