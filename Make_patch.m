function [ patch_img, patch_ref, patch_coordx, patch_coordy, patch_coordz, norm_fact, mean_fact ] = Make_patch( in0, ref0, varargin)

    if size(varargin) > 0

        num_phase = varargin{1};
        
    else
        num_phase = 7;
    end
    
    %Patch size for learnig
    patch_size = 48;
    
    z_range = 1:size(in0,3);  
    rand_flag = false;
    
    if ndims(in0) <= 3
       disp('Input dimension must be 4')
       
    end
    
    
        
    in = in0;
    ref = ref0;
    
    for ii=1:size(ref0,3)
       
        sx = round(64*rand)-32;
        sy = round(64*rand)-32;
        
        in(:,:,ii,:) = circshift(in0(:,:,ii,:), [sx sy 0 0]);
        ref(:,:,ii,:) = circshift(ref0(:,:,ii,:), [sx sy 0 0]);
        
    end
    
    patch_img = [];
    patch_ref = [];
    
    patch_coordx = [];
    patch_coordy = [];
    patch_coordz = [];
    
   
    patch_step = round(patch_size*0.5);
    
    
    sl_index = 1;
    
    if z_range(end) > (size(in,3)-1)
        z_range = z_range(1):(size(in,3)-1);
    
    
    elseif rand_flag
        
        z_range = ceil( size(in,3) * rand(1,80) );
        z_range = z_range(:);
        
    end
    
 
    
    if( patch_size == size(in,1))
        
        for kk = z_range


            range_x = 1:patch_size;
            range_y = 1:patch_size;

            patch_img(:,:,sl_index) = in(range_x, range_y,kk);
            patch_ref(:,:,sl_index) = ref(range_x, range_y,kk);

            patch_coordx = [patch_coordx; 1, (1+patch_size-1)];
            patch_coordy = [patch_coordy; 1, (1+patch_size-1)];
            patch_coordz = [patch_coordz; kk];

            sl_index = sl_index + 1;

        end
       
    else
        
        for kk = z_range
            for ii =1:patch_step:(size(in,1)-patch_size)
                for jj = 1:patch_step:(size(in,2)-patch_size)
                    
                    sl_index = sl_index + 1;
        
                end
            end
        end
        
        
        sl_index = sl_index -1;
        num_z = length(z_range);
        
        patch_img = zeros(patch_size, patch_size, sl_index, num_phase);
        patch_ref = zeros(patch_size, patch_size, sl_index, num_phase);
        sl_index = 0;
        
        for ii =1:patch_step:(size(in,1)-patch_size)
            for jj = 1:patch_step:(size(in,2)-patch_size)


                    range_x = ii:(ii+patch_size-1);
                    range_y = jj:(jj+patch_size-1);
                    range_z = (1:num_z) + num_z*sl_index;
                    
                    patch_img(:,:,range_z,:) = (in(range_x, range_y,z_range,:));
                    patch_ref(:,:,range_z,:) = (ref(range_x, range_y,z_range,:));

                    patch_coordx = [patch_coordx; repmat( [ii, (ii+patch_size-1)], [num_z 1])];
                    patch_coordy = [patch_coordy; repmat( [jj, (jj+patch_size-1)], [num_z 1])];
                    patch_coordz = [patch_coordz; range_z' ];

                    sl_index = sl_index + 1;

            end
        end
        
        size(patch_coordx)
        size(patch_coordz)
        
        
    end
    
    disp('cropping done');
    
    th_val = mean(abs(patch_img(:)));
    
    patch_new = [];
    patch_ref_new = []
    sl_index = 1;
    
    px = [];
    py = [];
    pz = [];
    dist = [];
    
    for kk = 1:(size(patch_ref,3))
        temp = ((patch_ref(:,:,kk,:)));
        distribution_flag = abs(mean(temp(:)) - median(temp(:))); 
        dist = [dist distribution_flag];
    end

    
    dist = sort(dist(:));
    dist_index = round(0.50*length(dist));
    
    sl_index_lst = []
    
    patch_new = patch_img;
    patch_ref_new = patch_ref;
    
    for kk = 1:(size(patch_img,3))
       
        temp = abs((patch_img(:,:,kk,:)));
        temp_val = mean(temp(:));
        intensity_flag = temp_val > 0.25*th_val;

        distribution_flag = true;
        
        
        
        if (intensity_flag & distribution_flag)
                       
           
           px = [px; patch_coordx(kk,:)];
           py = [py; patch_coordy(kk,:)];
           pz = [pz; patch_coordz(kk,:)];
           
           sl_index = sl_index + 1;
           
        else
            
            sl_index_lst = [sl_index_lst kk];
            
        end
        
    end
        
    patch_new(:,:,sl_index_lst,:) = [];
    patch_ref_new(:,:,sl_index_lst,:) = [];
    
    patch_coordx = px;
    patch_coordy = py;
    patch_coordz = pz;

    patch_img = patch_new;
    patch_ref = patch_ref_new;
    norm_fact = [];
    mean_fact = [];

    %Calculate max value
    temp = [patch_img(:)];
    temp2 = [patch_ref(:)];
    temp = [temp(:); temp2(:)];
    
    stdval = max(temp(:));
    
    
    %Normalize image
    for kk=1:(size(patch_img,3))
      
        meanval = 0;
        patch_ref(:,:,kk,:) = (patch_ref(:,:,kk,:)- meanval)/stdval;
        patch_img(:,:,kk,:) = (patch_img(:,:,kk,:) - meanval)/stdval;
        
    end
    

    