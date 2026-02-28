%% FUNC createTemplate：构建臀部模板
function [hipTemplate] = createTemplate(height)
    template = zeros(32,32); 
    d = floor(ceil(height/16)/2)*2;
    h = round(d/2);
    r1 = 7; r2 = 3; r3 = r1+4;
    w = 2; % 惩罚区宽度
    ischialLeft = [20,16-d/2]; ischialRight = [ischialLeft(1),16+d/2];
    coccyx = [ischialLeft(1)+h,16];
    % 低奖赏区
    for i = ischialLeft(1)-r1:ischialLeft(1)
        for j = ischialLeft(2)-r1:ischialRight(2)+r1
            template(i,j) = 1;
        end
    end
    for i = ischialLeft(1)+1:32
        for j = 1:32
            if norm([i-ischialLeft(1),j-ischialLeft(2)])<=r1 || norm([i-ischialRight(1),j-ischialRight(2)])<=r1
                template(i,j) = 1;
            end
        end
    end
    % 高奖赏区
    for i = 1:32
        for j = 1:32
            if norm([i-ischialLeft(1),j-ischialLeft(2)])<=r2 || norm([i-ischialRight(1),j-ischialRight(2)])<=r2 ...
                    || norm([i-coccyx(1),j-coccyx(2)])<=r2
                template(i,j) = 3;
            end
        end
    end
    % 惩罚区
    for i = ischialLeft(1)+1:32
        for j = 1:ischialLeft(2)
            if norm([i-ischialLeft(1),j-ischialLeft(2)])<=r3 && norm([i-ischialLeft(1),j-ischialLeft(2)])>r3-w
                template(i,j) = -1;
            end
        end
        for j = ischialLeft(2)+1:ischialRight(2)-1
            if i-ischialLeft(1) <=r3 && i-ischialLeft(1)>r3-w
                template(i,j) = -1;
            end
        end
        for j = ischialRight(2):32
            if norm([i-ischialRight(1),j-ischialRight(2)])<=r3 && norm([i-ischialRight(1),j-ischialRight(2)])>r3-w
                template(i,j) = -1;
            end
        end
    end
    hipTemplate.template = template;
    hipTemplate.ischialLeft = ischialLeft;
    hipTemplate.ischialRight = ischialRight;
    hipTemplate.coccyx = coccyx;
end