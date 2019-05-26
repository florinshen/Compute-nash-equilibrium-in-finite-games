% main_test.m
% Date : 2019.3.16
% reproduce the paper "Gaming and Learning Approaches for
% multi-user computation offloading"
% number of strategies mi = 5 
% number of players   N = 3
% length of vetor X  mi*N+N = (mi+1)*n = 18
clear all;clc
global mi N utility_matrix prob_index_matrix
mi = 4;
N = 6;
%% To generate the utility_matrix in one decision
utility_matrix = zeros(mi^N,N);
prob_index_matrix = zeros(N,mi^N);
for i = 1:N
    const = mi^(N-i);
    prob_index_matrix(i,:) = repmat(reshape(repmat((1:mi)',1,const)',1,mi*const),1,mi^(i-1));
end
speed_up_factor = [1, 0.1, 0.8, 0.1];
for i = 1:N
    user(i).release_t = 20*rand;
    user(i).process_t = 10+90*rand;
    user(i).communication_t = (10+90*rand)/5;
end
for i = 1:mi^N
    for j = 1:N
        if prob_index_matrix(j,i) == 1
            utility_matrix(i,j) = user(j).process_t + user(j).release_t;
        else
            for k = 1:N
                if k == j
                    continue;
                else
                    if prob_index_matrix(k,i) == prob_index_matrix(j,i)
                        if (user(k).release_t+user(k).communication_t)<...
                                (user(j).release_t+user(j).communication_t)
                        utility_matrix(i,j) = ...
                        utility_matrix(i,j) +...
                        speed_up_factor(prob_index_matrix(k,i))*user(k).process_t +...
                        user(k).release_t +...
                        user(k).communication_t;
                        end
                    end
                end
            end
            utility_matrix(i,j) = ...
            utility_matrix(i,j) +...
            speed_up_factor(prob_index_matrix(j,i))*user(j).process_t +...
            user(j).release_t+...
            user(j).communication_t;                 
        end
    end
end
        
    
%%
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
options = optimoptions('fmincon','Algorithm','sqp');
tic
[x,fval,exitflag,output] = fmincon('object_fun',X0,[],[],Aeq,beq,lb,[],'nonlin',options)
toc