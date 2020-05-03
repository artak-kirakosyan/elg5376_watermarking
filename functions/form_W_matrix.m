function w_matrix = form_W_matrix(size, current_bits)
    % form the w matrix which contains bits
    w_matrix = zeros(size);
    index = 1;
    for row = 1:size
        for col = 1:size
            if row ~= col
                w_matrix(row,col) = current_bits(index);
                index = index + 1;
            end
        end
    end
end
