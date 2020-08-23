function temp = rotate_random(x, num_phase)

    L = size(x);
    temp = reshape(x,L(1),L(2),L(3)/num_phase,num_phase);
    
    parfor ii=1:L(3)/num_phase
        
        ang_rand = 5*(rand-0.5);
        for jj = 1:num_phase
            
            temp(:,:,ii,jj) = imrotate(temp(:,:,ii,jj), ang_rand, 'bilinear', 'crop');
            
        end
    end
    
    temp = reshape(temp,L(1),L(2),L(3));
    