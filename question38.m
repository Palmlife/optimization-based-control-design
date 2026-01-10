Points = [ 1,  2; 
           5,  3; 
          -1,  2; 
          -1, -2; 
           0,  0];

% Points = [ 1,  2; 
%            5,  3; 
%           -1,  2; 
%           -1, -2; 
%            0,  0;
%            4, -1];

n_points = size(Points, 2);

% find indices of the points that make the convex hull
k = convhull(Points(:,1), Points(:,2))

% extract vertices (remove the duplicate end point
HullVertices = Points(k(1:end-1), :);

num_edges = size(HullVertices, 1);
A = zeros(num_edges, 2);
b = zeros(num_edges, 1);

% Calculate the center to determine which way is "in" vs "out"
centroid = mean(HullVertices);

for i = 1:num_edges
    % Get the two points defining the current edge
    p_start = HullVertices(i, :);
    p_end   = HullVertices(mod(i, num_edges) + 1, :); % Wrap around to 1
    
    % Vector along the edge
    edge_vec = p_end - p_start;
    
    % Calculate Normal Vector (Rotate edge 90 degrees)
    % If edge is [dx, dy], normal is [-dy, dx]
    normal = [-edge_vec(2), edge_vec(1)];
    
    % Normalize the vector (make length 1)
    normal = normal / norm(normal);
    
    % Ensure normal points OUTWARD
    % We check the dot product with the vector from centroid to edge.
    % If dot > 0, it points towards the centroid (inward), so we flip it.
    if dot(normal, centroid - p_start) > 0
        normal = -normal;
    end
    
    % Store A and b for this edge constraint: normal * x <= b
    A(i, :) = normal;
    b(i)    = dot(normal, p_start);
end

% Define the variables
c = sdpvar(2,1); % center of the circle
r = sdpvar(1,1); %radius


% define the constraint such that the circle is contained in the polyhedron
Constr = [];

Constr = [Constr, r >= 0];

% For every linear inequality a_i*x <= b_i defining the hull,
% the ball is contained if: a_i*xc + r*||a_i|| <= b_i
for i = 1:length(b)
    Constr = [Constr, A(i,:)*c + r*norm(A(i,:)) <= b(i)];
end

optimize(Constr, -r)

clf;
fill(Points(k,1), Points(k,2), 'c', 'FaceAlpha', 0.1); hold on;
plot(Points(:,1), Points(:,2), 'ko', 'MarkerFaceColor', 'k');
viscircles(value(c)', value(r), 'Color', 'r');
axis equal;
title('Exercise 38: Max Inscribed Circle');