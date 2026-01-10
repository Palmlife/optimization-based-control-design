% Solve "Computer Education Problem" (Q7) using YALMIP (sdpvar)
% This script computes the optimal *trajectory* for N=10 years
% starting from x(0) = [1; 1].

clear; clc;

% Ensure YALMIP is in your path (you might need to run 'yalmipdemo')
% and you have a QP solver like 'quadprog' (built-in) or Gurobi/Mosek.

%% System and Problem Definition
N = 10; % Horizon
A = [0.95 0.05; 0 1];
B = [-1 0; 0 -1];
x0 = [1; 1]; % The given initial state

% Assume cost coefficients 
c1 = 5;
c2 = 3;

% Cost matrices
Q = [10 0; 0 0];  % Stage cost for x
R = [c1 0; 0 c2];  % Stage cost for u
QN = Q;             % Terminal cost for x(N)

%% Define YALMIP Variables
% We need to define the state and input variables for the entire horizon
% x(:,t) will be the state at time t-1 
% We'll have N+1 states (t=0 to t=N) and N inputs (t=0 to t=N-1)
x = sdpvar(2, N + 1); % x(t) from t=0 (col 1) to t=N (col N+1)
u = sdpvar(2, N);     % u(t) from t=0 (col 1) to t=N-1 (col N)

%% 3. Define Constraints and cost
constraints = [];
cost = 0;

% Add the initial state constraint
constraints = [constraints, x(:, 1) == x0];

% Loop through the 10-year horizon
for t = 1:N
    % System Dynamics Constraint: x(t+1) = A*x(t) + B*u(t)
    % In our 1-based indexing: x(:,t+1) == A*x(:,t) + B*u(:,t)
    constraints = [constraints, x(:, t + 1) == A * x(:, t) + B * u(:, t)];
    
    % State Constraints: 0 <= x(t) <= 1
    constraints = [constraints, [0; 0] <= x(:, t), x(:, t) <= [1; 1]];

    % Input Constraints: 0 <= u(t) <= 1
    constraints = [constraints,[0; 0] <= u(:, t), u(:, t) <= [1; 1]];

    % cost Function (Stage Cost): x(t)'Qx(t) + u(t)'Ru(t)
    cost = cost + x(:, t)' * Q * x(:, t) + u(:, t)' * R * u(:, t);
end

% Add constraints for the *final* state x(N)
constraints = [constraints,[0; 0] <= x(:, N + 1), x(:, N + 1) <= [1; 1]];

% Add the *terminal* cost: x(N)' * QN * x(N)
cost = cost + x(:, N + 1)' * QN * x(:, N + 1);

%% Solve the Problem
disp('Solving the 10-year optimal control problem as a single QP...');


sol = optimize(constraints, cost);

%% 5. Display and Plot Results
if sol.problem == 0
    disp('Optimal 10-year plan found!');
    
    % Get the numerical values from the YALMIP variables
    x_opt = value(x);
    u_opt = value(u);

    % Plot the optimal state trajectory
    figure;
    plot(0:N, x_opt', '-o');
    title('Optimal 10-Year Trajectory ');
    xlabel('Year (t)');
    ylabel('Percentage Unable (x)');
    legend('x_1 (Public Admin)', 'x_2 (Young People)');
    grid on;
    ylim([0, 1.1]);
    
    % Plot the optimal control inputs
    figure;
    stairs(0:(N-1), u_opt', '-o');
    title('Optimal 10-Year Action Plan ');
    xlabel('Year (t)');
    ylabel('Action Applied (u)');
    legend('u_1 (Teach Public Admin)', 'u_2 (Teach Young People)');
    grid on;
    ylim([0, 1.1]);
    
    fprintf('\nOptimal first action: u1(0) = %.4f, u2(0) = %.4f\n', u_opt(1,1), u_opt(2,1));
else
    disp('Error: Problem could not be solved.');
    disp(sol.info);
end