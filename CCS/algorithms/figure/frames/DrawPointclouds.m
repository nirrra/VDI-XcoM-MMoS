function [f] = DrawPointclouds(pointclouds,idxFrame,idxsDBSCAN)
    points = pointclouds{idxFrame};

    x = points(:,1)./1000;
    y = points(:,2)./1000;
    z = points(:,3)./1000;

    f = figure; 
    view(3);
    if nargin<3
        scatter3(x,y,z,3,'filled'); 
    else
        idxDBSCAN = idxsDBSCAN{idxFrame};
        idxHuman = find(idxDBSCAN==1);
        idxNoise = find(idxDBSCAN~=1);
        scatter3(x(idxHuman),y(idxHuman),z(idxHuman),3,'filled'); 
        hold on;
        scatter3(x(idxNoise),y(idxNoise),z(idxNoise),3,'filled');
        hold off;
    end
    xlabel('x 向右');
    ylabel('y 向前');
    zlabel('z 向上');
    if nargin==3
        legend('Human', 'Noise');
    end
    axis equal;
    grid on;
end