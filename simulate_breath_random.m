function [y, pos_change_y, pos_change_z] = simulate_breath_random(in, varargin)

    dim = size(in);

    %Get number of phase
    if length(varargin) > 0
       num_phase = varargin{1}; 
    else
        num_phase = 7;
    end

    in2 = reshape(in, dim(1), dim(2), dim(3));

    [xx,yy,zz] = meshgrid(1:size(in,2), 1:size(in,1), 1:size(in,3));

    
    phase_map_y = 0*yy;
    pos_change_y = phase_map_y;
    pos_change_z = phase_map_y;


    for jj=1:size(in2,3)

        %Determine the number of PE line with noise
        num_noise = 2 * round(0.1*dim(1) + 0.5*rand*dim(1));

        %Select PE lines
        valid_pos = ceil(rand(1,num_noise) * size(in,1));

        %Determine shift along PE direction randomly
        pos_change = 0.30 * dim(1) * (rand(num_noise, 1, 1) - 0.5);
        pos_change = repmat(pos_change, [1 dim(2) 1]);

        pos_change_y(valid_pos(:),:,jj) = pos_change;

    end

    %No motion shift in the center of k-space
    xc = (size(in,1)/2 - round(0.1*dim(1))):(size(in,1)/2 + round(0.1*dim(1)));
    pos_change_y(xc,:,:) = 0;

    %Add noise to the k-space
    y = shift_PE(in2, pos_change_y, pos_change_z);


function y = shift_PE(in, posy, posz)

    temp = in;
    
    for ii=1:size(in,3)
        
        %Add B0 inhomogeneity
        B0 = 0.25*make_B0field(size(in));
        B0 = exp( complex(0, B0) );

        temp(:,:,ii) = temp(:,:,ii) .* B0;
        
    end
    
    spect = fft2c(temp);

    [xx,yy,zz] = meshgrid(1:size(in,2), 1:size(in,1), 1:size(in,3));
    
    phasey = (yy-size(in,1)/2);
 
    phasey = 2.*pi.*posy.*phasey/size(in,1);   
    
    phasez = (zz-size(in,3)/2);

    phasez = 2.*pi.*posz.*phasez/size(in,3);
    
    phase = exp( complex( 0, phasey + phasez ) );
    
    spect = spect.*phase;
    
    y = abs(ifft2c(spect));
    
    
