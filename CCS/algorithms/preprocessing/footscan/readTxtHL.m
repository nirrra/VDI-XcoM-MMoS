%% FUNC readTxtHL：读取txt（同时保存原值高8位和低4位）
function [dataAllOri, datetimeArray] = readTxtHL(fileName)
    % 是否错位
    % 嵌入式代码中格式为：0x2A 0x06 0x00 1024高位 uart[1026] 1024低位 0x23
    % QT处理格式为：0x2A 0x06 0x00 1024高位 1024低位 0x23
    % 会导致错位
    % 但根据压力分布图结果，应该是没有错位
    flag_wrong_displacement = false;
    
    dataAllOri = []; datetimeArray = [];
    
    fid = fopen(fileName);
    if fgetl(fid) == -1
        return;
    end
    fid = fopen(fileName);
    while ~feof(fid)
        line = fgetl(fid);
        line = strsplit(line, ',');
        if length(line) == 2049
            aux = [];
            for i = 1:1024
                numH8 = str2num(line{2*i});
                if flag_wrong_displacement
                    if i<1024
                        numL4 = str2num(line{2*i+3});
                    else
                        numL4 = 0;
                    end
                else
                    numL4 = str2num(line{2*i+1});
                end

                aux = [aux, numH8*16+numL4];
            end
            dataAllOri = [dataAllOri; aux];
            aux = datetime(line{1},'InputFormat','yyyy-MM-dd HH:mm:ss:SSS'); 
            aux.Format = 'yyyy-MM-dd HH:mm:ss:SSS';
            datetimeArray = [datetimeArray; aux];
        end
    end
end
