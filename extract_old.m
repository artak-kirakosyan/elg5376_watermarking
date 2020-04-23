function [extracted_watermark] = extract_old(source_file_path, result_file_path, sub_matrix_size, wavelet_name)
    % read information from mentioned file
    % disp("Reading info from file");
    
    load(result_file_path);
    u_matrices = cell2mat(results(1));
    v_matrices = cell2mat(results(2));
    % This variable will be used to cut the additional zeros from the
    % watermark
    watermark_tail = cell2mat(results(3));
    
    % this is used to remove unused samples from the signal 
    audio_tail = cell2mat(results(4));
    
    % this variable is not used but can be used to make sure that
    % everything is correct
    number_of_watermarks = cell2mat(results(5));
    
    % check if this is true, invert the extracted signal after extraction
    inverted = cell2mat(results(6));
    
    %reference value used for extraction
    intensiveness = cell2mat(results(7));
    % read audio from watermarked file, reshape and cut the tail
    [watermarked_audio,~] = audioread(source_file_path);
   
    audio_shape = size(watermarked_audio);
    if audio_shape(2) == 1
        % reshaping audio from column to raw for easy analysis
        watermarked_audio = reshape(watermarked_audio, 1, length(watermarked_audio));
    else
        if audio_shape(2) == 2
            watermarked_audio = reshape(watermarked_audio, 1, audio_shape(1)*audio_shape(2));
        else
            error("Too many channels, please provide one or 2 channel audio");
        end
    end
    
    watermarked_audio = watermarked_audio(1:length(watermarked_audio) - audio_tail);
    
    % bits per frame
    bits_per_frame = sub_matrix_size * sub_matrix_size - sub_matrix_size;
    
    % if the number of u and v matrices is not the same then something
    % is wrong.
    if length(u_matrices) ~= length(v_matrices)
        disp("The number of u and v matrices is not the same.");
        disp("Consider reruning the embedding part to try again.");
        disp("If the problem repeats, contact your system administrator");
        error("Incorrespondence in U and V matrices");
    end
    
    % this number shows how many frames are needed
    number_of_iterations = length(u_matrices);
    
    % preallocate memory for the final result
    extracted_watermark = zeros(1,bits_per_frame, number_of_iterations);
    
    % detect frame length
    frame_length = floor(length(watermarked_audio) / number_of_iterations);

    %disp("Finished preparations. Proceeding with extraction");
    
    % iterate over audio signal and extract watermark
    for index = 1:number_of_iterations
        % detect the beggining and the end of the current frame
        start = (index-1)*frame_length + 1;
        stop = start + frame_length -1;
        
        %here we keep the current frame and corresponding u and v matrices
        %in variables for easy access.
        current_frame = watermarked_audio(start:stop);
        current_u = u_matrices(:,:,index);
        current_v = v_matrices(:,:,index);
        
        %we give current frame and corresponding u and v matrices to
        %extract current bits from it
        current_bits = extract_bits_from_frame(current_frame, current_u, current_v, sub_matrix_size, wavelet_name, intensiveness);
        
        %keep current extracted bits into final result
        extracted_watermark(:,:,index) = current_bits;
    end
    
    %how many frames were used for 1 watermark
    frames_per_watermark = number_of_iterations/number_of_watermarks;
    
    %reshape extracted numbers in a matrix, having one full watermark on
    %each line
    extracted_watermark_series = reshape(extracted_watermark, 1, frames_per_watermark*bits_per_frame, number_of_watermarks);

    % sum up all extraced watermarks and divide by number of watermarks to
    % get the average
    extracted_watermark = zeros(1, frames_per_watermark*bits_per_frame);
    for i = 1:number_of_watermarks
        extracted_watermark = extracted_watermark + extracted_watermark_series(:,:,i);
    end
    
    %round the average to get final watermark, then cut the tail
    extracted_watermark = round(extracted_watermark/number_of_watermarks);
    extracted_watermark = extracted_watermark(1,1:length(extracted_watermark)-watermark_tail);
    
    %after deletion  we should check the value of inverted variable %
    %if its true, invert the signal                                 %
    if inverted == 1
        extracted_watermark = ~extracted_watermark;
    end
    disp("Extraction done!");
end

function extracted_bits = extract_bits_from_frame(frame, u_matrix, v_matrix, sub_matrix_size, wavelet_name, intensiveness)
    %apply DWT, get coefficients and form the current d_matrix.
    [~, D1, D2, D3, D4] = four_level_dwt(frame, wavelet_name);
    d_matrix = form_D_matrix(D1,D2,D3,D4);
    
    %decompose the watermarked d_matrix to get S1.
    [~,S1,~] = svd(d_matrix);
    
    %take the top left 4*4 matrix which contains watermark bits.
    S1_prime = S1(1:sub_matrix_size,1:sub_matrix_size);
    
    S_W_prime = u_matrix * S1_prime * transpose(v_matrix);
    extracted_bits = extract_bits(S_W_prime, sub_matrix_size, intensiveness);
end

function bits = extract_bits(s_matrix, sub_matrix_size, reference_value)
    %takes an s_matrix and extracts 12 bits from non diagonal elements.
    bits_in_matrix = sub_matrix_size * sub_matrix_size - sub_matrix_size; 
    bits = zeros(1,bits_in_matrix);
    index = 1;
    
    %this part takes the actual bits from the matrix.
    for row = 1:sub_matrix_size
        for col = 1:sub_matrix_size
            if row ~= col
                bits(index) = s_matrix(row,col);
                index = index + 1;
            end
        end
    end
    %here we calculate the average value of extracted bits.
    avg = sum(bits)/length(bits);

    %here we round the actual bits wrt their average.
    for index = 1:length(bits)
        if bits(index) <= avg
            bits(index) = 0;
        else
            bits(index) = 1;
        end
    end
end