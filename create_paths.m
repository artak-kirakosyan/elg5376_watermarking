function [target, watermarked, attacked, watermark_path, watermark_path_old, result_file_path] = create_paths(audio_name, type)
   
    result_file_path = "./testing/"+audio_name+"results.mat";
    if type=="mp3"
        target = "./testing/"+audio_name+".mp3";
    else
        target = "./testing/"+audio_name+".wav";
    end
    watermarked = "./testing/"+audio_name+"_watermarked.wav";
    attacked = "./testing/"+audio_name+"_attacked.wav";
    watermark_path = "./testing/"+audio_name+"_extracted.png";
    watermark_path_old = "./testing/"+audio_name+"_extracted_old.png";
end