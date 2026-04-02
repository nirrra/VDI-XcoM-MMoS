function sub2masT = ReadSub2Mas(filename)
fid = fopen(filename);
c = textscan(fid, '%s', 'delimiter', ',');
c = c{1,1};
c{1} = c{1}(2:end);
c{4} = c{4}(1:end-1);
c{8} = c{8}(1:end-1);
c{12} = c{12}(1:end-1);
c{16} = c{16}(1:end-1);

sub2masT = zeros(4,4);
for i = 1:4
    for j = 1:4
        sub2masT(i,j) = str2double(c{4*(i-1)+j});
    end
end