A = [2 1; 0 1];

B = [1 ; 1];

Q = sdpvar(2, 2);

Y = sdpvar(1,2);

const = [[Q (A*Q+B*Y)'; (A*Q+B*Y) Q] >= 10^-6];

const = [const , Q >= 10^-6];

cost = [];

options = sdpsettings('debug',1);
sol = optimize(const, cost, options);

solution_Y = double(Y)

solution_Q = double(Q)

P = inv(solution_Q)


K = solution_Y*P