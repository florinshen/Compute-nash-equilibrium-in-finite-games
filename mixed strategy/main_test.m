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
N = 5;
%% To generate the utility_matrix in one decision
utility_matrix = zeros(mi^N,N);
prob_index_matrix = zeros(N,mi^N);
for i = 1:N
    const = mi^(N-i);
    prob_index_matrix(i,:) = repmat(reshape(repmat((1:mi)',1,const)',1,mi*const),1,mi^(i-1));
end
speed_up_factor = [1, 0.5, 0.2, 0.8];
for i = 1:N
    user(i).release_t = 20*rand;
    user(i).process_t = 10 + 90*rand;
    user(i).communication_t = (10+90*rand)/5;
end
for i = 1:mi^N
    for j = 1:N
        if prob_index_matrix(j,i) == 1
            utility_matrix(i,j) = user(j).process_t + user(j).release_t;
        else
            compete = [];
            compete = find(prob_index_matrix(:,i) == prob_index_matrix(j,i));
            r_c_time = zeros(1,length(compete));
            r_c_time_j = user(j).communication_t +...
                user(j).release_t;
            for k = 1:length(compete)
                r_c_time(k) = user(compete(k)).communication_t +...
                    user(compete(k)).release_t;
            end
            [min_value,min_index] = min(r_c_time);
            if compete(min_index) == prob_index_matrix(j,i)
                utility_matrix(i,j) = ...
                speed_up_factor(prob_index_matrix(j,i))*user(j).process_t +...
                user(j).release_t +...
                user(j).communication_t;
            else
                utility_matrix(i,j) = ...
                speed_up_factor(prob_index_matrix(compete(min_index),i))*user(compete(min_index)).process_t +...
                user(compete(min_index)).release_t +...
                user(compete(min_index)).communication_t +...
                speed_up_factor(prob_index_matrix(j,i))*user(j).process_t;                    
                for k = 1:length(compete)
                    if (r_c_time(k)<r_c_time_j)&&(r_c_time(k)>r_c_time(min_index))
                        utility_matrix(i,j) = utility_matrix(i,j) + ...
                            speed_up_factor(prob_index_matrix(compete(k),i))*user(compete(k)).process_t;
                    end
                end                               
            end
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
%%
options = optimoptions('fmincon','MaxFunctionEvaluations',8000,'Algorithm','interior-point','HessianApproximation','bfgs','Display','iter-detailed','PlotFcn','optimplotfval','OptimalityTolerance',1e-6);
tic
[x,fval,exitflag,output,lamda] = fmincon('object_fun',X0,[],[],Aeq,beq,lb,[],'nonlin',options)
toc
find_vector = zeros(1,N);
find_vector2 = 3*ones(1,N);
for i = 1:N
    find_vector(i) = find(abs(x(((i-1)*mi+1):i*mi)-1)<1e-3) ;
end
%%    
for i = 1:length(prob_index_matrix)
    for j = 1:length(find_vector)
        if prob_index_matrix(j,i) ~= find_vector(j)
            break;
        elseif j == length(find_vector) 
            disp(find_vector);
            disp(mean(utility_matrix(i,:)));
        end
    end
    for j = 1:length(find_vector)
        if prob_index_matrix(j,i) ~= find_vector2(j)
            break;
        elseif j == length(find_vector2)
            disp(find_vector2);
            disp(mean(utility_matrix(i,:)));
        end
    end    
end