function output = ifftc(input, varargin)

    
    L = size(input);
    
    output = input;
    n = L(1);
    
    ii=1
    output = ifftshift(ifft(fftshift(output, ii),[], ii), ii);
    
    output = sqrt(n)*output; 
