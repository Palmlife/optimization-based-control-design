% --- 1. SETUP ---
clear; clc;

% Ellipsoid parameters
center = [20; 20];
Q = [10 4;
      4 10];
% Note: In the constraint x'Qx <= val, 'val' is usually radius^2.
% We will treat your 'radius' variable as the RHS scalar bound.
radius = 3; 

% --- 2. OPTIMIZATION ---
% Define the variables
x_line = sdpvar(2,1);
x_ellip = sdpvar(2,1);
x_between = sdpvar(2,1);

% Define the constraints
constr = [];

% Ellipsoid constraint: (x-c)'*Q*(x-c) <= RHS
constr = [constr, (x_ellip-center)'*Q*(x_ellip-center) <= radius];

% Line constraint: x1 = x2 + 100
constr = [constr, x_line(1) == x_line(2) + 100];

% Define objective function
% PRO TIP: Minimize the squared norm. It is mathematically equivalent
% for finding the points, but computationally easier (QP vs SOCP).
obj = norm(x_between-x_ellip)^2 + norm(x_between-x_line)^2; % norm squared otherwise every point on the line is equivalent

% Solve the optimization problem
options = sdpsettings('solver', 'gurobi', 'verbose', 0);
sol = optimize(constr, obj, options);

% Retrieve the optimal values
optimalXellip = value(x_ellip);
optimalXline = value(x_line);
optimalXbetween = value(x_between);
min_dist = norm(optimalXline - optimalXellip);

% Display results
fprintf('Solver Status: %s\n', sol.info);
fprintf('Minimal Distance: %f\n', min_dist);
fprintf('Optimal x_ellip: [%f, %f]\n', optimalXellip(1), optimalXellip(2));
fprintf('Optimal x_line:  [%f, %f]\n', optimalXline(1), optimalXline(2));

% --- 3. PLOTTING ---
figure;
hold on;
grid on;
axis equal; % Crucial to see the actual geometry and distance

% A. Plot the Correct Ellipsoid
th = linspace(0, 2*pi, 100);

[V,D] = eig(Q/(2*radius))

radii = 1./sqrt(diag(D));

%transform circle ppitns to ellipsoid points
ellip_points = V * [radii(1)*cos(th);
                    radii(2)*sin(th)] +center;

fill(ellip_points(1,:), ellip_points(2, :), 'r', 'FaceAlpha', 0.1, 'DisplayName','Ellipsoid');

% B. Plot the Line
% The optimal line point is likely far from the center, so we center the plot
% around the solution
plot_range = linspace(optimalXline(2)-10, optimalXline(2)+10, 100);
% Line eq: x1 = x2 + 100
plot(plot_range + 100, plot_range, 'r--', 'LineWidth', 1.5);

% C. Plot the connection (The Distance)
plot([optimalXellip(1) optimalXline(1)], [optimalXellip(2) optimalXline(2)], 'k-', 'LineWidth', 1.5);

% D. Plot the optimal points
p1 = plot(optimalXellip(1), optimalXellip(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
p2 = plot(optimalXline(1), optimalXline(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
p3 = plot(optimalXbetween(1), optimalXbetween(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'g');

legend([p1, p2, p3], 'Optimal Ellipsoid Point', 'Optimal Line Point', 'Optimal point in between');
title(sprintf('Min Distance: %.4f', min_dist));
hold off;