function [z_final] = reduce_z(z_initial)
% This function reduces the input value z_initial 
% by decrementing it until it is less than or equal to half of z_initial.

z = z_initial;

while z > z_initial/2
    z = z - 1; % Example operation to reduce z
end

z_final = z;

end