pr = mean(holdpredpdf_BJSAVL_psit_21_norm_SP500);


 max1 = max(pr);
 
 probstar = (exp(pr - ones(size(pr, 1), 1) * max1));
 
 logpred = log(probstar) + max1;
% 
 LPS = mean(- logpred);


xtot           = ret_SP500;
xtot(xtot(:, 1)==0,:) = [];
xtot(isnan(xtot))=[];
Median = prctile(xtot(:, 1), 50);

inSampleObs = ceil(size(xtot,1)- size(xtot,1)/2);       
ytot        = xtot-Median;
yin         = ytot(1: inSampleObs, 1);     %%% fit
yout        = ytot(inSampleObs+1: end, 1); %%% predictive
 
limit1 = quantile(abs(yout), 0.95);
zstar = abs(yout) > limit1;
LPS005 = mean(- logpred(zstar==1));
 
limit2 = quantile(abs(yout), 0.99);
zstar = abs(yout) > limit2;
LPS001 = mean(- logpred(zstar==1));


