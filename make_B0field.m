function y = make_B0field(dim)

    L = dim;
    [gx,gy] = meshgrid(1:L(2), 1:L(1));
    
    gx = gx - L(1)/2;
    gy = gy - L(2)/2;
    
    y  = 10*(rand-0.5) * gx/L(1) + 10*(rand-0.5) * gy/L(2) + 10*(rand-0.5) *  gx.*gx/(L(1)*L(1)) + 10*(rand-0.5) *  gy .* gy/(L(1)*L(1)) + 10*(rand-0.5) *  gx .* gy/(L(1)*L(2));
    y = pi * y;


