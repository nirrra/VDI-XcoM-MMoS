function [T_K,T_P] = T_Read(filename)
% oldfilename = [filepath,'Settings.xaml'];
% newfilename = [filepath,'Settings.txt'];
% try
% movefile(oldfilename,newfilename);
% catch
% end
fileID = fopen(filename,'r');
useless1 =  textscan(fileID, '%[^\n]',1);
useful = textscan(fileID, '%s %s %s', 'delimiter', '<>');
match = repmat('%f', 1, 16);
T_K_cell = textscan(useful{1,3}{3}, match, 'delimiter', '|');
T_P_cell = textscan(useful{1,3}{1}, match, 'delimiter', '|');
T_K = zeros(1,16);
T_P = zeros(1,16);
for i = 1:16
    T_K(i) = T_K_cell{i};
    T_P(i) = T_P_cell{i};
end
T_K = reshape(T_K,[4,4])';
T_P = reshape(T_P,[4,4])';

T_K(1,4)= T_K(1,4)/1000;
T_K(2,4)= T_K(2,4)/1000;
T_K(3,4)= T_K(3,4)/1000;

T_P(1,4)= T_P(1,4)/1000;
T_P(2,4)= T_P(2,4)/1000;
T_P(3,4)= T_P(3,4)/1000;
