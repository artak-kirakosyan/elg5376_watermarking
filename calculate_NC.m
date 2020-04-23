
function nc = calculate_NC(signal_1, signal_2)
    nc = sumsqr(signal_1.*signal_2)/sqrt((sumsqr(signal_1) *sumsqr(signal_2)));
end