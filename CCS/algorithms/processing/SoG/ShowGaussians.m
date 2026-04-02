function [] = ShowGaussians(pts,scale_factor)
    if nargin<2, scale_factor = 1; end
    x = pts(:,1);
    y = pts(:,2);
    z = pts(:,3);
    sigma = sqrt(pts(:,4));

    radii = sigma*scale_factor;

    figure;
    scatter3(x,y,z,radii,'filled');
    axis equal;
    grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
end