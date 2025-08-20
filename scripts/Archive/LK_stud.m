function [LK] = LK_stud(q_minus, q_plus, theta_minus, theta_plus, sigmasq, y, alpha_minus, alpha_plus, nu)
%*************************************************************************
% Computes the loglikelihood for the model when the centring distribution
% is the Student
%
check2 = 1;
LK = 0;

theta_minus = theta_minus .* (sqrt(sigmasq) * ones(1, size(theta_minus, 2)));
theta_plus  = theta_plus  .* (sqrt(sigmasq) * ones(1, size(theta_minus, 2)));

fin1 = size(q_minus, 2);

z1 = ((y(:, 1) > q_minus(:, 1)) .* (y(:, 1)<0));
LK = LK - sum(log(theta_minus(z1==1, 1))) + sum(logSt( (y(z1==1, 1))./theta_minus(z1==1, 1), nu ));
for j = 2:fin1
    z1 = ((y(:, 1) > q_minus(:, j)) .* (y(:, 1)<q_minus(:, j - 1)));
    LK = LK - sum(log(theta_minus(z1==1, j))) + sum(logSt( (y(z1==1, 1) - q_minus(z1==1, j-1))./theta_minus(z1==1, j)+tinv(0.5 - alpha_minus(j), nu), nu ));
end
z1 = (y(:, 1) < q_minus(:, fin1));
LK = LK - sum(log(theta_minus(z1==1, fin1+1))) + sum(logSt( (y(z1==1, 1) - q_minus(z1==1, fin1))./theta_minus(z1==1, fin1+1)+tinv(0.5 - alpha_minus(fin1+1), nu), nu ));

fin1 = size(q_plus, 2);
z1 = ((y(:, 1)>=0) .* (y(:, 1)<q_plus(:, 1)));
LK = LK - sum(log(theta_plus(z1==1, 1))) + sum(logSt(y(z1==1, 1)./theta_plus(z1==1, 1), nu));
for j = 2:fin1
    z1 = ((y(:, 1)>q_plus(:, j -1)) .* (y(:, 1)<q_plus(:, j)));
    LK = LK - sum(log(theta_plus(z1==1, j))) + sum(logSt( (y(z1==1, 1)-q_plus(z1==1, j-1))./theta_plus(z1==1, j)+tinv(0.5 + alpha_plus(j), nu), nu ));
end
z1 = (y(:, 1)>q_plus(:, fin1));
LK = LK - sum(log(theta_plus(z1==1, fin1+1))) + sum(logSt( (y(z1==1, 1)-q_plus(z1==1, fin1))./theta_plus(z1==1, fin1+1)+tinv(0.5 + alpha_plus(fin1+1), nu), nu ));


if ( check2 == 0 )
    LK = -inf;
end
if ( check2 == 0 )
    LK = inf;
end
%**************************************************************************
