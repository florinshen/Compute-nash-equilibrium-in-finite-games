% main_test.m
% Date : 2019.3.16
% reproduce the paper "An optimization formulatin to compute nash
% equilibrium in finite games"
% number of strategies mi = 5 
% number of players   N = 3
% length of vetor X  mi*N+N=18
tic
clear all;
% clc
global mi N utility_matrix
mi = 4;
N = 5;
utility_matrix = 10.*rand(mi^N,N);
X0 = zeros((mi+1)*N,1);
for i = 1:N
	sigma_temp = rand(mi,1);
	sigma_temp = sigma_temp./sum(sigma_temp);
	X0((mi*(i-1)+1):mi*i) = sigma_temp;
end
beta = 20*ones(N,1);
X0(end-N+1:end) = beta;
Aeq_origin = [ones(1,mi),zeros(1,length(X0)-mi)];
Aeq = [];
beq = ones(N,1);
for i = 1:N
	Aeq = cat(1,Aeq,circshift(Aeq_origin,mi*(i-1)));
end
lb = zeros(mi*N,1);
options = optimoptions('fmincon','Algorithm','sqp-legacy');
[x,fval,exitflag,output] = fmincon('object_fun',X0,[],[],Aeq,beq,lb,[],'nonlin',options)
toc
