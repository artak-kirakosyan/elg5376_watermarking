function [a4, d1, d2, d3, d4, l]= four_level_dwt(frame, wavelet_name)
    % takes in the frame and returns all sub-band coefficients.
    % used the haar wavelet as only this one gives proper size sub-bands
    % according to the algorithm.
    
    % applying DWT and extracting coefficients.
    [c,l] = wavedec(frame, 4, wavelet_name);
    a4 = appcoef(c,l, wavelet_name);
    [d1, d2, d3, d4] = detcoef(c,l,[1 2 3 4]);
end
