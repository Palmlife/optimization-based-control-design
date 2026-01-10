P_points = [1 5 -1 -1 0;
            2 3  2 -2 0];

n_points = size(P_points, 2);

%ellipsoid param
center = [20; 20];
Q = [10 4;
      4 10];
radius = 3;


%% minimal euclidean distance

x_poly = sdpvar(2,1); %point on the polyhedron

x_ellip = sdpvar(2,1); %point on the ellipsoid

lambda = sdpvar(n_points, 1); %convex combination weights for x_poly 

%constraints
constr = [];

%convex hull

constr = [constr, x_poly == P_points*lambda];
constr = [constr, lambda >= 0];
constr = [constr, sum(lambda) == 1];

% x_ellip must be inside the ellipsoid

constr = [constr, (x_ellip - center)'*Q*(x_ellip - center)<=radius];

%define objective

objective = norm(x_ellip-x_poly);

%solve problem
options = sdpsettings('solver', 'gurobi', 'debug',1)
sol = optimize(constr,objective, options)

%% ploting
figure('Name', 'Exercise 34: Geometry opitmisation');
hold on;
grid on;
axis equal;

k = convhull(P_points(1,:), P_points(2,:));

fill(P_points(1, k), P_points(2,k), 'b', 'FaceAlpha', 0.2, 'DisplayName', 'Convex Hull')

plot(P_points(1,:), P_points(2, :), 'bo', 'MarkerFaceColor', 'B', 'DisplayName','Vertices')

% Extract the optimal points from the solution
optimalXPoly = value(x_poly)
optimalXEllip = value(x_ellip)

% plot the ellipsoid

% use eigen decomposition to find shape and orientation

th = linspace(0, 2*pi, 100);

[V,D] = eig(Q/radius)

radii = 1./sqrt(diag(D));

%transform circle ppitns to ellipsoid points
ellip_points = V * [radii(1)*cos(th);
                    radii(2)*sin(th)] +center;

fill(ellip_points(1,:), ellip_points(2, :), 'r', 'FaceAlpha', 0.1, 'DisplayName','Ellipsoid');

% plot the optimisation result

plot(optimalXPoly(1), optimalXPoly(2), 'ko', 'MarkerFaceColor', 'g', 'DisplayName', 'Optimal Point on Polyhedron');
plot(optimalXEllip(1), optimalXEllip(2), 'ko', 'MarkerFaceColor', 'm', 'DisplayName', 'Optimal Point on Ellipsoid');
legend show;