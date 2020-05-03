function ber = calculate_ber(signal_1,  signal_2)
    ber = sum(xor(signal_1, signal_2))/length(signal_1);
end