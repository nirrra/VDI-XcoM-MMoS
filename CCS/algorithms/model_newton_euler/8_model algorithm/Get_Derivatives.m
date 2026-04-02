function der_r = Get_Derivatives(freq,r_cell)
len_r = length(r_cell);
der_r{1} = zeros(3,3);
der_r{2} = zeros(3,3);
der_r{len_r} = zeros(3,3);
der_r{len_r-1} = zeros(3,3);
% for i=1:(len_r-1)
%     der_r{i+1} = (r_cell{i+1}-r_cell{i})*freq;
%     
% end

for i=3:len_r-2
der_r{i} =( - r_cell{i+2} + 8 * r_cell{i+1} - 8 * r_cell{i-1} + r_cell{i-2})*freq/12;
end