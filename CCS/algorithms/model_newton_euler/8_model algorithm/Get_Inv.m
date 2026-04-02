function inv_r = Get_Inv(r_cell)
len_r = length(r_cell);
for i=1:len_r
    inv_r{i}=inv(r_cell{i});
end
