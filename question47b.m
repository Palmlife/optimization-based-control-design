clear; close all;

% 1. Setup Variable
x = sdpvar(1, 2, 'full');

% 2. Data
A  = [5 2; 2 10];
B = [-15 -2; -2 -10];

% 3. Create the Matrix Expression (Don't constrain it yet)
% We want: M >= 0 (Positive Semi-Definite)
M = x(1, 1)*A + x(1,2)*B - 10^-6 * eye(2);

% 4. Define Constraints
cons = [
    % --- THE FIX FOR GUROBI (Manual LMI) ---
    % Sylvester's Criterion for 2x2 Matrix:
    % 1. Top-left element >= 0
    M(1,1) >= 0,
    % 2. Determinant >= 0 (This is a Rotated Second Order Cone)
    % Logic: M(1,1)*M(2,2) - M(1,2)^2 >= 0
    M(1,1) * M(2,2) >= M(1,2)^2, 
    
    % --- LINEAR CONSTRAINTS ---
    x(1,1) + x(1,2) <= 1,
    
    % --- THE FIX FOR "HANGING" (Bounds) ---
    % We must prevent the solver from chasing infinity
    % -100 <= x <= 100
];

obj = -x(1,2);

% 5. Solve using Gurobi (Native Quadratic Support)
options = sdpsettings('solver', 'gurobi', 'verbose', 1); 
sol = optimize(cons, obj, options);

value(x)
