% 单位：米
classdef HumanModel
    properties
        % 身高
        height = 1.73;
        modelHeight = 1.8; % 模型定义的身高，参照OpenSim的FullBody模型
        rHeight = 1;

        % 骨骼结构
        % 全局坐标系：Kinect拍摄人体背面，x正向为右，y正向为前，z正向为上
        segments = struct('trunk',struct('length',0,'parentSegment','root','location',zeros(1,3),'weight',1),... % 全局坐标系以骨盆为原点，局部坐标系参照师兄论文
            'headNeck',struct('length',0,'parentSegment','trunk','location',zeros(1,3),'weight',1),...
            'leftArm',struct('length',0,'parentSegment','trunk','location',zeros(1,3),'weight',1),...
            'rightArm',struct('length',0,'parentSegment','trunk','location',zeros(1,3),'weight',1),...
            'leftForearm',struct('length',0,'parentSegment','leftArm','location',zeros(1,3),'weight',1),...
            'rightForearm',struct('length',0,'parentSegment','rightArm','location',zeros(1,3),'weight',1),...
            'leftThigh',struct('length',0,'parentSegment','trunk','location',zeros(1,3),'weight',1),...
            'rightThigh',struct('length',0,'parentSegment','trunk','location',zeros(1,3),'weight',1),...
            'leftShank',struct('length',0,'parentSegment','leftThigh','location',zeros(1,3),'weight',1),...
            'rightShank',struct('length',0,'parentSegment','rightThigh','location',zeros(1,3),'weight',1));
        
        % 姿态参数 (43维)
        pose = struct('trunkPosition', zeros(1,3), ... % 全局位置 (3维)
                     'headNeck', zeros(1,4), ...
                     'trunk', zeros(1,4), ...    % 根
                     'leftArm', zeros(1,4), ...   
                     'rightArm', zeros(1,4), ...
                     'leftForearm', zeros(1,4), ...  
                     'rightForearm', zeros(1,4), ...
                     'leftThigh', zeros(1,4), ...
                     'rightThigh', zeros(1,4), ...
                     'leftShank', zeros(1,4), ...
                     'rightShank', zeros(1,4));
        
        % SoG模型参数 (228维)
        % [x,y,z,σ^2]，σ^2为方差，设为高斯核的半径的平方
        gaussians = struct(...
            'headNeck', zeros(1,4), ...
            'trunk', zeros(24,4), ...
            'leftArm', zeros(4,4),...
            'rightArm', zeros(4,4), ...
            'leftForearm', zeros(4,4),...
            'rightForearm', zeros(4,4), ...
            'leftThigh', zeros(4,4), ...
            'rightThigh', zeros(4,4), ...
            'leftShank', zeros(4,4), ...
            'rightShank', zeros(4,4));
    end
    
    methods
        function obj = HumanModel(height)
            % 初始化默认姿态和高斯核参数
            obj = setHeight(obj,height);
            obj = initializeDefaultPose(obj);
            obj = initializeDefaultGaussians(obj);
            obj = initializeSegments(obj);
            % 计算体段权重
            obj = calculateSegmentWeights(obj);
        end
        
        function obj = setHeight(obj,height)
            obj.height = height;
            obj.rHeight = obj.height./obj.modelHeight;
            obj.rHeight = obj.rHeight*1000; % m转化为mm
        end

        function obj = initializeDefaultPose(obj)
            % 初始化默认姿态（站立T-pose）
            obj.pose.trunkPosition = [0 0 0];
            % 所有四元数初始化为单位四元数 [1 0 0 0]
            obj.pose.headNeck = [1 0 0 0];
            obj.pose.trunk = [1 0 0 0];
            obj.pose.leftArm = [cosd(90/2) 0 sind(90/2) 0];
            obj.pose.rightArm = [cosd(-90/2) 0 sind(-90/2) 0];
            obj.pose.leftForearm = [1 0 0 0];
            obj.pose.rightForearm = [1 0 0 0];
            obj.pose.leftThigh = [1 0 0 0];
            obj.pose.rightThigh = [1 0 0 0];
            obj.pose.leftShank = [1 0 0 0];
            obj.pose.rightShank = [1 0 0 0];
        end
        
        function obj = initializeDefaultGaussians(obj)
            % 初始化默认高斯核参数，在局部坐标系下的位置
            % 这里需要根据人体比例设置合理的初始值
            % TODO: 添加具体的初始化逻辑
            obj.gaussians.headNeck = [0 0 0 0.1].*obj.rHeight;
            obj.gaussians.trunk = [-0.135 0 0 0.045;
                -0.045 0 0 0.045;
                0.045 0 0 0.045;
                0.135 0 0 0.045;
                -0.135 0 0.09 0.045;
                -0.045 0 0.09 0.045;
                0.045 0 0.09 0.045;
                0.135 0 0.09 0.045;
                -0.135 0 0.18 0.045;
                -0.045 0 0.18 0.045;
                0.045 0 0.18 0.045;
                0.135 0 0.18 0.045;
                -0.135 0 0.27 0.045;
                -0.045 0 0.27 0.045;
                0.045 0 0.27 0.045;
                0.135 0 0.27 0.045;
                -0.135 0 0.36 0.045;
                -0.045 0 0.36 0.045;
                0.045 0 0.36 0.045;
                0.135 0 0.36 0.045;
                -0.135 0 0.45 0.045;
                -0.045 0 0.45 0.045;
                0.045 0 0.45 0.045;
                0.135 0 0.45 0.045;].*obj.rHeight;
            obj.gaussians.leftArm = [0 0 -0.04 0.04;
                0 0 -0.12 0.04;
                0 0 -0.20 0.04;
                0 0 -0.28 0.04].*obj.rHeight;
            obj.gaussians.rightArm = [0 0 -0.04 0.04;
                0 0 -0.12 0.04;
                0 0 -0.20 0.04;
                0 0 -0.28 0.04].*obj.rHeight;
            obj.gaussians.leftForearm = [0 0 -0.045 0.045;
                0 0 -0.135 0.045;
                0 0 -0.225 0.045;
                0 0 -0.315 0.045].*obj.rHeight;
            obj.gaussians.rightForearm = [0 0 -0.045 0.045;
                0 0 -0.135 0.045;
                0 0 -0.225 0.045;
                0 0 -0.315 0.045].*obj.rHeight;
            obj.gaussians.leftThigh = [0 0 -0.055 0.055;
                0 0 -0.165 0.055;
                0 0 -0.275 0.055;
                0 0 -0.385 0.055].*obj.rHeight;
            obj.gaussians.rightThigh = [0 0 -0.055 0.055;
                0 0 -0.165 0.055;
                0 0 -0.275 0.055;
                0 0 -0.385 0.055].*obj.rHeight;
            obj.gaussians.leftShank = [0 0 -0.05 0.05;
                0 0 -0.15 0.05;
                0 0 -0.25 0.05;
                0 0 -0.35 0.05].*obj.rHeight;
            obj.gaussians.rightShank = [0 0 -0.05 0.05;
                0 0 -0.15 0.05;
                0 0 -0.25 0.05;
                0 0 -0.35 0.05].*obj.rHeight;

            % 标准差转换为方差
            names = fieldnames(obj.gaussians);
            for i = 1:length(names)
                obj.gaussians.(names{i})(:,4) = obj.gaussians.(names{i})(:,4).^2;
            end
        end

        function obj = initializeSegments(obj)
            obj.segments.trunk.location = [0,0,0].*obj.rHeight;
            obj.segments.headNeck.location = [0,0,0.72].*obj.rHeight;
            obj.segments.leftArm.location = [-0.17,0,0.51].*obj.rHeight;
            obj.segments.rightArm.location = [0.17,0,0.51].*obj.rHeight;
            obj.segments.leftForearm.location = [0,0,-0.29].*obj.rHeight;
            obj.segments.rightForearm.location = [0,0,-0.29].*obj.rHeight;
            obj.segments.leftThigh.location = [-0.12,0,0].*obj.rHeight;
            obj.segments.rightThigh.location = [0.12,0,0].*obj.rHeight;
            obj.segments.leftShank.location = [0.04,0,-0.43].*obj.rHeight;
            obj.segments.rightShank.location = [-0.04,0,-0.43].*obj.rHeight;
        end
        
        function gaussiansGlobal = transformGaussians(obj)
            % 根据姿态参数转换高斯核位置
            % TODO: 实现高斯核位置的转换逻辑
            % 每个高斯核的位置从局部坐标系转换到全局坐标系
            gaussiansGlobal = zeros(57,4);
            aux = RotatePointByQuaternion(obj.gaussians.headNeck(1:3),obj.pose.headNeck);
            gaussiansGlobal(1,:) = [aux+obj.segments.headNeck.location,obj.gaussians.headNeck(4)];

            for i = 1:size(obj.gaussians.trunk,1)
                aux = RotatePointByQuaternion(obj.gaussians.trunk(i,1:3),obj.pose.trunk);
                gaussiansGlobal(1+i,:) = [aux+obj.segments.trunk.location,obj.gaussians.trunk(i,4)];
            end

            for i = 1:size(obj.gaussians.leftArm,1)
                aux = RotatePointByQuaternion(obj.gaussians.leftArm(i,1:3),obj.pose.leftArm);
                gaussiansGlobal(25+i,:) = [aux+obj.segments.leftArm.location,obj.gaussians.leftArm(i,4)];
            end

            for i = 1:size(obj.gaussians.rightArm,1)
                aux = RotatePointByQuaternion(obj.gaussians.rightArm(i,1:3),obj.pose.rightArm);
                gaussiansGlobal(29+i,:) = [aux+obj.segments.rightArm.location,obj.gaussians.rightArm(i,4)];
            end

            for i = 1:size(obj.gaussians.leftForearm,1)
                aux = RotatePointByQuaternion(obj.gaussians.leftForearm(i,1:3),obj.pose.leftForearm);
                aux = RotatePointByQuaternion(aux+obj.segments.leftForearm.location,obj.pose.leftArm);
                gaussiansGlobal(33+i,:) = [aux+obj.segments.leftArm.location,obj.gaussians.leftForearm(i,4)];
            end

            for i = 1:size(obj.gaussians.rightForearm,1)
                aux = RotatePointByQuaternion(obj.gaussians.rightForearm(i,1:3),obj.pose.rightForearm);
                aux = RotatePointByQuaternion(aux+obj.segments.rightForearm.location,obj.pose.rightArm);
                gaussiansGlobal(37+i,:) = [aux+obj.segments.rightArm.location,obj.gaussians.rightForearm(i,4)];
            end

            for i = 1:size(obj.gaussians.leftThigh,1)
                aux = RotatePointByQuaternion(obj.gaussians.leftThigh(i,1:3),obj.pose.leftThigh);
                gaussiansGlobal(41+i,:) = [aux+obj.segments.leftThigh.location,obj.gaussians.leftThigh(i,4)];
            end

            for i = 1:size(obj.gaussians.rightThigh,1)
                aux = RotatePointByQuaternion(obj.gaussians.rightThigh(i,1:3),obj.pose.rightThigh);
                gaussiansGlobal(45+i,:) = [aux+obj.segments.rightThigh.location,obj.gaussians.rightThigh(i,4)];
            end

            for i = 1:size(obj.gaussians.leftShank,1)
                aux = RotatePointByQuaternion(obj.gaussians.leftShank(i,1:3),obj.pose.leftShank);
                aux = RotatePointByQuaternion(aux+obj.segments.leftShank.location,obj.pose.leftThigh);
                gaussiansGlobal(49+i,:) = [aux+obj.segments.leftThigh.location,obj.gaussians.leftShank(i,4)];
            end

            for i = 1:size(obj.gaussians.rightShank,1)
                aux = RotatePointByQuaternion(obj.gaussians.rightShank(i,1:3),obj.pose.rightShank);
                aux = RotatePointByQuaternion(aux+obj.segments.rightShank.location,obj.pose.rightThigh);
                gaussiansGlobal(53+i,:) = [aux+obj.segments.rightThigh.location,obj.gaussians.rightShank(i,4)];
            end

            % 平移
            gaussiansGlobal(:,1:3) = gaussiansGlobal(:,1:3)+obj.pose.trunkPosition;

        end

        % 根据高斯核更新体段权重
        function obj = calculateSegmentWeights(obj)
            n = 3;
            names = fieldnames(obj.segments);
            for idxSeg = 1:length(names)
                name = names{idxSeg};
                w = 0;
                for i = 1:size(obj.gaussians.(name),1)
                    variance = obj.gaussians.(name)(i,4);
                    Sigma = variance * eye(3);
                    w = w+((2*pi)^n/(det(inv(Sigma))))^(0.5);
                end
                obj.segments.(name).w = w;
            end
        end
        
        function error = fitToPointCloud(obj, pointCloud)
            % 将模型拟合到点云数据
            % TODO: 实现拟合逻辑
        end
        
        function [reducedGaussians] = reduceGaussians(obj)
            % 将57个高斯核合并为13个
            % TODO: 实现高斯核合并逻辑
        end
    end
end