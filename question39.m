clear; close all;

x_line = sdpvar(2,1,'full');
x_ellip = sdpvar(2,1,'full');

A = [5,2;2,10];
B = [15,-2;-2,10];

constr= [];
constr= [constr, x_ellip'*A*x_ellip <= 1]
constr = [constr, x_ellip'*B*x_ellip <= 1];
constr = [constr, x_line(1,1) <= 100, x_line(1,1) >= 99, x_line(2,1) == 4];

% minimal distance is convex, maximal is not
obj = norm(x_line- x_ellip);
options = sdpsettings('solver', 'gurobi');
sol = optimize(constr, obj, options);

disp('Optimal x_line:');
disp(value(x_line));
disp('Optimal x_ellip:');
disp(value(x_ellip));

% plot

figure;
hold on;
grid on;
axis equal;

fimplicit(@(x1, x2) x1^2/A(1,1) + x2^2/A(2,2) - 1, 'r', 'LineWidth', 1.5);
fimplicit(@(x1, x2) x1^2/B(1,1) + x2^2/B(2,2) - 1, 'b', 'LineWidth', 1.5);
plot(value(x_line(1)), value(x_line(2)), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
plot(value(x_ellip(1)), value(x_ellip(2)), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
legend('Ellipse A', 'Ellipse B', 'Optimal x\_line', 'Optimal x\_ellip');
xlabel('x_1');
ylabel('x_2');
title('Optimal Points and Constraints');
hold off;
