% given two targets in R^2, p1 and P2 a starting point x_0 and 
% an end point x_g, try to find the minimal legnth trajectory 
% composed of 3 segments such that it start in x_0, arrives at least
% r from p1,p2 and then go to x_f . Define the associated optimization
% problem and build (in MPT) a function that computes the optimal 
% solution to this problem



% Start and goal far apart (forces longer path with potential detours)
x0 = [-2; 1];
x_g = [9; 8];

% Two targets placed so the path must bend; use small radii to make constraints tight
p1 = [3; 4.2];
p2 = [6.2; 1.4];
r = 0.7; % small radius -> more constrained placement of waypoints



% Define the optimization variables and constraints
x = sdpvar(2, 4); % 2D points for the trajectory segments
constraints = [x(:,1) == x0, norm(x(:,2) - p1) <= r, norm(x(:,3) - p2) <= r, x(:,4) == x_g];

% Define the objective function to minimize the total trajectory length
cost = norm(x(:,2) - x(:,1)) + norm(x(:,3) - x(:,2)) + norm(x(:,4) - x(:,3));

% Set up the optimization problem
optimize(constraints, cost);

% Check if the optimization was successful
% if optimize(constraints, cost) == 0
%     disp('Optimal trajectory found.');
% else
%     disp('Optimization failed.');
% end

% Retrieve the optimal trajectory points
optimalTrajectory = value(x);


% Visualize the optimal trajectory
figure;
% plot individual segments (kept for colored segments)
h1 = plot([x0(1), optimalTrajectory(1,1)], [x0(2), optimalTrajectory(2,1)], 'r-o', 'LineWidth', 2); hold on;
h2 = plot([optimalTrajectory(1,1), optimalTrajectory(1,2)], [optimalTrajectory(2,1), optimalTrajectory(2,2)], 'g-o', 'LineWidth', 2);
h3 = plot([optimalTrajectory(1,2), optimalTrajectory(1,3)], [optimalTrajectory(2,2), optimalTrajectory(2,3)], 'b-o', 'LineWidth', 2);
h4 = plot([optimalTrajectory(1,3), x_g(1)], [optimalTrajectory(2,3), x_g(2)], 'm-o', 'LineWidth', 2);

% draw a single polyline connecting all points in order
allPoints = [x0, optimalTrajectory(:,1:3), x_g];
hLine = plot(allPoints(1,:), allPoints(2,:), 'k--', 'LineWidth', 1.2);

% plot targets
h5 = scatter(p1(1), p1(2), 50, 'k', 'filled');
h6 = scatter(p2(1), p2(2), 50, 'k', 'filled');

% draw circles of radius r around p1 and p2
t = linspace(0,2*pi,200);
circ1 = p1 + r*[cos(t); sin(t)];
circ2 = p2 + r*[cos(t); sin(t)];
h7 = plot(circ1(1,:), circ1(2,:), 'k--', 'LineWidth', 1.5);
h8 = plot(circ2(1,:), circ2(2,:), 'k--', 'LineWidth', 1.5);

xlabel('X-axis');
ylabel('Y-axis');
title('Optimal Trajectory');
legend([h1 h2 h3 h4 hLine h5 h7], {'Start segment','Segment 1','Segment 2','Segment 3','Full path','Targets','Target circles'});
grid on;
hold off;
