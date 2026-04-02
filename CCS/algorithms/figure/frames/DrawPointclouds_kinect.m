function [] = DrawPointclouds_kinect(pointclouds,stream,idxFrame,idxsDBSCAN)
    points = pointclouds{idxFrame};

    x = points(:,1)./1000;
    y = points(:,2)./1000;
    z = points(:,3)./1000;

    figure; view(3);
    if nargin<4
        scatter3(x,y,z,3,'filled'); 
        hold on;
    else
        idxHuman = idxsDBSCAN(idxsDBSCAN==1);
        idxNoise = idxsDBSCAN(idxsDBSCAN~=1);
        scatter3(x(idxHuman),y(idxHuman),z(idxHuman),3,'filled'); 
        hold on;
        scatter3(x(idxNoise),y(idxNoise),z(idxNoise),3,'filled');
    end
    plot3(stream.HEAD.x(idxFrame),stream.HEAD.y(idxFrame),stream.HEAD.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.NECK.x(idxFrame),stream.NECK.y(idxFrame),stream.NECK.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.PELVIS.x(idxFrame),stream.PELVIS.y(idxFrame),stream.PELVIS.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.SPINE_NAVAL.x(idxFrame),stream.SPINE_NAVAL.y(idxFrame),stream.SPINE_NAVAL.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.SPINE_CHEST.x(idxFrame),stream.SPINE_CHEST.y(idxFrame),stream.SPINE_CHEST.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.CLAVICLE_LEFT.x(idxFrame),stream.CLAVICLE_LEFT.y(idxFrame),stream.CLAVICLE_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.SHOULDER_LEFT.x(idxFrame),stream.SHOULDER_LEFT.y(idxFrame),stream.SHOULDER_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.ELBOW_LEFT.x(idxFrame),stream.ELBOW_LEFT.y(idxFrame),stream.ELBOW_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.HIP_LEFT.x(idxFrame),stream.HIP_LEFT.y(idxFrame),stream.HIP_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.KNEE_LEFT.x(idxFrame),stream.KNEE_LEFT.y(idxFrame),stream.KNEE_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.ANKLE_LEFT.x(idxFrame),stream.ANKLE_LEFT.y(idxFrame),stream.ANKLE_LEFT.z(idxFrame),'r*','MarkerSize',10);
    plot3(stream.FOOT_LEFT.x(idxFrame),stream.FOOT_LEFT.y(idxFrame),stream.FOOT_LEFT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.CLAVICLE_RIGHT.x(idxFrame),stream.CLAVICLE_RIGHT.y(idxFrame),stream.CLAVICLE_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.SHOULDER_RIGHT.x(idxFrame),stream.SHOULDER_RIGHT.y(idxFrame),stream.SHOULDER_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.ELBOW_RIGHT.x(idxFrame),stream.ELBOW_RIGHT.y(idxFrame),stream.ELBOW_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.HIP_RIGHT.x(idxFrame),stream.HIP_RIGHT.y(idxFrame),stream.HIP_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.KNEE_RIGHT.x(idxFrame),stream.KNEE_RIGHT.y(idxFrame),stream.KNEE_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.ANKLE_RIGHT.x(idxFrame),stream.ANKLE_RIGHT.y(idxFrame),stream.ANKLE_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    plot3(stream.FOOT_RIGHT.x(idxFrame),stream.FOOT_RIGHT.y(idxFrame),stream.FOOT_RIGHT.z(idxFrame),'r*','MarkerSize',10); 
    xlabel('x 向右');
    ylabel('y 向前');
    zlabel('z 向上');
    if nargin==4
        legend('Human', 'Noise');
    end 
    axis equal;
    grid on;
end