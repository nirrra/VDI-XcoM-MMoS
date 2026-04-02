%% FUNC getPosDueToTemplate：根据模板获取图的特征位置
function [ischialLeft, ischialRight, coccyx] = getPosDueToTemplate(img, hipTemplate)
    aux = conv2(img,rot90(hipTemplate.template,2),'full');
    % figure; imshow(mat2gray(aux),'InitialMagnification','fit'); title('卷积');
    [x,y] = find(aux==max(max(aux)));
    ischialLeft = [x,y]-[1,1]+hipTemplate.ischialLeft-31;
    ischialRight = [x,y]-[1,1]+hipTemplate.ischialRight-31;
    coccyx = [x,y]-[1,1]+hipTemplate.coccyx-31; coccyx(1) = min(32,coccyx(1));
end