function [y, pos_change_x, pos_change_z] = simulate_breath_sine(in)

dim = size(in);

[xx,yy,zz] = meshgrid(1:size(in,2), 1:size(in,1), 1:size(in,3));

%Make centric order
restp1 = (size(in,1)/2+1):size(in,1);
restp2 = (size(in,1)/2):-1:1;
restp(1:2:size(in,1)) = restp1;
restp(2:2:size(in,1)) = restp2;
 
 
for jj=1:size(in,3)

    %Respiratory Frequency (alpha)
    rHz = 0.1 + 5*rand;
    %Shift along PE direction (delta)
    dPos = 0 + 20*rand;
    %Phase (beta)
    Phase = (pi/4)*rand;
    %ky0
    Start = round(0.5*dim(1));
    
    %Make periodical motion
    Resp_sig = 1:size(in,1);
    Resp_sig = dPos .* sin(-2*pi*rHz*Resp_sig/size(in,1) + Phase);
    Resp_sig((dim(1)-Start-1):end) = 0;
    Resp_sig = circshift(Resp_sig, [0 Start]);
    Resp_sig = reshape(Resp_sig, size(in,1), 1);
    Resp_sig(restp) = Resp_sig;
    
    pos_change_x(:,:,jj) = repmat(Resp_sig, [1 size(in,2)]);


end

%No motion in the center of k-space
xc = (size(in,1)/2 - round(0.1*dim(1))):(size(in,1)/2 + round(0.1*dim(1)));
pos_change_z = 0.0*zz;
pos_change_x(xc,:,:) = 0;


%Add phase error to k-space
y = shift_PE(in(:,:,:), pos_change_x, pos_change_z);



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
    
    