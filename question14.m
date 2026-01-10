% Generalized version of question13: visit n targets (within radii) between x0 and x_g
% Requires YALMIP

% example params (change as needed)
x0 = [-2; 1];
x_g = [9; 8];
% define 7 targets as a 2 x 7 matrix (columns are target coordinates)
p = [0, 1.5, 3, 4.5, 6, 7.5, 9; 2, 5, 1, 6, 3, 7, 4];    % 2 x 7 (more spread)
% radii: scalar or 1 x n vector
r = 0.7;   

%% validate / normalize inputs
if size(p,1) ~= 2
    error('p must be a 2 x n matrix of target coordinates.');
end
n = size(p,2); % number of targets
if isscalar(r)
    r = repmat(r,1,n);
elseif numel(r) ~= n
    error('r must be scalar or a vector of length n.');
end
r = reshape(r,1,n);

%% decision variables: 2 x (n+2) points: [x0, way1..way_n, x_g]
X = sdpvar(2, n+2);

%% constraints
cons = [];
cons = [cons, X(:,1) == x0];           % start fixed
for i = 1:n
    cons = [cons, norm(X(:,i+1) - p(:,i)) <= r(i)]; % waypoint i within radius of target i
end
cons = [cons, X(:,n+2) == x_g];        % goal fixed

%% objective: minimize total path length (sum of Euclidean norms)
obj = 0;
for k = 1:(n+1)
    obj = obj + norm(X(:,k+1) - X(:,k));
end

%% solve
options = sdpsettings('verbose',1,'solver','gurobi','gurobi.BarHomogeneous',1);
sol = optimize(cons, obj, options);
if sol.problem ~= 0
    disp(['Solver returned problem code: ' num2str(sol.problem)]);
    if isfield(sol,'info'), disp(sol.info); end
    return;
end

Xopt = value(X);  % 2 x (n+2)

%% Visualization
figure;
hold on; grid on; axis equal;
% colored segments
colors = lines(n+1); % n+1 segments
hSeg = gobjects(n+1,1);
for k = 1:(n+1)
    xA = Xopt(:,k); xB = Xopt(:,k+1);
    hSeg(k) = plot([xA(1), xB(1)], [xA(2), xB(2)], '-o', 'Color', colors(k,:), 'LineWidth', 1.8);
end

% polyline through all points
allPts = Xopt;
hPath = plot(allPts(1,:), allPts(2,:), 'k--', 'LineWidth', 1.2);

% plot targets and circles
hTargets = gobjects(n,1);
hCircles = gobjects(n,1);
t = linspace(0,2*pi,200);
for i = 1:n
    hTargets(i) = scatter(p(1,i), p(2,i), 50, 'k', 'filled');
    circ = p(:,i) + r(i)*[cos(t); sin(t)];
    hCircles(i) = plot(circ(1,:), circ(2,:), 'k--', 'LineWidth', 1);
end

xlabel('X'); ylabel('Y');
title(sprintf('Optimal path visiting %d targets', n));
legendEntries = [arrayfun(@(k) sprintf('seg %d',k), 1:(n+1), 'UniformOutput', false), {'polyline','targets','target circles'}];
legend([hSeg; hPath; hTargets(1); hCircles(1)], legendEntries([1:(n+1), n+2, n+3, n+4]), 'Location','bestoutside');
hold off;

% Xopt contains the optimized points: columns are [x0, way1..way_n, x_g]
disp('Optimized points (columns):');
disp(Xopt);