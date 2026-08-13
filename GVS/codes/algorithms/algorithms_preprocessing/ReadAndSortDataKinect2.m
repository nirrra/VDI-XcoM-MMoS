%% 读取Kinect2的OpenSim结果，用于最后比较分析
function [cellData] = ReadAndSortDataKinect2()
    folderPath = '../data/dataSTS2/';
    
    filePath = [folderPath,'KinectMat'];
    dirOutput = dir([filePath,'/*.mat']);
    filenames = {dirOutput.name};
    
    filePath = [folderPath,'GRF2Mat'];
    dirOutput = dir([filePath,'/*.mat']);
    filenames2 = {dirOutput.name};
    if length(filenames) ~= length(filenames2)
        disp('============数据数量不一致！！！=============');
    end
    
    filename_floor = 'floorFileSTS2.txt';
    Mas2floorT = Read_Floor(filename_floor);
    
    cellData = cell(length(filenames),1);
    for i = 1:length(filenames)
        filename = filenames{i};
        filename2 = filenames2{i}(1:6);
        cellTest.idxSub = str2double(filename(1:3));
        cellTest.idxSTS = str2double(filename(4:5));
        cellTest.idxSTSTest = str2double(filename(6:7));
        cellTest.idxTest = str2double(filename2(5:6));
        cellTest.isRight = filename(8)=='r';
        
        cellTest.kinect = KinectMat2Struct(filename,Mas2floorT);
        cellTest.plantar = FootScanMat2Struct([filename(1:7),'p.mat']);
        cellTest.hip = FootScanMat2Struct([filename(1:7),'h.mat']);

        cellTest.grf = ReadDataTable([filename2,'grf2.mat']);
        cellTest.ik = ReadDataTable([filename2,'ik.mat']);
        cellTest.id = ReadDataTable([filename2,'id2.mat']);
        cellTest.analysis = AnalysisMat2Struct(filename2);

        % Predicted tangential GRF used by the Kinect route.  The files are
        % copied into the GVS dataset so this analysis does not depend on an
        % external absolute path.  Missing files are kept explicit and are
        % handled by the agreement-analysis QC table.
        predictionFile = fullfile(folderPath, 'PredictedGRFMat', ...
            [filename(1:7), 'grfP.mat']);
        cellTest.predictionFile = predictionFile;
        cellTest.grfP = GRFPMat2Struct(predictionFile);
        
        cellData{i} = cellTest;
    end

end

% WrenchP的mat转化为struct
function [dataTable] = WrenchPMat2Struct(filename)
    load (filename,'dataTable');
end

% GRFP的mat转化为struct
function [dataTable] = GRFPMat2Struct(filename)
    if exist(filename,'file') == 2
        loaded = load(filename,'dataTable');
        dataTable = loaded.dataTable;
    else
        dataTable = [];
    end
end

% Analyze的mat转化为struct
function [struct] = AnalysisMat2Struct(filename)
    load([filename,'analysis2.mat'],'dataTable'); % 根据COM 有切向力 分析结果，JRL在parent坐标系下
    struct.analysisParent = dataTable;
    load([filename,'analysis4.mat'],'dataTable'); % 根据COM 有切向力 分析结果，JRL在ground坐标系下
    struct.analysisGround = dataTable;
end

function [struct] = AnalysisPMat2Struct(filename)
    load([filename,'analysis_k_parent.mat'],'dataTable'); % 根据COM 有切向力 分析结果，JRL在parent坐标系下
    struct.analysisParent = dataTable;
    load([filename,'analysis_k_ground.mat'],'dataTable'); % 根据COM 有切向力 分析结果，JRL在ground坐标系下
    struct.analysisGround = dataTable;
end

function [dataTable] = ReadDataTable(filename)
    load(filename,'dataTable');
end

% Kinect的mat转化为struct
function [struct] = KinectMat2Struct(fileName,Mas2floorT)
    load(fileName,'streamAllMaster');
    % 是否将kinect转化至地面坐标系（X右，Y前，Z上）
    if true
        for i = 1:length(streamAllMaster)
            streamAllMaster{i} = Transform_Azure(Mas2floorT,streamAllMaster{i});
        end
    end
    struct.master = streamAllMaster;
end

% 阵列的mat转化为struct
function [struct] = FootScanMat2Struct(fileName)
    eval(['load ',fileName]);
    struct.dataAllOri = dataAllOri;
    struct.datetimeF = datetimeF;
    struct.fsF = fsF;
end
