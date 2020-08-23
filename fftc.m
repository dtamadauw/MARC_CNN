function output = fftc(input)


    L = size(input);
    
    output = input;
    n = L(1);
    
    ii=1
    output = ifftshift(fft(fftshift(output, ii),[], ii), ii);
  
    
    output = (1/sqrt(n))*output; 
