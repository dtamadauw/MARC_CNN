%Motion artifact simulation
%Tamada, D., Kromrey, M. L., Ichikawa, S., Onishi, H., & Motosugi, U. (2020). Motion artifact reduction using a convolutional neural network for dynamic contrast enhanced MR imaging of the liver. Magnetic Resonance in Medical Sciences, 19(1), 64.

%training_data is MR images without motion arifact from 14 patients
load training_data.mat;

%Image patch with motion artifact
patch_img = cell(1,length(training_data));

%Patch of motion artifact component (residual component)
patch_ref = cell(1,length(training_data));

for ii=1:length(training_data)
    
    %In this study, we used 7-phase imaging  sequence
    num_phase = 7;
    [ image ] = training_data{ii};
    image = rotate_random(image, num_phase);
    
    %Motion artifact simulation
    [y] = simulate_breath_random(image, 0, 0);
    %[y] = simulate_breath_sine(image);
    
    
    y = reshape(y, size(image,1), size(image,2), size(image,3)/num_phase, num_phase);
    image = reshape(image, size(image,1), size(image,2), size(image,3)/num_phase, num_phase);
    %Get residual component
    noise = y - image;
    
    %Crop image to 48*48 for training
    [ patch_img{ii}, patch_ref{ii} ] = Make_patch( y, noise );
    
end


