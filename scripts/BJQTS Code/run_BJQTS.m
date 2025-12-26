load data_SP500.mat	
load data_COIL.mat	
load data_IBM.mat	

alpha_minus = linspace(0, 0.5, 5);
alpha_plus  = linspace(0, 0.5, 5);

burnin      = 10000;
numberofits = 2000;
every       = 5;
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                                5
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1: BJSAV
% [holdbeta_minus_BJSAV_5_norm_SP500_pred, holdbeta_plus_BJSAV_5_norm_SP500_pred, holdq_minus_BJSAV_5_norm_SP500_pred, holdq_plus_BJSAV_5_norm_SP500_pred, holdtheta_minus_BJSAV_5_norm_SP500_pred, holdtheta_plus_BJSAV_5_norm_SP500_pred, holdtheta_minus1_BJSAV_5_norm_SP500_pred, holdtheta_plus1_BJSAV_5_norm_SP500_pred, holdmu_BJSAV_5_norm_SP500_pred, holdsigvar_BJSAV_5_norm_SP500_pred, holdloglike_BJSAV_5_norm_SP500_pred, holdpredpdf_BJSAV_5_norm_SP500, accept_BJSAV_5_norm_SP500_pred, aveJD_BJSAV_5_norm_SP500_pred, TIME_BJSAV_5_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
% save BJSAV_5_norm_SP500_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSAV_5_norm_IBM_pred, holdbeta_plus_BJSAV_5_norm_IBM_pred, holdq_minus_BJSAV_5_norm_IBM_pred, holdq_plus_BJSAV_5_norm_IBM_pred, holdtheta_minus_BJSAV_5_norm_IBM_pred, holdtheta_plus_BJSAV_5_norm_IBM_pred, holdtheta_minus1_BJSAV_5_norm_IBM_pred, holdtheta_plus1_BJSAV_5_norm_IBM_pred, holdmu_BJSAV_5_norm_IBM_pred, holdsigvar_BJSAV_5_norm_IBM_pred, holdloglike_BJSAV_5_norm_IBM_pred, holdpredpdf_BJSAV_5_norm_IBM, accept_BJSAV_5_norm_IBM_pred, aveJD_BJSAV_5_norm_IBM_pred, TIME_BJSAV_5_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
% save BJSAV_5_norm_IBM_pred.mat -v7.3 
% 
[holdbeta_minus_BJSAV_5_norm_COIL_pred, holdbeta_plus_BJSAV_5_norm_COIL_pred, holdq_minus_BJSAV_5_norm_COIL_pred, holdq_plus_BJSAV_5_norm_COIL_pred, holdtheta_minus_BJSAV_5_norm_COIL_pred, holdtheta_plus_BJSAV_5_norm_COIL_pred, holdtheta_minus1_BJSAV_5_norm_COIL_pred, holdtheta_plus1_BJSAV_5_norm_COIL_pred, holdmu_BJSAV_5_norm_COIL_pred, holdsigvar_BJSAV_5_norm_COIL_pred, holdloglike_BJSAV_5_norm_COIL_pred, holdpredpdf_BJSAV_5_norm_COIL, accept_BJSAV_5_norm_COIL_pred, aveJD_BJSAV_5_norm_COIL_pred, TIME_BJSAV_5_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
save BJSAV_5_norm_COIL_pred.mat -v7.3 
% %%%%%
% %2: BJSSV
%  [holdbeta_minus_BJSSV_5_norm_SP500_pred, holdbeta_plus_BJSSV_5_norm_SP500_pred, holdq_minus_BJSSV_5_norm_SP500_pred, holdq_plus_BJSSV_5_norm_SP500_pred, holdtheta_minus_BJSSV_5_norm_SP500_pred, holdtheta_plus_BJSSV_5_norm_SP500_pred, holdtheta_minus1_BJSSV_5_norm_SP500_pred, holdtheta_plus1_BJSSV_5_norm_SP500_pred, holdmu_BJSSV_5_norm_SP500_pred, holdsigvar_BJSSV_5_norm_SP500_pred, holdloglike_BJSSV_5_norm_SP500_pred, holdpredpdf_BJSSV_5_norm_SP500, accept_BJSSV_5_norm_SP500_pred, aveJD_BJSSV_5_norm_SP500_pred, TIME_BJSSV_5_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
%  save BJSSV_5_norm_SP500_pred.mat -v7.3 
% 
%  [holdbeta_minus_BJSSV_5_norm_IBM_pred, holdbeta_plus_BJSSV_5_norm_IBM_pred, holdq_minus_BJSSV_5_norm_IBM_pred, holdq_plus_BJSSV_5_norm_IBM_pred, holdtheta_minus_BJSSV_5_norm_IBM_pred, holdtheta_plus_BJSSV_5_norm_IBM_pred, holdtheta_minus1_BJSSV_5_norm_IBM_pred, holdtheta_plus1_BJSSV_5_norm_IBM_pred, holdmu_BJSSV_5_norm_IBM_pred, holdsigvar_BJSSV_5_norm_IBM_pred, holdloglike_BJSSV_5_norm_IBM_pred, holdpredpdf_BJSSV_5_norm_IBM, accept_BJSSV_5_norm_IBM_pred, aveJD_BJSSV_5_norm_IBM_pred, TIME_BJSSV_5_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
%  save BJSSV_5_norm_IBM_pred.mat -v7.3 
% 
%  [holdbeta_minus_BJSSV_5_norm_COIL_pred, holdbeta_plus_BJSSV_5_norm_COIL_pred, holdq_minus_BJSSV_5_norm_COIL_pred, holdq_plus_BJSSV_5_norm_COIL_pred, holdtheta_minus_BJSSV_5_norm_COIL_pred, holdtheta_plus_BJSSV_5_norm_COIL_pred, holdtheta_minus1_BJSSV_5_norm_COIL_pred, holdtheta_plus1_BJSSV_5_norm_COIL_pred, holdmu_BJSSV_5_norm_COIL_pred, holdsigvar_BJSSV_5_norm_COIL_pred, holdloglike_BJSSV_5_norm_COIL_pred, holdpredpdf_BJSSV_5_norm_COIL, accept_BJSSV_5_norm_COIL_pred, aveJD_BJSSV_5_norm_COIL_pred, TIME_BJSSV_5_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
%  save BJSSV_5_norm_COIL_pred.mat -v7.3 
%%%%%
% % %3: BJGJR
%  [holdbeta_minus_BJGJR_5_norm_COIL_pred, holdbeta_plus_BJGJR_5_norm_COIL_pred, holdq_minus_BJGJR_5_norm_COIL_pred, holdq_plus_BJGJR_5_norm_COIL_pred, holdtheta_minus_BJGJR_5_norm_COIL_pred, holdtheta_plus_BJGJR_5_norm_COIL_pred, holdtheta_minus1_BJGJR_5_norm_COIL_pred, holdtheta_plus1_BJGJR_5_norm_COIL_pred, holdmu_BJGJR_5_norm_COIL_pred, holdsigvar_BJGJR_5_norm_COIL_pred, holdloglike_BJGJR_5_norm_COIL_pred, holdpredpdf_BJGJR_5_norm_COIL, accept_BJGJR_5_norm_COIL_pred, aveJD_BJGJR_5_norm_COIL_pred, TIME_BJGJR_5_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
%  save BJGJR_5_norm_COIL_pred.mat -v7.3

%  [holdbeta_minus_BJGJR_5_norm_IBM_pred, holdbeta_plus_BJGJR_5_norm_IBM_pred, holdq_minus_BJGJR_5_norm_IBM_pred, holdq_plus_BJGJR_5_norm_IBM_pred, holdtheta_minus_BJGJR_5_norm_IBM_pred, holdtheta_plus_BJGJR_5_norm_IBM_pred, holdtheta_minus1_BJGJR_5_norm_IBM_pred, holdtheta_plus1_BJGJR_5_norm_IBM_pred, holdmu_BJGJR_5_norm_IBM_pred, holdsigvar_BJGJR_5_norm_IBM_pred, holdloglike_BJGJR_5_norm_IBM_pred, holdpredpdf_BJGJR_5_norm_IBM, accept_BJGJR_5_norm_IBM_pred, aveJD_BJGJR_5_norm_IBM_pred, TIME_BJGJR_5_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
%  save BJGJR_5_norm_IBM_pred.mat -v7.3 
% 
% [holdbeta_minus_BJGJR_5_norm_SP500_pred, holdbeta_plus_BJGJR_5_norm_SP500_pred, holdq_minus_BJGJR_5_norm_SP500_pred, holdq_plus_BJGJR_5_norm_SP500_pred, holdtheta_minus_BJGJR_5_norm_SP500_pred, holdtheta_plus_BJGJR_5_norm_SP500_pred, holdtheta_minus1_BJGJR_5_norm_SP500_pred, holdtheta_plus1_BJGJR_5_norm_SP500_pred, holdmu_BJGJR_5_norm_SP500_pred, holdsigvar_BJGJR_5_norm_SP500_pred, holdloglike_BJGJR_5_norm_SP500_pred, holdpredpdf_BJGJR_5_norm_SP500, accept_BJGJR_5_norm_SP500_pred, aveJD_BJGJR_5_norm_SP500_pred, TIME_BJGJR_5_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
% save BJGJR_5_norm_SP500_pred.mat -v7.3 
%%%%%
%4: BJSAVL
%  [holdbeta_minus_BJSAVL_5_norm_COIL_pred, holdbeta_plus_BJSAVL_5_norm_COIL_pred, holdq_minus_BJSAVL_5_norm_COIL_pred, holdq_plus_BJSAVL_5_norm_COIL_pred, holdtheta_minus_BJSAVL_5_norm_COIL_pred, holdtheta_plus_BJSAVL_5_norm_COIL_pred, holdtheta_minus1_BJSAVL_5_norm_COIL_pred, holdtheta_plus1_BJSAVL_5_norm_COIL_pred, holdmu_BJSAVL_5_norm_COIL_pred, holdsigvar_BJSAVL_5_norm_COIL_pred, holdloglike_BJSAVL_5_norm_COIL_pred, holdpredpdf_BJSAVL_5_norm_COIL, accept_BJSAVL_5_norm_COIL_pred, aveJD_BJSAVL_5_norm_COIL_pred, TIME_BJSAVL_5_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
%  save BJSAVL_5_norm_COIL_pred.mat -v7.3 
%  [holdbeta_minus_BJSAVL_5_norm_IBM_pred, holdbeta_plus_BJSAVL_5_norm_IBM_pred, holdq_minus_BJSAVL_5_norm_IBM_pred, holdq_plus_BJSAVL_5_norm_IBM_pred, holdtheta_minus_BJSAVL_5_norm_IBM_pred, holdtheta_plus_BJSAVL_5_norm_IBM_pred, holdtheta_minus1_BJSAVL_5_norm_IBM_pred, holdtheta_plus1_BJSAVL_5_norm_IBM_pred, holdmu_BJSAVL_5_norm_IBM_pred, holdsigvar_BJSAVL_5_norm_IBM_pred, holdloglike_BJSAVL_5_norm_IBM_pred, holdpredpdf_BJSAVL_5_norm_IBM, accept_BJSAVL_5_norm_IBM_pred, aveJD_BJSAVL_5_norm_IBM_pred, TIME_BJSAVL_5_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
%  save BJSAVL_5_norm_IBM_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSAVL_5_norm_SP500_pred, holdbeta_plus_BJSAVL_5_norm_SP500_pred, holdq_minus_BJSAVL_5_norm_SP500_pred, holdq_plus_BJSAVL_5_norm_SP500_pred, holdtheta_minus_BJSAVL_5_norm_SP500_pred, holdtheta_plus_BJSAVL_5_norm_SP500_pred, holdtheta_minus1_BJSAVL_5_norm_SP500_pred, holdtheta_plus1_BJSAVL_5_norm_SP500_pred, holdmu_BJSAVL_5_norm_SP500_pred, holdsigvar_BJSAVL_5_norm_SP500_pred, holdloglike_BJSAVL_5_norm_SP500_pred, holdpredpdf_BJSAVL_5_norm_SP500, accept_BJSAVL_5_norm_SP500_pred, aveJD_BJSAVL_5_norm_SP500_pred, TIME_BJSAVL_5_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
% save BJSAVL_5_norm_SP500_pred.mat -v7.3 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                               11
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %1: BJSAV
% [holdbeta_minus_BJSAV_11_norm_SP500_pred, holdbeta_plus_BJSAV_11_norm_SP500_pred, holdq_minus_BJSAV_11_norm_SP500_pred, holdq_plus_BJSAV_11_norm_SP500_pred, holdtheta_minus_BJSAV_11_norm_SP500_pred, holdtheta_plus_BJSAV_11_norm_SP500_pred, holdtheta_minus1_BJSAV_11_norm_SP500_pred, holdtheta_plus1_BJSAV_11_norm_SP500_pred, holdmu_BJSAV_11_norm_SP500_pred, holdsigvar_BJSAV_11_norm_SP500_pred, holdloglike_BJSAV_11_norm_SP500_pred, holdpredpdf_BJSAV_11_norm_SP500, accept_BJSAV_11_norm_SP500_pred, aveJD_BJSAV_11_norm_SP500_pred, TIME_BJSAV_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
% save BJSAV_11_norm_SP500_pred.mat -v7.3 
% [holdbeta_minus_BJSAV_11_norm_IBM_pred, holdbeta_plus_BJSAV_11_norm_IBM_pred, holdq_minus_BJSAV_11_norm_IBM_pred, holdq_plus_BJSAV_11_norm_IBM_pred, holdtheta_minus_BJSAV_11_norm_IBM_pred, holdtheta_plus_BJSAV_11_norm_IBM_pred, holdtheta_minus1_BJSAV_11_norm_IBM_pred, holdtheta_plus1_BJSAV_11_norm_IBM_pred, holdmu_BJSAV_11_norm_IBM_pred, holdsigvar_BJSAV_11_norm_IBM_pred, holdloglike_BJSAV_11_norm_IBM_pred, holdpredpdf_BJSAV_11_norm_IBM, accept_BJSAV_11_norm_IBM_pred, aveJD_BJSAV_11_norm_IBM_pred, TIME_BJSAV_11_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
% save BJSAV_11_norm_IBM_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSAV_11_norm_COIL_pred, holdbeta_plus_BJSAV_11_norm_COIL_pred, holdq_minus_BJSAV_11_norm_COIL_pred, holdq_plus_BJSAV_11_norm_COIL_pred, holdtheta_minus_BJSAV_11_norm_COIL_pred, holdtheta_plus_BJSAV_11_norm_COIL_pred, holdtheta_minus1_BJSAV_11_norm_COIL_pred, holdtheta_plus1_BJSAV_11_norm_COIL_pred, holdmu_BJSAV_11_norm_COIL_pred, holdsigvar_BJSAV_11_norm_COIL_pred, holdloglike_BJSAV_11_norm_COIL_pred, holdpredpdf_BJSAV_11_norm_COIL, accept_BJSAV_11_norm_COIL_pred, aveJD_BJSAV_11_norm_COIL_pred, TIME_BJSAV_11_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
% save BJSAV_11_norm_COIL_pred.mat -v7.3 
%%%%%
% %2: BJSSV
% [holdbeta_minus_BJSSV_11_norm_COIL_pred, holdbeta_plus_BJSSV_11_norm_COIL_pred, holdq_minus_BJSSV_11_norm_COIL_pred, holdq_plus_BJSSV_11_norm_COIL_pred, holdtheta_minus_BJSSV_11_norm_COIL_pred, holdtheta_plus_BJSSV_11_norm_COIL_pred, holdtheta_minus1_BJSSV_11_norm_COIL_pred, holdtheta_plus1_BJSSV_11_norm_COIL_pred, holdmu_BJSSV_11_norm_COIL_pred, holdsigvar_BJSSV_11_norm_COIL_pred, holdloglike_BJSSV_11_norm_COIL_pred, holdpredpdf_BJSSV_11_norm_COIL, accept_BJSSV_11_norm_COIL_pred, aveJD_BJSSV_11_norm_COIL_pred, TIME_BJSSV_11_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
% save BJSSV_11_norm_COIL_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSSV_11_norm_SP500_pred, holdbeta_plus_BJSSV_11_norm_SP500_pred, holdq_minus_BJSSV_11_norm_SP500_pred, holdq_plus_BJSSV_11_norm_SP500_pred, holdtheta_minus_BJSSV_11_norm_SP500_pred, holdtheta_plus_BJSSV_11_norm_SP500_pred, holdtheta_minus1_BJSSV_11_norm_SP500_pred, holdtheta_plus1_BJSSV_11_norm_SP500_pred, holdmu_BJSSV_11_norm_SP500_pred, holdsigvar_BJSSV_11_norm_SP500_pred, holdloglike_BJSSV_11_norm_SP500_pred, holdpredpdf_BJSSV_11_norm_SP500, accept_BJSSV_11_norm_SP500_pred, aveJD_BJSSV_11_norm_SP500_pred, TIME_BJSSV_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
% save BJSSV_11_norm_SP500_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSSV_11_norm_IBM_pred, holdbeta_plus_BJSSV_11_norm_IBM_pred, holdq_minus_BJSSV_11_norm_IBM_pred, holdq_plus_BJSSV_11_norm_IBM_pred, holdtheta_minus_BJSSV_11_norm_IBM_pred, holdtheta_plus_BJSSV_11_norm_IBM_pred, holdtheta_minus1_BJSSV_11_norm_IBM_pred, holdtheta_plus1_BJSSV_11_norm_IBM_pred, holdmu_BJSSV_11_norm_IBM_pred, holdsigvar_BJSSV_11_norm_IBM_pred, holdloglike_BJSSV_11_norm_IBM_pred, holdpredpdf_BJSSV_11_norm_IBM, accept_BJSSV_11_norm_IBM_pred, aveJD_BJSSV_11_norm_IBM_pred, TIME_BJSSV_11_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
% save BJSSV_11_norm_IBM_pred.mat -v7.3 
%2: BJGJR
% [holdbeta_minus_BJGJR_11_norm_COIL_pred, holdbeta_plus_BJGJR_11_norm_COIL_pred, holdq_minus_BJGJR_11_norm_COIL_pred, holdq_plus_BJGJR_11_norm_COIL_pred, holdtheta_minus_BJGJR_11_norm_COIL_pred, holdtheta_plus_BJGJR_11_norm_COIL_pred, holdtheta_minus1_BJGJR_11_norm_COIL_pred, holdtheta_plus1_BJGJR_11_norm_COIL_pred, holdmu_BJGJR_11_norm_COIL_pred, holdsigvar_BJGJR_11_norm_COIL_pred, holdloglike_BJGJR_11_norm_COIL_pred, holdpredpdf_BJGJR_11_norm_COIL, accept_BJGJR_11_norm_COIL_pred, aveJD_BJGJR_11_norm_COIL_pred, TIME_BJGJR_11_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
% save BJGJR_11_norm_COIL_pred.mat -v7.3 

% [holdbeta_minus_BJGJR_11_norm_SP500_pred, holdbeta_plus_BJGJR_11_norm_SP500_pred, holdq_minus_BJGJR_11_norm_SP500_pred, holdq_plus_BJGJR_11_norm_SP500_pred, holdtheta_minus_BJGJR_11_norm_SP500_pred, holdtheta_plus_BJGJR_11_norm_SP500_pred, holdtheta_minus1_BJGJR_11_norm_SP500_pred, holdtheta_plus1_BJGJR_11_norm_SP500_pred, holdmu_BJGJR_11_norm_SP500_pred, holdsigvar_BJGJR_11_norm_SP500_pred, holdloglike_BJGJR_11_norm_SP500_pred, holdpredpdf_BJGJR_11_norm_SP500, accept_BJGJR_11_norm_SP500_pred, aveJD_BJGJR_11_norm_SP500_pred, TIME_BJGJR_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
% save BJGJR_11_norm_SP500_pred.mat -v7.3 
% 
% [holdbeta_minus_BJGJR_11_norm_IBM_pred, holdbeta_plus_BJGJR_11_norm_IBM_pred, holdq_minus_BJGJR_11_norm_IBM_pred, holdq_plus_BJGJR_11_norm_IBM_pred, holdtheta_minus_BJGJR_11_norm_IBM_pred, holdtheta_plus_BJGJR_11_norm_IBM_pred, holdtheta_minus1_BJGJR_11_norm_IBM_pred, holdtheta_plus1_BJGJR_11_norm_IBM_pred, holdmu_BJGJR_11_norm_IBM_pred, holdsigvar_BJGJR_11_norm_IBM_pred, holdloglike_BJGJR_11_norm_IBM_pred, holdpredpdf_BJGJR_11_norm_IBM, accept_BJGJR_11_norm_IBM_pred, aveJD_BJGJR_11_norm_IBM_pred, TIME_BJGJR_11_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 3, exp(linspace(0, -0.1, 4)));
% save BJGJR_11_norm_IBM_pred.mat -v7.3 
% % 
% %4: BJSAVL
%  [holdbeta_minus_BJSAVL_11_norm_COIL_pred, holdbeta_plus_BJSAVL_11_norm_COIL_pred, holdq_minus_BJSAVL_11_norm_COIL_pred, holdq_plus_BJSAVL_11_norm_COIL_pred, holdtheta_minus_BJSAVL_11_norm_COIL_pred, holdtheta_plus_BJSAVL_11_norm_COIL_pred, holdtheta_minus1_BJSAVL_11_norm_COIL_pred, holdtheta_plus1_BJSAVL_11_norm_COIL_pred, holdmu_BJSAVL_11_norm_COIL_pred, holdsigvar_BJSAVL_11_norm_COIL_pred, holdloglike_BJSAVL_11_norm_COIL_pred, holdpredpdf_BJSAVL_11_norm_COIL, accept_BJSAVL_11_norm_COIL_pred, aveJD_BJSAVL_11_norm_COIL_pred, TIME_BJSAVL_11_norm_COIL_pred] = MHRWIK_PT(100*ret_COIL, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
%  save BJSAVL_11_norm_COIL_pred.mat -v7.3 

%  [holdbeta_minus_BJSAVL_11_norm_IBM_pred, holdbeta_plus_BJSAVL_11_norm_IBM_pred, holdq_minus_BJSAVL_11_norm_IBM_pred, holdq_plus_BJSAVL_11_norm_IBM_pred, holdtheta_minus_BJSAVL_11_norm_IBM_pred, holdtheta_plus_BJSAVL_11_norm_IBM_pred, holdtheta_minus1_BJSAVL_11_norm_IBM_pred, holdtheta_plus1_BJSAVL_11_norm_IBM_pred, holdmu_BJSAVL_11_norm_IBM_pred, holdsigvar_BJSAVL_11_norm_IBM_pred, holdloglike_BJSAVL_11_norm_IBM_pred, holdpredpdf_BJSAVL_11_norm_IBM, accept_BJSAVL_11_norm_IBM_pred, aveJD_BJSAVL_11_norm_IBM_pred, TIME_BJSAVL_11_norm_IBM_pred] = MHRWIK_PT(100*ret_IBM, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
%  save BJSAVL_11_norm_IBM_pred.mat -v7.3 
% 
% [holdbeta_minus_BJSAVL_11_norm_SP500_pred, holdbeta_plus_BJSAVL_11_norm_SP500_pred, holdq_minus_BJSAVL_11_norm_SP500_pred, holdq_plus_BJSAVL_11_norm_SP500_pred, holdtheta_minus_BJSAVL_11_norm_SP500_pred, holdtheta_plus_BJSAVL_11_norm_SP500_pred, holdtheta_minus1_BJSAVL_11_norm_SP500_pred, holdtheta_plus1_BJSAVL_11_norm_SP500_pred, holdmu_BJSAVL_11_norm_SP500_pred, holdsigvar_BJSAVL_11_norm_SP500_pred, holdloglike_BJSAVL_11_norm_SP500_pred, holdpredpdf_BJSAVL_11_norm_SP500, accept_BJSAVL_11_norm_SP500_pred, aveJD_BJSAVL_11_norm_SP500_pred, TIME_BJSAVL_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 4, exp(linspace(0, -0.1, 3)));
% save BJSAVL_11_norm_SP500_pred.mat -v7.3 




figure(1)
for i = 1:30
    subplot(3,10,i)
    autocorr(holdbeta_minus_BJSAV_5_norm_COIL_pred(:, i), 'NumLags', 1000);
end

figure(2)
for i = 1:30
    subplot(3,10,i)
    autocorr(holdbeta_plus_BJSAV_5_norm_COIL_pred(:, i), 'NumLags', 1000);
end

figure(3)
for i = 1:3
    subplot(1,3,i)
    plot(holdmu_BJSAV_5_norm_COIL_pred(:, i));
end


figure(4)
for i = 1:3
    subplot(1,3,i)
    plot(holdsigvar_BJSAV_5_norm_COIL_pred(:, i));
end


z = quantile(holdbeta_minus_BJSAV_5_norm_COIL_pred(1:numberofits, :), [0.5 0.05 0.975]);
z_minus = z(1, :);
l_minus = z(2, :);
u_minus = z(3, :);

z = quantile(holdbeta_plus_BJSAV_5_norm_COIL_pred(1:numberofits, :), [0.5 0.05 0.975]);
z_plus = z(1, :);
l_plus = z(2, :);
u_plus = z(3, :);

nparam = 3;
for i = 1:nparam
    
    
    figure(i)
    x = z_plus(i:nparam:end);
    plot(x,'b-')
    hold on
    x = l_plus(i:nparam:end);
    plot(x, 'b--')
    x = u_plus(i:nparam:end);
    plot(x, 'b--')
    
    x = z_minus(i:nparam:end);
    plot(x,'r-')
    x = l_minus(i:nparam:end);
    plot(x, 'r--')
    x = u_minus(i:nparam:end);
    plot(x, 'r--')

    hold off
end    


for i = 1:30
    subplot(3,10,i)
    autocorr(holdbeta_minus_BJSAV_5_norm_COIL_pred(:, i), 'NumLags', 1000);
end



for i = 1:30
    subplot(3,10,i)
    autocorr(holdbeta_plus_BJSAV_5_norm_COIL_pred(:, i), 'NumLags', 1000);
end


for i = 1:3
    subplot(1,3,i)
    autocorr(holdsigvar_BJSAV_5_norm_COIL_pred(:, i), 'NumLags', 1000);
end

for i = 1:3
    subplot(1,3,i)
    autocorr(holdmu_BJSAV_5_norm_IBM_pred(:, i), 'NumLags', 1000);
end