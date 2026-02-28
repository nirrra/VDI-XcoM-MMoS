function Mas2floorT = Read_Floor(filename)
% kinect视角的前方为z，原始kinect坐标是向下为y，向右是x

%原始数据读取
fileID = fopen(filename);
c = textscan(fileID, '%f %f %f %f', 'delimiter', ',');
fclose(fileID);
cm = zeros(length(c{1}),4);
for i = 1:length(c{1})
    cm(i,1) = c{1}(i);
    cm(i,2) = c{2}(i);
    cm(i,3) = c{3}(i);
    cm(i,4) = c{4}(i);
end

n0 = mean(cm(11:end-10,1:3));
h0 = mean(cm(11:end-10,4));

n1 = [0,0,1];
Mas2floorT = zeros(4,4);
Mas2floorR = vrrotvec2mat(vrrotvec(n0,n1 ));
Mas2floorT(1:3,1:3) = Mas2floorR;
Mas2floorT(3,4) = -h0;
Mas2floorT(4,4) = 1;

end