function der_mul_inv_r = Get_Derivatives_Multiply_Inv(freq,r_cell,flag)
% flag == 1 中心有限差分法精度更高，但是有延迟 ；flag == 0，普通方法，没有延迟
len_r = length(r_cell);

if nargin<3
    flag = 1;
end
if flag == 1
    
    for i=3:len_r-2
        der_r{i} =( - r_cell{i+2} + 8 * r_cell{i+1} - 8 * r_cell{i-1} + r_cell{i-2})*freq/12;
    end
    der_r{1} = (r_cell{2} - r_cell{1}) * freq;
    der_r{2} = (r_cell{2} - r_cell{1}) * freq;
    der_r{len_r} = (r_cell{end} - r_cell{end-1}) * freq;
    der_r{len_r-1} = (r_cell{end} - r_cell{end-1}) * freq;
elseif flag ==0
    for i=2:len_r
        der_r{i} = (r_cell{i} - r_cell{i-1}) * freq;
    end
    
    der_r{1} = der_r(2);
end

for i=1:len_r
    %Inv_R=inv(r_cell{i+1});
    %der_mul_inv_r{i+1} = der_r * Inv_R;
    der_mul_inv_r{i} = der_r{i} /r_cell{i}; % der_r*inv(r_cell) 
end