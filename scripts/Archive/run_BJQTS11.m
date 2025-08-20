load data_SP500.mat	

alpha_minus = linspace(0, 0.5, 11);
alpha_plus  = linspace(0, 0.5, 11);

burnin      = 10000;
numberofits = 2000;
every       = 5;
tic
%1
[holdbeta_minus_BJSAV_11_norm_SP500_pred, holdbeta_plus_BJSAV_11_norm_SP500_pred, holdq_minus_BJSAV_11_norm_SP500_pred, holdq_plus_BJSAV_11_norm_SP500_pred, holdtheta_minus_BJSAV_11_norm_SP500_pred, holdtheta_plus_BJSAV_11_norm_SP500_pred, holdtheta_minus1_BJSAV_11_norm_SP500_pred, holdtheta_plus1_BJSAV_11_norm_SP500_pred, holdmu_BJSAV_11_norm_SP500_pred, holdsigvar_BJSAV_11_norm_SP500_pred, holdloglike_BJSAV_11_norm_SP500_pred, holdpredpdf_BJSAV_11_norm_SP500, accept_BJSAV_11_norm_SP500_pred, aveJD_BJSAV_11_norm_SP500_pred, TIME_BJSAV_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));
save BJSAV_11_norm_SP500_pred.mat -v7.3 

%2
% [holdbeta_minus_BJSSV_11_norm_SP500_pred, holdbeta_plus_BJSSV_11_norm_SP500_pred, holdq_minus_BJSSV_11_norm_SP500_pred, holdq_plus_BJSSV_11_norm_SP500_pred, holdtheta_minus_BJSSV_11_norm_SP500_pred, holdtheta_plus_BJSSV_11_norm_SP500_pred, holdtheta_minus1_BJSSV_11_norm_SP500_pred, holdtheta_plus1_BJSSV_11_norm_SP500_pred, holdmu_BJSSV_11_norm_SP500_pred, holdsigvar_BJSSV_11_norm_SP500_pred, holdloglike_BJSSV_11_norm_SP500_pred, holdpredpdf_BJSSV_11_norm_SP500, accept_BJSSV_11_norm_SP500_pred, aveJD_BJSSV_11_norm_SP500_pred, TIME_BJSSV_11_norm_SP500_pred] = MHRWIK_PT(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 2, exp(linspace(0, -0.1, 3)));
% save BJSSV_11_norm_SP500_pred.mat -v7.3 

%3
%[holdbeta_minus_BJGJR_SP500, holdbeta_plus_BJGJR_SP500, holdq_minus_BJGJR_SP500, holdq_plus_BJGJR_SP500, holdtheta_minus_BJGJR_SP500, holdtheta_plus_BJGJR_SP500, holdtheta_minus1_BJGJR_SP500, holdtheta_plus1_BJGJR_SP500, holdmu_BJGJR_SP500, holdsigmaq_BJGJR_SP500, holdloglike_BJGJR_SP500, accept_BJGJR_SP500, aveJD_BJGJR_SP500, TIME_BJGJR_11_norm_SP500_pred] = MHRWIK_BJSAV_new(100*ret_SP500, alpha_minus, alpha_plus, numberofits, burnin, every, 3);

figure(1)
for i = 1:30
    subplot(3,10,i)
    plot(holdbeta_minus_BJSAV_11_norm_SP500_pred(:, i));
end

figure(2)
for i = 1:30
    subplot(3,10,i)
    plot(holdbeta_plus_BJSAV_11_norm_SP500_pred(:, i));
end

figure(3)
for i = 1:3
    subplot(1,3,i)
    plot(holdmu_BJSAV_11_norm_SP500_pred(:, i));
end


figure(4)
for i = 1:3
    subplot(1,3,i)
    plot(holdsigvar_BJSAV_11_norm_SP500_pred(:, i));
end

% figure(1)
% plot(holdloglike_BJSAV_SP500, 'b-')
% hold on
% plot(holdloglike_BJSSV_11_norm_SP500_pred, 'r-')
% plot(holdloglike_BJGJR_SP500, 'g-')
% plot(holdloglike_BJST_SP500, 'm-')
% hold off
% 

z = quantile(holdbeta_minus_BJSAV_11_norm_SP500_pred(1:numberofits, :), [0.5 0.05 0.975]);
z_minus = z(1, :);
l_minus = z(2, :);
u_minus = z(3, :);

z = quantile(holdbeta_plus_BJSAV_11_norm_SP500_pred(1:numberofits, :), [0.5 0.05 0.975]);
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
    autocorr(holdbeta_minus_BJSAV_11_norm_SP500_pred(:, i), 500);
end



for i = 1:30
    subplot(3,10,i)
    autocorr(holdbeta_plus_BJSAV_11_norm_SP500_pred(:, i), 1000);
end


for i = 1:3
    subplot(1,3,i)
    autocorr(holdsigvar_BJSAV_11_norm_SP500_pred(:, i), 1000);
end