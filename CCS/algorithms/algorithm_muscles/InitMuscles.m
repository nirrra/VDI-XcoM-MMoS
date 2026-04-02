%% 确定肌肉与人体模型连接点位置
% 足部：原点为ANKLE，Y轴：ANKLE→FOOT
% 小腿：原点为ANKLE，Z轴：ANKLE→KNEE
% 大腿：原点为KNEE，Z轴：KNEE→HIP
% 骨盆，原点为Pelvis，X轴：HIP_LEFT→HIP_RIGHT；Z轴：mean(HIP_LEFT,HIP_RIGHT)→PELVIS
% 躯干，原点为SPINE_NAVAL，Z轴：SPINE_NAVAL→SPINE_CHEST
% 头颈：原点为NECK，Z轴：NECK→HEAD

% 髋关节角范围：-40-80°
% 膝关节角范围：-100-0°
% 踝关节角范围：-10-25°
% 腰椎关节角范围：-65-55°
function muscles = InitMuscles()

muscles = struct();

%% 腘绳肌
hamstrings_l = struct();
hamstrings_l.geometry = {};
hamstrings_l.geometry{1}.location = [-0.4542   -0.13   -0.7];
hamstrings_l.geometry{1}.frame = 'Pelvis';
hamstrings_l.geometry{2}.location = [-0.0354    -0.03    0.9092];
hamstrings_l.geometry{2}.frame = 'Shank_Left';
hamstrings_l.geometry{3}.location = [-0.0568    0    0.8672];
hamstrings_l.geometry{3}.frame = 'Shank_Left';

hamstrings_l.max_isometric_force = 2700;
hamstrings_l.optimal_fiber_length = 0.109;
hamstrings_l.tendon_slack_length = 0.326;
hamstrings_l.pennation_angle = 0;
hamstrings_l.max_contraction_velocity = 10;

% knee
hamstrings_l.mtp_length_range = [0.37, 0.42];
hamstrings_l.fiber_length_range = [0.048, 0.08];
hamstrings_l.tendon_length_range = [0.32, 0.34];

muscles.hamstrings_l = hamstrings_l;

%% 股二头肌
bifemsh_l = struct();
bifemsh_l.geometry = {};
bifemsh_l.geometry{1}.location = [-0.03,0.0305,0.3832];
bifemsh_l.geometry{1}.frame = 'Thigh_Left';
bifemsh_l.geometry{2} = hamstrings_l.geometry{2}; 
bifemsh_l.geometry{3} = hamstrings_l.geometry{3}; 

bifemsh_l.max_isometric_force = 804;
bifemsh_l.optimal_fiber_length = 0.173;
bifemsh_l.tendon_slack_length = 0.089;
bifemsh_l.pennation_angle = 0.40142573;
bifemsh_l.max_contraction_velocity = 10;

% knee
bifemsh_l.mtp_length_range = [0.195, 0.246];
bifemsh_l.fiber_length_range = [0.123, 0.167];
bifemsh_l.tendon_length_range = [0.092, 0.093];

muscles.bifemsh_l = bifemsh_l;

%% 臀大肌
glut_max_l = struct();
glut_max_l.geometry = {};
glut_max_l.geometry{1}.location = [-0.3779,-0.2947,-0.0726];
glut_max_l.geometry{1}.frame = 'Pelvis';
glut_max_l.geometry{2}.location = [-0.57,-0.2058,-0.4];
glut_max_l.geometry{2}.frame = 'Pelvis';
glut_max_l.geometry{3}.location = [-0.05,-0.08,0.7004];
glut_max_l.geometry{3}.frame = 'Thigh_Left';
glut_max_l.geometry{4}.location = [-0.076,-0.0155,0.6043];
glut_max_l.geometry{4}.frame = 'Thigh_Left';

glut_max_l.max_isometric_force = 1944;
glut_max_l.optimal_fiber_length = 0.147;
glut_max_l.tendon_slack_length = 0.127;
glut_max_l.pennation_angle = 0;
glut_max_l.max_contraction_velocity = 10;

% hip
glut_max_l.mtp_length_range = [0.17, 0.266];
glut_max_l.fiber_length_range = [0.065, 0.133];
glut_max_l.tendon_length_range = [0.103, 0.133];

muscles.glut_max_l = glut_max_l;

%% 髂腰肌
iliopsoas_l = struct();
iliopsoas_l.geometry = {};
iliopsoas_l.geometry{1}.location = [-0.16,0.16,0.42];
iliopsoas_l.geometry{1}.frame = 'Pelvis';
iliopsoas_l.geometry{2}.location = [-0.52,0.5,-0.4400];
iliopsoas_l.geometry{2}.frame = 'Pelvis';
iliopsoas_l.geometry{3}.location = [-0.56,0.46,-0.54];
iliopsoas_l.geometry{3}.frame = 'Pelvis';
iliopsoas_l.geometry{4}.location = [0.0187,0.0240,0.7097];
iliopsoas_l.geometry{4}.frame = 'Thigh_Left';
iliopsoas_l.geometry{5}.location = [0.0067,-0.0160,0.6919];
iliopsoas_l.geometry{5}.frame = 'Thigh_Left';

iliopsoas_l.max_isometric_force = 2342.0;
iliopsoas_l.optimal_fiber_length = 0.1;
iliopsoas_l.tendon_slack_length = 0.16;
iliopsoas_l.pennation_angle = 0.13962634;
iliopsoas_l.max_contraction_velocity = 10;

% hip
iliopsoas_l.mtp_length_range = [0.203, 0.284];
iliopsoas_l.fiber_length_range = [0.044, 0.118];
iliopsoas_l.tendon_length_range = [0.159, 0.167];

muscles.iliopsoas_l = iliopsoas_l;

%% 股直肌
rect_fem_l = struct();
rect_fem_l.geometry = {};
rect_fem_l.geometry{1}.location = [-0.67    0.45   0];
rect_fem_l.geometry{1}.frame = 'Pelvis';
rect_fem_l.geometry{2}.location = [0.0284    0.1    0.0493];
rect_fem_l.geometry{2}.frame = 'Thigh_Left';
rect_fem_l.geometry{3}.location = [0.0180,0.08,1.0447];
rect_fem_l.geometry{3}.frame = 'Shank_Left';

rect_fem_l.max_isometric_force = 1169.0;
rect_fem_l.optimal_fiber_length = 0.114;
rect_fem_l.tendon_slack_length = 0.31;
rect_fem_l.pennation_angle = 0.08726646;
rect_fem_l.max_contraction_velocity = 10;

% hip
rect_fem_l.mtp_length_range = [0.34, 0.431];
rect_fem_l.fiber_length_range = [0.051, 0.106];
rect_fem_l.tendon_length_range = [0.29, 0.325];

muscles.rect_fem_l = rect_fem_l;

%% 股外侧肌
vasti_l = struct();
vasti_l.geometry = {};
vasti_l.geometry{1}.location = [-0.05,0.0806,0.4204];
vasti_l.geometry{1}.frame = 'Thigh_Left';
vasti_l.geometry{2}.location = [-0.045,0.0884,0.3868];
vasti_l.geometry{2}.frame = 'Thigh_Left';
vasti_l.geometry{3} = rect_fem_l.geometry{2};
vasti_l.geometry{4} = rect_fem_l.geometry{3};

vasti_l.max_isometric_force = 5000.0;
vasti_l.optimal_fiber_length = 0.087;
vasti_l.tendon_slack_length = 0.136;
vasti_l.pennation_angle = 0.05235988;
vasti_l.max_contraction_velocity = 10;

% knee
vasti_l.mtp_length_range = [0.182, 0.249];
vasti_l.fiber_length_range = [0.044, 0.107];
vasti_l.tendon_length_range = [0.138, 0.143];

muscles.vasti_l = vasti_l;

%% 腓肠肌
gastroc_l = struct();
gastroc_l.geometry = {};
gastroc_l.geometry{1}.location = [0.0749,0.0583,1.0146];
gastroc_l.geometry{1}.frame = 'Shank_Left';
gastroc_l.geometry{2}.location = [0.0801,0.0277,0.9808];
gastroc_l.geometry{2}.frame = 'Shank_Left';
gastroc_l.geometry{3}.location = [0.0368,-0.0696,-0.1021];
gastroc_l.geometry{3}.frame = 'Foot_Left';

gastroc_l.max_isometric_force = 2500.0;
gastroc_l.optimal_fiber_length = 0.06;
gastroc_l.tendon_slack_length = 0.39;
gastroc_l.pennation_angle = 0.29670597;
gastroc_l.max_contraction_velocity = 10;

% ankle
gastroc_l.mtp_length_range = [0.442, 0.471];
gastroc_l.fiber_length_range = [0.041, 0.063];
gastroc_l.tendon_length_range = [0.405, 0.409];

muscles.gastroc_l = gastroc_l;

%% 比目鱼肌
soleus_l = struct();
soleus_l.geometry = {};
soleus_l.geometry{1}.location = [0.0046,0.05,0.6553];
soleus_l.geometry{1}.frame = 'Shank_Left';
soleus_l.geometry{2} = gastroc_l.geometry{3};

soleus_l.max_isometric_force = 5137.0;
soleus_l.optimal_fiber_length = 0.05;
soleus_l.tendon_slack_length = 0.25;
soleus_l.pennation_angle = 0.43633231;
soleus_l.max_contraction_velocity = 10;

% ankle
soleus_l.mtp_length_range = [0.283, 0.309];
soleus_l.fiber_length_range = [0.033, 0.053];
soleus_l.tendon_length_range = [0.258, 0.262];

muscles.soleus_l = soleus_l;

%% 胫骨前肌
tib_ant_l = struct();
tib_ant_l.geometry = {};
tib_ant_l.geometry{1}.location = [-0.0074,0.1281,0.6298];
tib_ant_l.geometry{1}.frame = 'Shank_Left';
tib_ant_l.geometry{2}.location = [0,0.16,0.08];
tib_ant_l.geometry{2}.frame = 'Shank_Left';
tib_ant_l.geometry{3}.location = [0.05,0.6522,0.1];
tib_ant_l.geometry{3}.frame = 'Foot_Left';

tib_ant_l.max_isometric_force = 3000.0;
tib_ant_l.optimal_fiber_length = 0.098;
tib_ant_l.tendon_slack_length = 0.223;
tib_ant_l.pennation_angle = 0.08726646;
tib_ant_l.max_contraction_velocity = 10;

% ankle
tib_ant_l.mtp_length_range = [0.283, 0.312];
tib_ant_l.fiber_length_range = [0.056, 0.079];
tib_ant_l.tendon_length_range = [0.228, 0.233];

muscles.tib_ant_l = tib_ant_l;

%% 竖脊肌
ercspn_l = struct();
ercspn_l.geometry = {};
ercspn_l.geometry{1}.location = [-0.2897   -0.3232    0.0426];
ercspn_l.geometry{1}.frame = 'Pelvis';
ercspn_l.geometry{2}.location = [-0.1857   -0.4379    0.02];
ercspn_l.geometry{2}.frame = 'Trunk';

ercspn_l.max_isometric_force = 2500.0;
ercspn_l.optimal_fiber_length = 0.12;
ercspn_l.tendon_slack_length = 0.03;
ercspn_l.pennation_angle = 0.0;
ercspn_l.max_contraction_velocity = 10;

% lumbar
ercspn_l.mtp_length_range = [0.101, 0.178];
ercspn_l.fiber_length_range = [0.07, 0.147];
ercspn_l.tendon_length_range = [0.031, 0.031];

muscles.ercspn_l = ercspn_l;

%% 腹外斜肌
extobl_l = struct();
extobl_l.geometry = {};
extobl_l.geometry{1}.location = [-0.0555    0.3977   -0.6483];
extobl_l.geometry{1}.frame = 'Pelvis';
extobl_l.geometry{2}.location = [-0.84    0.5174    0.0143];
extobl_l.geometry{2}.frame = 'Trunk';

extobl_l.max_isometric_force = 900.0;
extobl_l.optimal_fiber_length = 0.12;
extobl_l.tendon_slack_length = 0.14;
extobl_l.pennation_angle = 0.0;
extobl_l.max_contraction_velocity = 10;

% lumbar
extobl_l.mtp_length_range = [0.175, 0.305];
extobl_l.fiber_length_range = [0.033, 0.161];
extobl_l.tendon_length_range = [0.143, 0.144];

muscles.extobl_l = extobl_l;

%% 腹内斜肌
intobl_l = struct();
intobl_l.geometry = {};
intobl_l.geometry{1}.location = [-0.7600    0.3309    0.2502];
intobl_l.geometry{1}.frame = 'Pelvis';
intobl_l.geometry{2}.location = [-0.1103    0.5552    0.3991];
intobl_l.geometry{2}.frame = 'Trunk';

intobl_l.max_isometric_force = 900.0;
intobl_l.optimal_fiber_length = 0.1;
intobl_l.tendon_slack_length = 0.1;
intobl_l.pennation_angle = 0;
intobl_l.max_contraction_velocity = 10;

% lumbar
intobl_l.mtp_length_range = [0.153, 0.243];
intobl_l.fiber_length_range = [0.050, 0.139];
intobl_l.tendon_length_range = [0.103, 0.103];

muscles.intobl_l = intobl_l;

%% 右侧对称
names = fieldnames(muscles);
for i = 1:length(names)
    nameL = names{i};
    nameR = strrep(nameL,'_l','_r');
    muscles.(nameR) = muscles.(nameL);
    for j = 1:length(muscles.(nameL).geometry)
        muscles.(nameR).geometry{j}.location(1) = -muscles.(nameR).geometry{j}.location(1);
        muscles.(nameR).geometry{j}.frame = strrep(muscles.(nameR).geometry{j}.frame,'Left','Right');
    end
end

%% 计算体段坐标系比例
% a=([-0.0304721 1.19406 -0.0139477]-[-0.1007 1.14358 0])./norm([-0.1107 1.26967 0]-[-0.1007 1.14358 0]); a=a([3,1,2]) % Trunk
% a=([-0.0397096 1.02003 -0.115519]-[-0.09 0.982 0])./norm([-0.093 0.975 -0.076]-[-0.093 0.975 0.076]); a=a([3,1,2]) % Pelvis
% a=([-0.0216935 0.511005 -0.083247]-[-0.0807 0.4869 -0.0971184])./norm([-0.093 0.975 -0.076]-[-0.0807 0.4869 -0.0971184]); a=a([3,1,2]) % Thigh
% a=([-0.0657999 0.674157 -0.106477]-[-0.113089 0.0597783 -0.0923325])./norm([-0.0807 0.4869 -0.0971184]-[-0.113089 0.0597783 -0.0923325]); a=a([3,1,2]) % Shank
% a=([-0.124448 0.043121 -0.0863329]-[-0.113089 0.0597783 -0.0923325])./norm([0.0425992 0.011939 -0.102572]-[-0.113089 0.0597783 -0.0923325]); a=a([3,1,2]) % Foot
