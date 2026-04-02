function str = DispArray(arr)
    % 将一维数组转换为字符串
    % 输入:
    %   arr - 一维数组
    % 输出:
    %   str - 字符串格式的数组表示

    % 检查输入是否为一维数组
    if ~isvector(arr)
        error('输入必须是一维数组');
    end

    % 使用 sprintf 函数将数组元素转换为字符串
    str = num2str(arr(1));

    for i = 2:length(arr)
        num = arr(i);
        str = [str,', ',num2str(num)];
    end

    % 添加方括号
    str = ['[' str ']'];
    disp(str);
end