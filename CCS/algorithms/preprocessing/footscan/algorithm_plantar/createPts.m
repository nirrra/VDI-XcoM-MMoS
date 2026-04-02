%% FUNC createPts：获取点集
function [pts] = createPts(img, th)
    imgBi = img; % 二值化图
    imgBi = zeros(size(img));
    imgBi(img>th) = 1;
    % 开操作
    bOpen = ones(2,2); 
    bOpen = [1,1];
    imgBi = imerode(imgBi,bOpen); imgBi = imdilate(imgBi,bOpen);
    
    % 消除噪点,与其他点均不相邻
%     aux = zeros(34,34); aux(2:33,2:33) = imgBi;
%     for i = 1:32
%         for j = 1:32
%             if sum(sum(aux(i:i+2,j:j+2))) == aux(i+1,j+1)
%                 imgBi(i,j) = 0;
%             end
%         end
%     end
    imgBi(1,:)=0;imgBi(32,:)=0;imgBi(:,1)=0;imgBi(:,32)=0; % 确保周围一圈无点
%     figure;imshow(mat2gray(imgBi),'InitialMagnification','fit');title('二值化');
    % 保留一些与足印主体连接的单点，删除一些离群点
    imgBi0 = zeros(32+4,32+4);
    imgBi0(3:34,3:34) = imgBi;    
    for i = 1:32
        for j = 1:32
            if imgBi0(i+2,j+2) == 0  && img(i,j)>th && sum(sum(imgBi0(i:i+4,j:j+4)))>=3
                imgBi(i,j) = 1;
            elseif imgBi0(i+2,j+2) == 1 && sum(sum(imgBi0(i:i+4,j:j+4)))<3
                imgBi(i,j) = 0;
            end
        end
    end
    [pts(:,2),pts(:,1)] = find(imgBi == 1); pts(:,2) = 33-pts(:,2);
end