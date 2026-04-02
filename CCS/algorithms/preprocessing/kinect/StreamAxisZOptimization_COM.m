function [cost] = StreamAxisZOptimization_COM(params,comX,comY)
    rotAngleZ = params; 

    comX = comX(1+100:end-100);
    comY = comY(1+100:end-100);

    comX = comX-mean(comX);
    comY = comY-mean(comY);

    comXRot = cosd(rotAngleZ).*comX+sind(rotAngleZ).*comY;
    comYRot = -sind(rotAngleZ).*comX+cosd(rotAngleZ).*comY;

    cost = 0;

    for i = 1:length(comX)
        cost = cost+comXRot(i);
    end