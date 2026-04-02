function Alfa_cell = Get_Angular_Acceleration(freq,W_cell,flag)
len_W = length(W_cell);

if nargin<3
    flag = 1;
end
if flag == 1
    
    for i=3:len_W-2
        Alfa_cell{i} =( - W_cell{i+2} + 8 * W_cell{i+1} - 8 * W_cell{i-1} + W_cell{i-2})*freq/12;
    end
    Alfa_cell{1} = (W_cell{2} - W_cell{1}) * freq;
    Alfa_cell{2} = (W_cell{2} - W_cell{1}) * freq;
    Alfa_cell{len_W} = (W_cell{end} - W_cell{end-1}) * freq;
    Alfa_cell{len_W-1} = (W_cell{end} - W_cell{end-1}) * freq;
elseif flag == 0
    for i=2:len_W
        Alfa_cell{i} = (W_cell{i} - W_cell{i-1}) * freq;
    end
    
    Alfa_cell{1} = Alfa_cell(2);
end