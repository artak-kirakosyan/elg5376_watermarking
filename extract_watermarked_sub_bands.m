function [D1, D2, D3, D4] = extract_watermarked_sub_bands(D_watermarked)
    % extract sub_bands from d_matrix
    l = length(D_watermarked);
    D1 = D_watermarked(1,1:l);
    D2 = D_watermarked(2,1:l/2);
    D3 = D_watermarked(3,1:l/4);
    D4 = D_watermarked(4,1:l/8);
end
