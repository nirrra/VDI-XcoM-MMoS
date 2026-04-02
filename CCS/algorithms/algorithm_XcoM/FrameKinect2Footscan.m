% 位于Kinect坐标系的点(x,y)转化到阵列坐标[j,i]
function [pt_img] = FrameKinect2Footscan(pt,transform_plantar2kinect)

    pt_img = struct();
    if isfield(pt,'x')
        pt_img.x = pt.x;
        pt_img.y = pt.y;
    else
        pt_img.x = pt(:,1);
        pt_img.y = pt(:,2);
    end
    
    pt_img.x = (pt_img.x-transform_plantar2kinect(1));
    pt_img.y = -(pt_img.y-transform_plantar2kinect(2));
    
    pt_img.x = pt_img.x*1000/11.5+0.5;
    pt_img.y = pt_img.y*1000/11.5+0.5;