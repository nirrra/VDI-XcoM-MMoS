%% OpenSim的2392肌肉力合并到Kinect模型的肌肉力
% 肌肉力
mf_v.hamstrings_l = so.for_bifemlh_l;
mf_v.hamstrings_r = so.for_bifemlh_r;

mf_v.bifemsh_l = so.for_bifemsh_l;
mf_v.bifemsh_r = so.for_bifemsh_r;

mf_v.glut_max_l = so.for_glut_max1_l+so.for_glut_max2_l+so.for_glut_max3_l;
mf_v.glut_max_r = so.for_glut_max1_r+so.for_glut_max2_r+so.for_glut_max3_r;

mf_v.iliopsoas_l = so.for_psoas_l;
mf_v.iliopsoas_r = so.for_psoas_r;

mf_v.rect_fem_l = so.for_rect_fem_l;
mf_v.rect_fem_r = so.for_rect_fem_r;

mf_v.vasti_l = so.for_vas_int_l;
mf_v.vasti_r = so.for_vas_int_r;

mf_v.gastroc_l = so.for_med_gas_l;
mf_v.gastroc_r = so.for_med_gas_r;

mf_v.soleus_l = so.for_soleus_l;
mf_v.soleus_r = so.for_soleus_r;

mf_v.tib_ant_l = so.for_tib_ant_l;
mf_v.tib_ant_r = so.for_tib_ant_r;

mf_v.ercspn_l = so.for_ercspn_l;
mf_v.ercspn_r = so.for_ercspn_r;

mf_v.intobl_l = so.for_intobl_l;
mf_v.intobl_r = so.for_intobl_r;

mf_v.extobl_l = so.for_extobl_l;
mf_v.extobl_r = so.for_extobl_r;

% 肌肉激活
ma_v.hamstrings_l = so.act_bifemlh_l;
ma_v.hamstrings_r = so.act_bifemlh_r;

ma_v.bifemsh_l = so.act_bifemsh_l;
ma_v.bifemsh_r = so.act_bifemsh_r;

ma_v.glut_max_l = so.act_glut_max2_l;
ma_v.glut_max_r = so.act_glut_max2_r;

ma_v.iliopsoas_l = so.act_psoas_l;
ma_v.iliopsoas_r = so.act_psoas_r;

ma_v.rect_fem_l = so.act_rect_fem_l;
ma_v.rect_fem_r = so.act_rect_fem_r;

ma_v.vasti_l = so.act_vas_int_l;
ma_v.vasti_r = so.act_vas_int_r;

ma_v.gastroc_l = so.act_med_gas_l;
ma_v.gastroc_r = so.act_med_gas_r;

ma_v.soleus_l = so.act_soleus_l;
ma_v.soleus_r = so.act_soleus_r;

ma_v.tib_ant_l = so.act_tib_ant_l;
ma_v.tib_ant_r = so.act_tib_ant_r;

ma_v.ercspn_l = so.act_ercspn_l;
ma_v.ercspn_r = so.act_ercspn_r;

ma_v.intobl_l = so.act_intobl_l;
ma_v.intobl_r = so.act_intobl_r;

ma_v.extobl_l = so.act_extobl_l;
ma_v.extobl_r = so.act_extobl_r;