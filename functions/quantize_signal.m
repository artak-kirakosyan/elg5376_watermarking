function quantize_signal(source_file_path, target_file_path)

[audio, fs] = audioread(source_file_path);
    
quants=zeros(size(audio, 1), size(audio, 2)); 
maxsig=max(audio); %signal max
interv=2*maxsig/(2^8-1); %interval length for 8 levels resolution
u=maxsig+interv;
partition = [-maxsig:interv:maxsig]; 
codebook = [-maxsig:interv:u]; 
[~,quants(:, 1)] = quantiz(audio(:,1),partition,codebook); % Quantize.
[~,quants(:, 2)] = quantiz(audio(:,2),partition,codebook); % Quantize.


quants16=zeros(size(audio, 1), size(audio, 2)); 
maxsig=max(quants); %signal max
interv=2*maxsig/(2^16-1); %interval length for 8 levels resolution
u=maxsig+interv;
partition = [-maxsig:interv:maxsig]; 
codebook = [-maxsig:interv:u]; 
[~,quants16(:, 1)] = quantiz(quants(:,1),partition,codebook); % Quantize.
[~,quants16(:, 2)] = quantiz(quants(:,2),partition,codebook); % Quantize.


audiowrite(target_file_path, quants16, fs);
end