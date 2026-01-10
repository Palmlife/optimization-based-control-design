%%%%% fminsearch for unconstrained optimization
%% fmincon for constrained optimization

%%sdpvar(n,m,'full') it generate n by m matrix of (if not full then matrix will contain same on upper and lower triangles ) 
%% F = [expression] it is needed to generate constraints 
%%optimize(constraints,costfunction,options) to solve the optimizaation problem
%% double(variables) to get the obtained optimal value 
%clear all;close all;clc;

C      = [[0;0],[10;0]]; % center of circle 
P      = sdpvar(2,1,'full'); % the point p1 is P(:,1) others are p2 and p3
constr = [norm(P - [6;7])<=1];
F      = constr;
cost   = 2*norm(P-C(1)) + norm(P-C(2));
msg    = optimize(constr,cost);

disp(double(P))