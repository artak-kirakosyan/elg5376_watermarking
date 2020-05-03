function d_matrix = form_D_matrix(D1,D2,D3,D4)
    
    %take detail sub-bands and form the d_matrix.
    d_matrix = [D1;D2,D2;D3,D3,D3,D3;D4,D4,D4,D4,D4,D4,D4,D4];
end