P_points = [1 5 -1 -1 0;
            2 3  2 -2 0];

n_points = size(P_points, 2);

% Define the variables
c = sdpvar(2,1); % center of the circle

r = sdpvar(1,1); %radius

constr = [r>= 10^-3];

for i=1:n_points
    constr = [constr, norm(P_points(:,i) - c) <= r];
end

obj = r;

options = sdpsettings('solver', 'gurobi');

sol = optimize(constr, obj, options);

%solution
c_val = value(c);
r_val = value(r);


figure('Name', 'Exercise 37');
hold on;
grid on;
axis equal;

%plot the hull of points
k = convhull(P_points(1,:), P_points(2,:));
fill(P_points(1, k), P_points(2,k), 'b', 'FaceAlpha', 0.2, 'DisplayName', 'Convex Hull')
plot(P_points(1,:), P_points(2, :), 'bo', 'MarkerFaceColor', 'B', 'DisplayName','Vertices')

%plot the optimized c
p1 = plot(c_val(1), c_val(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName','Optimal Value');



% draw the circle

theta = linspace(0, 2*pi, 100); % parameter for circle
x_circle = c_val(1) + r_val * cos(theta); % x coordinates of the circle
y_circle = c_val(2) + r_val * sin(theta); % y coordinates of the circle
plot(x_circle, y_circle, 'r-', 'LineWidth', 2, 'DisplayName', 'Optimized Circle'); % plot the circle

legend;