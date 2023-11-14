function y = heaviside(n)
% We assume a vector input 

% Our default output value is 0
y = 0 * n;
% Now, we find values in n greater than or equal to 0
y(find(n >= 0)) = 1;

end

