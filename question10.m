%% 1. Define the Scalar Function
% f(x) = |(0.5 + sin(x))(0.1 + x^2)|
% We use '.*' and '.^' so the function can work with vector inputs (for plotting)
f = @(x) abs((0.5 + sin(x)) .* (0.1 + x.^2));


%% 2. Plot the Function
figure;
fplot(f, [-10, 10]); % Plot from x = -10 to x = 10
title('Plot of f(x) = |(0.5 + sin(x))(0.1 + x^2)|');
xlabel('x');
ylabel('f(x)');
grid on;
hold on;
% Add a line at y=0 to show the global minimum
plot([-10, 10], [0, 0], 'r--', 'LineWidth', 1.5);
legend('f(x)', 'Global Minimum (y=0)');

%% 3. Find the Minimum using fminsearch
% We will try "very different initial conditions" as requested.
% Let's pick starting points (x0) from all over the plot.
x0_list = [-8, -1, 0, 3, 6];

fprintf('Running fminsearch from different initial conditions:\n');
fprintf('------------------------------------------------------\n');
fprintf('%10s | %15s | %15s\n', 'Start (x0)', 'Min. Found (x)', 'Value f(x)');
fprintf('------------------------------------------------------\n');

for i = 1:length(x0_list)
    x0 = x0_list(i);
    
    % Use fminsearch to find the local minimum
    [x_min, f_min] = fminsearch(f, x0);
    
    % Display the result
    fprintf('%10.2f | %15.6f | %15.6e\n', x0, x_min, f_min);
    
    % Plot the starting point and the found minimum
    plot(x0, f(x0), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8); % Start
    plot(x_min, f_min, 'rx', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'LineWidth', 2); % End
end
hold off;
legend('f(x)', 'Global Minimum (y=0)', 'Start Points (x0)', 'Found Minima');