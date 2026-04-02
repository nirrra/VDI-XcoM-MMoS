function T = Mas2Pathway_T_Read(filename)
fileID = fopen(filename);
c = textscan(fileID, '%f %f %f %f', 'delimiter', ',');
T =zeros(4,4);
for i=1:4
T(:,i) =c{i};
end
T(1,4)= T(1,4)/1000;
T(2,4)= T(2,4)/1000;
T(3,4)= T(3,4)/1000;
fclose(fileID);