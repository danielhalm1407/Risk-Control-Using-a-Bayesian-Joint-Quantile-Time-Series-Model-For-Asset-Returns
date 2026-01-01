function [holdbeta_minus, holdbeta_plus, holdq_minus, holdq_plus, holdtheta_minus, holdtheta_plus, holdtheta_minus1, holdtheta_plus1, holdmu, holdsigvar, holdloglike, accept, aveJD, TIME] = MHRWIK_PT(dat, alpha_minus, alpha_plus, numberofits, burnin, every, type, heat, fig1)
%************ INPUTS *****************************************************
% dat
% numberofits
% burnin
% thinning
% type
% 1 = BJSAV
% 2 = BJSSV
% 3 = BJGJR
% 4 = BJSAVL
%************ OUTPUT *****************************************************
% holdbeta
% holdalpha
% holdq
% holdtheta
% holdsigma
% accept
% aveJDs
% *************************************************************************

warning off

if ( verLessThan('matlab', '9.7') == 0 )
    d = uiprogressdlg(fig1,'Title','Fitting Model','Message', 'Progress');
else
    uialert(fig1, 'Running Code', 'Fitting Run','Icon', 'info');
end

tic
if ( (type == 1) || (type == 2) )
    nprmtrs = 3;
elseif ( ( type == 3 )|| (type == 4) )
    nprmtrs = 4;
end

xtot = dat;
%xtot(xtot(:, 1)==0,:) = [];
xtot(isnan(xtot)) = [];

Median = prctile(xtot(:, 1), 50);
ytot        = xtot - Median;
y           = ytot(:, :);

rhostar = zeros(1, length(heat) - 1);
for i = 1:(length(heat)-1)
    rhostar(i) = log(log(heat(i)/heat(i+1)));
end
order = 1:length(heat);

numbofchains = length(heat);

fin1_minus = length(alpha_minus)-1;
fin1_plus  = length(alpha_plus)-1;

beta_minus = ones(nprmtrs * fin1_minus, numbofchains);
beta_plus  = ones(nprmtrs * fin1_plus, numbofchains);

for chain = 1:numbofchains
    for i = 1:fin1_minus
        
        beta_minus(nprmtrs*(i-1)+2, chain)  = 0.85;
        beta_minus(nprmtrs*(i-1)+3, chain)  = 0.1;
        beta_minus(nprmtrs*(i-1)+1, chain)  = sqrt(var(y)) * (1 - beta_minus(nprmtrs*(i-1)+2, chain) - beta_minus(nprmtrs*(i-1) + 3, chain));
        if ( type == 2 )
        beta_minus(nprmtrs*(i-1)+1, chain)  = var(y) * (1 - beta_minus(nprmtrs*(i-1)+2, chain) - beta_minus(nprmtrs*(i-1) + 3, chain));
        end 
        
        if  ( type == 3 )
            beta_minus(nprmtrs*(i-1)+1, chain)  = var(y) * (1 - beta_minus(nprmtrs*(i-1)+2, chain) - beta_minus(nprmtrs*(i-1) + 3, chain));
            beta_minus(nprmtrs*(i-1)+4, chain)  = 0.001;
        end
        if  ( type == 4 )
            beta_minus(nprmtrs*(i-1)+1, chain)  = sqrt(var(y)) * (1 - beta_minus(nprmtrs*(i-1)+2, chain) - beta_minus(nprmtrs*(i-1) + 3, chain));
            beta_minus(nprmtrs*(i-1)+4, chain)  = 0.001;

        end
    end
end


for chain = 1:numbofchains
    for i = 1:fin1_plus
        beta_plus(nprmtrs*(i-1)+2, chain)  = 0.85;
        beta_plus(nprmtrs*(i-1)+3, chain)  = 0.1;
        beta_plus(nprmtrs*(i-1)+1, chain)  = sqrt(var(y)) * (1 - beta_plus(nprmtrs*(i-1)+2, chain) - beta_plus(nprmtrs*(i-1) + 3, chain));
        
        if ( type == 2 )
        beta_plus(nprmtrs*(i-1)+1, chain)  = var(y) * (1 - beta_plus(nprmtrs*(i-1)+2, chain) - beta_plus(nprmtrs*(i-1) + 3, chain));
        end
        if  ( type == 3 )
            beta_plus(nprmtrs*(i-1)+1, chain)  = var(y) * (1 - beta_plus(nprmtrs*(i-1)+2, chain) - beta_plus(nprmtrs*(i-1) + 3, chain));
            beta_plus(nprmtrs*(i-1)+4, chain)  = 0.001;
        end
        if  ( type == 4 )
            beta_plus(nprmtrs*(i-1)+1, chain)  = sqrt(var(y)) * (1 - beta_plus(nprmtrs*(i-1)+2, chain) - beta_plus(nprmtrs*(i-1) + 3, chain));
            beta_plus(nprmtrs*(i-1)+4, chain)  = 0.001;

        end
        
    end
end
%%
ell = 0.1 * ones(nprmtrs);
mu = zeros(nprmtrs, numbofchains);
sigvar = zeros(nprmtrs, numbofchains);

for i = 1:nprmtrs
    mu(i, :) = log(beta_plus(i, chain));
end
sigvar(1, :) = 0.9;
sigvar(2:nprmtrs, :) = 0.4;
% sigvar(1, :) = 0.8;
% sigvar(2:nprmtrs, :) = 0.3;
K        = zeros(fin1_minus+fin1_plus, fin1_minus+fin1_plus, nprmtrs);
cholK    = zeros(fin1_minus+fin1_plus, fin1_minus+fin1_plus, nprmtrs);
invcholK = zeros(fin1_minus+fin1_plus, fin1_minus+fin1_plus, nprmtrs);
e1K = zeros(fin1_minus+fin1_plus, fin1_minus+fin1_plus, nprmtrs);
e2K = zeros(fin1_minus+fin1_plus, nprmtrs);

onesK = zeros(1, fin1_minus+fin1_plus, nprmtrs);
onese1K = zeros(1, fin1_minus+fin1_plus, nprmtrs);

for i=1:nprmtrs
    K(:, :, i) = covAEiso(ell(i), alpha_minus, alpha_plus);
    
    invcholK(:, :, i) = inv(cholK(:, :, i));
    [e1, e2] = eig(K(:, :, i));
    e1K(:, :, i) = e1;
    e2K(:, i) = diag(e2);
    
    onesK(:, :, i) = ones(1, fin1_minus+fin1_plus) * e1K(:, :, i) * diag(1./e2K(:, i)) * e1K(:, :, i)';
    onese1K(:, :, i) = ones(1, fin1_minus+fin1_plus) * e1K(:, :, i);
end

prec_tot = zeros(1, nprmtrs);
for i = 1:nprmtrs
    prec_tot(i) = onesK(:, :, i) * ones(fin1_minus+fin1_plus, 1);
    
end
holdbeta_minus   = zeros(numberofits, size(beta_minus, 1));
holdbeta_plus    = zeros(numberofits, size(beta_plus, 1));
holdq_minus      = zeros(numberofits, length(y), length(alpha_minus)-2);
holdq_plus       = zeros(numberofits, length(y), length(alpha_plus)-2);
holdtheta_minus  = zeros(numberofits, length(y), fin1_minus);
holdtheta_plus   = zeros(numberofits, length(y), fin1_plus);
holdtheta_minus1 = zeros(numberofits, fin1_minus);
holdtheta_plus1  = zeros(numberofits, fin1_plus);
holdmu           = zeros(numberofits, nprmtrs);
holdsigvar       = zeros(numberofits, nprmtrs);
holdloglike      = zeros(numberofits, 1);

muaccept = zeros(nprmtrs, numbofchains);
mucount  = zeros(nprmtrs, numbofchains);
totalaccept  = zeros(1, numbofchains);
totalcount   = zeros(1, numbofchains);
totalaccept2 = zeros(1, numbofchains - 1);
totalcount2  = zeros(1, numbofchains - 1);
theta_plus1accept  = zeros(1, numbofchains);
theta_plus1count   = zeros(1, numbofchains);
theta_minus1accept = zeros(1, numbofchains);
theta_minus1count  = zeros(1, numbofchains);
sigvaraccept  = zeros(nprmtrs, numbofchains);
sigvarcount   = zeros(nprmtrs, numbofchains);
sigvaraccept2 = zeros(nprmtrs, numbofchains);
sigvarcount2  = zeros(nprmtrs, numbofchains);
%
sumxsq_minus = zeros(nprmtrs, nprmtrs, fin1_minus, numbofchains);
sumx_minus   = zeros(nprmtrs, fin1_minus, numbofchains);
count1_minus = zeros(fin1_minus, numbofchains);
sumxsq_plus  = zeros(nprmtrs, nprmtrs, fin1_plus, numbofchains);
sumx_plus    = zeros(nprmtrs, fin1_plus, numbofchains);
count1_plus  = zeros(fin1_plus, numbofchains);
%
theta_minus1 = sqrt(var(y)) * ones(fin1_minus, numbofchains);
theta_plus1  = sqrt(var(y)) * ones(fin1_plus, numbofchains);
sigmasq      = ones(length(y), numbofchains);

q_minus = zeros(length(y), length(alpha_minus) - 2, numbofchains);
q_plus  = zeros(length(y), length(alpha_plus) - 2, numbofchains);
theta_minus = zeros(length(y), length(alpha_minus) - 1, numbofchains);
theta_plus  = zeros(length(y), length(alpha_plus) - 1, numbofchains);
loglike     = zeros(1, numbofchains);

for chain = 1:numbofchains
    param = [beta_minus(:, chain)' beta_plus(:, chain)' theta_minus1(:, chain)' theta_plus1(:, chain)'];
    if ( type == 1 )
        [q_minus(:, :, chain), q_plus(:, :, chain), theta_minus(:, :, chain), theta_plus(:, :, chain)] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
    elseif ( type == 2 )
        [q_minus(:, :, chain), q_plus(:, :, chain), theta_minus(:, :, chain), theta_plus(:, :, chain)] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
    elseif  ( type == 3 )
        [q_minus(:, :, chain), q_plus(:, :, chain), theta_minus(:, :, chain), theta_plus(:, :, chain)] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
     elseif  ( type == 4 )
        [q_minus(:, :, chain), q_plus(:, :, chain), theta_minus(:, :, chain), theta_plus(:, :, chain)] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
    end
    loglike(chain) = LK_norm(q_minus(:, :, chain), q_plus(:, :, chain), theta_minus(:, :, chain), theta_plus(:, :, chain), sigmasq(:, chain), y, alpha_minus, alpha_plus);
end

logscale         = log(10^(-2)) * ones(nprmtrs, numbofchains);
logtheta_minus1sd= log(10^(-2)) * ones(fin1_minus, numbofchains);
logtheta_plus1sd = log(10^(-2)) * ones(fin1_plus, numbofchains);
logsigvarsd      = log(10^(-2)) * ones(nprmtrs, numbofchains);
logsigvarsd2     = log(10^(-4)) * ones(nprmtrs, numbofchains);
musd             = log(10^(-4)) * ones(nprmtrs, numbofchains);

for it = 1:(burnin+numberofits*every)
    
%     if ( mod(it, 10) == 0 )
%         top_chain = find(order == 1);
%         disp(['it = ' num2str(it)]);
%         disp(['heat = ' num2str(heat)]);
%         disp(['mu = ' num2str(mu(:, top_chain)')]);
%         disp(['sigvar = ' num2str(sigvar(:, top_chain)')]);
%         
%         temploglike = zeros(1, length(order));
%         for i = 1:length(order)
%             temploglike(i) = loglike(order==i);
%         end
%         disp(['log likeihood = ' num2str(temploglike)]);
%         disp(['accept = ' num2str(totalaccept ./ totalcount)]);
%         disp(['accept2 = ' num2str(totalaccept2 ./ totalcount2)]);
%         disp(['theta_plus1 accept = ' num2str(theta_plus1accept./theta_plus1count)]);
%         disp(['theta_minus1 accept = ' num2str(theta_minus1accept./theta_minus1count)]);
%         disp(['mu accept' num2str(median(muaccept ./ mucount))]);
%         disp(['sigvar accept' num2str(median(sigvaraccept ./ sigvarcount))]);
%         disp(['sigvar accept 2' num2str(median(sigvaraccept2 ./ sigvarcount2))]);
%         disp(' ');
%         %         disp('mu accept')
%         %         muaccept ./ mucount
%         %         disp('sigvar accept')
%         %         sigvaraccept ./ sigvarcount
%         %         disp('sigvar accept 2')
%         %         sigvaraccept2 ./ sigvarcount2
%         %         disp(' ');
%         
%         
% %         figure(1)
% % %         plot(y)
% % %         hold on
% %         plot(q_minus(:, :, top_chain))
% %         hold on
% %         plot(q_plus(:, :, top_chain))
% %         hold off
% %         drawnow
% %         
% %         %        figure(2)
%         %        plot(sigmasq)
%     end
        
    for chain = 1:numbofchains
        
        chain1 = order(chain);
        
        for i=1:size(theta_minus1, 1)
            
            newtheta_minus1    = theta_minus1(:, chain);
            newtheta_minus1(i) = theta_minus1(i, chain) * exp(exp(logtheta_minus1sd(i, chain1)) * randn);
            
            param = [beta_minus(:, chain)' beta_plus(:, chain)' newtheta_minus1' theta_plus1(:, chain)'];
            if ( type == 1 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
            elseif  ( type == 2 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 3 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
             elseif  ( type == 4 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
            end
            newloglike = LK_norm(newq_minus, newq_plus, newtheta_minus, newtheta_plus, sigmasq(:, chain), y, alpha_minus, alpha_plus);
            
            logaccept = heat(chain1) * (newloglike - loglike(chain));
            logaccept = logaccept + log(newtheta_minus1(i)) - 2 * log(1 + newtheta_minus1(i));
            logaccept = logaccept - log(theta_minus1(i, chain)) + 2 * log(1 + theta_minus1(i, chain));
            
            accept = 1;
            if ( (isreal(logaccept) == 0) || (isnan(logaccept)==1) || (isinf(logaccept)==1) )
                accept = 0;
            elseif ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            theta_minus1accept(chain1) = theta_minus1accept(chain1) + accept;
            theta_minus1count(chain1)  = theta_minus1count(chain1) + 1;
            
            if ( rand < accept )
                theta_minus1(:, chain) = newtheta_minus1;
                q_minus(:, :, chain) = newq_minus;
                q_plus(:, :, chain)  = newq_plus;
                theta_minus(:, :, chain) = newtheta_minus;
                theta_plus(:, :, chain)  = newtheta_plus;
                loglike(chain) = newloglike;
            end
            
            logtheta_minus1sd(i, chain1) = logtheta_minus1sd(i, chain1) + ((1 / it^0.55) * (accept - 0.234));
        end
        
        for i = 1:nprmtrs
            err1 = exp(logscale(i, chain1)) * sqrt(sigvar(i, chain)) * e1K(:, :, i) * (sqrt(e2K(:, i)) .* randn(fin1_minus + fin1_plus, 1));
            newbeta_minus = beta_minus(:, chain);
            newbeta_plus = beta_plus(:, chain);
            newbeta_minus(i:nprmtrs:end) = beta_minus(i:nprmtrs:end, chain) .* exp(err1(1:fin1_minus));
            newbeta_plus(i:nprmtrs:end) = beta_plus(i:nprmtrs:end, chain) .* exp(err1((fin1_minus+1):(fin1_minus+fin1_plus)));
            
            param = [newbeta_minus' newbeta_plus' theta_minus1(:, chain)' theta_plus1(:, chain)'];
            if ( type == 1 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 2 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 3 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
             elseif ( type == 4 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
             end
            newloglike = LK_norm(newq_minus, newq_plus, newtheta_minus, newtheta_plus, sigmasq(:, chain), y, alpha_minus, alpha_plus);
            
            logaccept = heat(chain1) * (newloglike - loglike(chain));
            
            xstar = [newbeta_minus(i:nprmtrs:end); newbeta_plus(i:nprmtrs:end)];
            zstar = e1K(:, :, i)' * (log(xstar) - mu(i, chain));
            logaccept = logaccept - 0.5 * sum(sum(zstar.^2, 2) ./ e2K(:, i)) / sigvar(i, chain);
            xstar = [beta_minus(i:nprmtrs:end, chain); beta_plus(i:nprmtrs:end, chain)];
            zstar = e1K(:, :, i)' * (log(xstar) - mu(i, chain));
            logaccept = logaccept + 0.5 * sum(sum(zstar.^2, 2) ./ e2K(:, i)) / sigvar(i, chain);
            
            accept = 1;
            if ( (isreal(logaccept) == 0) || (isnan(logaccept)==1) || (isinf(logaccept)==1) )
                accept = 0;
            elseif ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            if ( rand < accept )
                beta_minus(:, chain) = newbeta_minus;
                beta_plus(:, chain)  = newbeta_plus;
                q_minus(:, :, chain) = newq_minus;
                q_plus(:, :, chain)  = newq_plus;
                theta_minus(:, :, chain) = newtheta_minus;
                theta_plus(:, :, chain)  = newtheta_plus;
                loglike(chain) = newloglike;
            end
            totalaccept(chain1) = totalaccept(chain1) + accept;
            totalcount(chain1)  = totalcount(chain1) + 1;
            
            logscale(i, chain1) = logscale(i, chain1) + ((1 / it^0.55) * (accept - 0.234));
        end
        
        
        for i=1:size(theta_plus, 2)
            
            newtheta_plus1 = theta_plus1(:, chain);
            newtheta_plus1(i) = theta_plus1(i, chain) * exp(exp(logtheta_plus1sd(i, chain1)) * randn);
            
            param = [beta_minus(:, chain)' beta_plus(:, chain)' theta_minus1(:, chain)' newtheta_plus1'];
            if ( type == 1 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 2 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 3 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
             elseif ( type == 4 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
             end
            newloglike = LK_norm(newq_minus, newq_plus, newtheta_minus, newtheta_plus, sigmasq(:, chain), y, alpha_minus, alpha_plus);
            
            logaccept = heat(chain1) * (newloglike - loglike(chain));
            logaccept = logaccept + log(newtheta_plus1(i)) - 2 * log(1 + newtheta_plus1(i));
            logaccept = logaccept - log(theta_plus1(i, chain)) + 2 * log(1 + theta_plus1(i, chain));
            
            accept = 1;
            if ( (isreal(logaccept) == 0) || (isnan(logaccept)==1) || (isinf(logaccept)==1) )
                accept = 0;
            elseif ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            theta_plus1accept(chain1) = theta_plus1accept(chain1) + accept;
            theta_plus1count(chain1)  = theta_plus1count(chain1) + 1;
            
            if ( rand < accept )
                theta_plus1(:, chain) = newtheta_plus1;
                q_minus(:, :, chain) = newq_minus;
                q_plus(:, :, chain)  = newq_plus;
                theta_minus(:, :, chain) = newtheta_minus;
                theta_plus(:, :, chain)  = newtheta_plus;
                loglike(chain) = newloglike;
            end
            
            logtheta_plus1sd(i, chain1) = logtheta_plus1sd(i, chain1) + ((1 / it^0.55) * (accept - 0.234));
        end
        
        
        for j = 1:nprmtrs
            xstar = [beta_minus(j:nprmtrs:end, chain); beta_plus(j:nprmtrs:end, chain)];
            
            mean1 = onesK(:, :, j) * log(xstar) / prec_tot(j);
            mu(j, chain) = mean1 + sqrt(sigvar(j, chain) / prec_tot(j)) * randn;
            
            if ( isreal(mu(j)) == 0 )
                mean1
                sigvar(j)
                prec_tot(j)
                mu(j)
                stop;
            end
            
            newsigvar = sigvar(j, chain) * exp(exp(logsigvarsd(j, chain1)) * randn);
            
                        zstar = e1K(:, :, j)' * (log(xstar) - mu(j, chain));
                        loglike1 = - 0.5 * length(xstar) * log(sigvar(j, chain)) - 0.5 * sum(sum(zstar.^2, 2) ./ e2K(:, j)) / sigvar(j, chain);
                        newloglike1 = - 0.5 * length(xstar) * log(newsigvar) - 0.5 * sum(sum(zstar.^2, 2) ./ e2K(:, j)) / newsigvar;
            
            logaccept = newloglike1 - loglike1;
            logaccept = logaccept + log(newsigvar) - 2 * log(1 + newsigvar);
            logaccept = logaccept - log(sigvar(j, chain)) + 2 * log(1 + sigvar(j, chain));
                        
            accept = 1;
            if ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            %             if ( accept == 0 )
            %                 sigvar(j, chain)
            %                 newsigvar
            %                 loglike1
            %                 newloglike1
            %             end
            
            if ( rand < accept )
                sigvar(j, chain) = newsigvar;
            end
            
            sigvaraccept(j, chain1) = sigvaraccept(j, chain1) + accept;
            sigvarcount(j, chain1) = sigvarcount(j, chain1) + 1;
            
            logsigvarsd(j, chain1) = logsigvarsd(j, chain1) + 1 / it^0.55 * (accept - 0.234);
        end
        
        for i = 1:nprmtrs
            newsigvar = sigvar(:, chain);
            newsigvar(i) = sigvar(i, chain) * exp(exp(logsigvarsd2(i, chain1)) * randn);
            transx = mu(i, chain) + newsigvar(i) / sigvar(i, chain) * (log(beta_minus(:, chain)) - mu(i, chain));
            newbeta_minus = exp(transx);
            transx = mu(i, chain) + newsigvar(i) / sigvar(i, chain) * (log(beta_plus(:, chain)) - mu(i, chain));
            newbeta_plus = exp(transx);
            
            param = [newbeta_minus' newbeta_plus' theta_minus1(:, chain)' theta_plus1(:, chain)'];
            if ( type == 1 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 2 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 3 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
             elseif ( type == 4 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
             end
            newloglike = LK_norm(newq_minus, newq_plus, newtheta_minus, newtheta_plus, sigmasq(:, chain), y, alpha_minus, alpha_plus);
            
            logaccept = heat(chain1) * (newloglike - loglike(chain));
            logaccept = logaccept + log(newsigvar(i)) - 2 * log(1 + newsigvar(i));
            logaccept = logaccept - log(sigvar(i, chain)) + 2 * log(1 + sigvar(i, chain));
                        
            accept = 1;
            if ( (isreal(logaccept) == 0) || (isnan(logaccept)==1) || (isinf(logaccept)==1) )
                accept = 0;
            elseif ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            if ( rand < accept )
                sigvar(i, chain) = newsigvar(i);
                beta_minus(:, chain) = newbeta_minus;
                beta_plus(:, chain) = newbeta_plus;
                q_minus(:, :, chain) = newq_minus;
                q_plus(:, :, chain)  = newq_plus;
                theta_minus(:, :, chain) = newtheta_minus;
                theta_plus(:, :, chain)  = newtheta_plus;
                loglike(chain) = newloglike;
            end
            sigvaraccept2(i, chain1) = sigvaraccept2(i, chain1) + accept;
            sigvarcount2(i, chain1)  = sigvarcount2(i, chain1) + 1;
            
            logsigvarsd2(i, chain1) = logsigvarsd2(i, chain1) + ((1 / it^0.55) * (accept - 0.234));
        end
        

                
        for i = 1:nprmtrs
            newmu = mu(:, chain);
            newmu(i) = mu(i, chain) + exp(musd(i, chain1)) * randn;
            newbeta_minus = beta_minus(:, chain) * exp(newmu(i) - mu(i, chain));
            newbeta_plus = beta_plus(:, chain) * exp(newmu(i) - mu(i, chain));
            
            param = [newbeta_minus' newbeta_plus' theta_minus1(:, chain)' theta_plus1(:, chain)'];
            if ( type == 1 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 2 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param);
            elseif ( type == 3 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJGJR(y, alpha_minus, alpha_plus, param);
            elseif ( type == 4 )
                [newq_minus, newq_plus, newtheta_minus, newtheta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param);
            end
            newloglike = LK_norm(newq_minus, newq_plus, newtheta_minus, newtheta_plus, sigmasq(:, chain), y, alpha_minus, alpha_plus);
            
            logaccept = heat(chain1) * (newloglike - loglike(chain));
                        
            accept = 1;
            if ( (isreal(logaccept) == 0) || (isnan(logaccept)==1) || (isinf(logaccept)==1) )
                accept = 0;
            elseif ( logaccept < 0 )
                accept = exp(logaccept);
            end
            
            if ( rand < accept )
                mu(i, chain) = newmu(i);
                beta_minus(:, chain) = newbeta_minus;
                beta_plus(:, chain) = newbeta_plus;
                q_minus(:, :, chain) = newq_minus;
                q_plus(:, :, chain)  = newq_plus;
                theta_minus(:, :, chain) = newtheta_minus;
                theta_plus(:, :, chain)  = newtheta_plus;
                loglike(chain) = newloglike;
            end
            muaccept(i, chain1) = muaccept(i, chain1) + accept;
            mucount(i, chain1)  = mucount(i, chain1) + 1;
            
            musd(i, chain1) = musd(i, chain1) + ((1 / it^0.55) * (accept - 0.234));
        end

        
        for i = 1:size(theta_plus, 2)
            trans = log(beta_plus((nprmtrs*(i-1)+1):(nprmtrs*i), chain));
            sumxsq_plus(:, :, i, chain1) = sumxsq_plus(:, :, i, chain1) + trans * trans';
            sumx_plus(:, i, chain1) = sumx_plus(:,  i, chain1) + trans;
            count1_plus(i, chain1)  = count1_plus(i, chain1) + 1;
        end
        for i = 1:size(theta_minus, 2)
            trans = log(beta_minus((nprmtrs*(i-1)+1):(nprmtrs*i), chain));
            sumxsq_minus(:, :, i, chain1) = sumxsq_minus(:, :, i, chain1) + trans * trans';
            sumx_minus(:, i, chain1)   = sumx_minus(:, i, chain1) + trans;
            count1_minus(i, chain1) = count1_minus(i, chain1) + 1;
        end
    end
    
        
    if ( length(heat) > 1 )
        % Swap move
        check = 1;
        while ( check == 1 )
            chain1 = ceil(rand * length(heat));
            check = (order(chain1) == length(heat));
        end
        chain2 = find(order == order(chain1) + 1);
        
        loglike1 = loglike(chain1);
        loglike2 = loglike(chain2);
        
        logaccept = heat(order(chain1)) * loglike2 + heat(order(chain2)) * loglike1 - heat(order(chain1)) * loglike1 - heat(order(chain2)) * loglike2;
        
        accept = 1;
        if ( logaccept  < 0 )
            accept = exp(logaccept);
        end
        totalaccept2(order(chain1)) = totalaccept2(order(chain1)) + accept;
        totalcount2(order(chain1))  = totalcount2(order(chain1)) + 1;
        
        rhostar(order(chain1)) = rhostar(order(chain1)) + 1 / it^0.55 * (accept - 0.234);
        if ( rhostar(order(chain1)) > 4 )
            rhostar(order(chain1)) = 4;
        end
        
        for j = 1:(length(heat)-1)
            heat(j+1) = heat(j) * exp(- exp(rhostar(j)));
        end
        
        if ( rand < accept )
            order(chain1) = order(chain1) + 1;
            order(chain2) = order(chain2) - 1;
        end
    end
    
    if ( verLessThan('matlab', '9.7') == 0 )
        
        d.Value = it / (burnin+numberofits*every);
        d.Message = 'Current Progress';
        
    else
       
        Val = floor(100 * it / (burnin+numberofits*every));
        uialert(fig1, [num2str(Val) '% completed'], 'Fitting Run','Icon', 'info');
        
    end
    
    if ( (it > burnin) && (mod(it - burnin, every) == 0) )
        
              
         
        top_chain = find(order == 1);

        holdbeta_minus((it - burnin) / every, :)     = beta_minus(:, top_chain);
        holdbeta_plus((it - burnin) / every, :)      = beta_plus(:, top_chain);
        holdq_minus((it - burnin) / every, :, :)     = q_minus(:, :, top_chain);
        holdq_plus((it - burnin) / every, :, :)      = q_plus(:, :, top_chain);
        holdtheta_minus((it - burnin) / every, :, :) = theta_minus(:, :, top_chain);
        holdtheta_plus((it - burnin) / every, :, :)  = theta_plus(:, :, top_chain);
        holdtheta_minus1((it - burnin) / every, :)   = theta_minus1(:, top_chain);
        holdtheta_plus1((it - burnin) / every, :)    = theta_plus1(:, top_chain);
        holdmu((it - burnin) / every, :)             = mu(:, top_chain);
        holdsigvar((it - burnin) / every, :)         = sigvar(:, top_chain);
        holdloglike((it - burnin) / every)           = loglike(top_chain);

        

    end
end

aveJD  = 0;
accept = totalaccept ./ totalcount;
TIME   = toc;



