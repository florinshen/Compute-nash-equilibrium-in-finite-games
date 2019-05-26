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
N = 3;
speed_up_factor = [1, 0.5, 0.2, 0.8];
%% To generate the prob_index_matrix
prob_index_matrix = zeros(N,mi^N);
for i = 1:N
    const = mi^(N-i);
    prob_index_matrix(i,:) = repmat(reshape(repmat((1:mi)',1,const)',1,mi*const),1,mi^(i-1));
end 
%% Initial the Erev-Roth model
z = zeros(N,mi);
e = zeros(N,mi);
sigma = zeros(N,mi);
count = 0;
count_num = 500;
flag = 0; 
utility_matrix = zeros(mi^N,N);
for i = 1:N
    user(i).sigma = zeros(count_num,mi);
end
%% start the erev-roth learning iteration
while 1
%% Generate the utility matrix in one offloading
    utility_matrix = zeros(mi^N,N);
    for i = 1:N
        user(i).release_t = 20*rand;
        user(i).process_t = 10+90*rand;
        user(i).communication_t = (10+90*rand)/5;
        if flag == 0
            flag = 1;
            for j = 1:mi
                if j ==1
                    z(i,j) = user(i).process_t;
%                     z(i,j)=0;
                else
                    z(i,j) = user(i).process_t/speed_up_factor(j);
%                     z(i,j) = user(i).process_t*(1-speed_up_factor(j));
                end
            end
        end
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
%% learn in this time of offloading
    for i = 1:N
        for j = 1:mi^N
            local_time = user(i).release_t + user(i).process_t;
            if utility_matrix(j,i) - local_time > 1e-6
                e(i,:) = zeros(1,mi);
                e(i,1) = 1;
                z(i,:) = z(i,:) + (utility_matrix(j,i)-local_time).*e(i,:);
            elseif local_time - utility_matrix(j,i) > 1e-6
                e(i,:) = zeros(1,mi);
                e(i,prob_index_matrix(i,j)) = 1;
                z(i,:) = z(i,:)+(local_time-utility_matrix(j,i)).*e(i,:);
            end
        end
        sigma(i,:) = z(i,:)./sum(z(i,:));
    end
    
    count = count + 1;
    if count == count_num
        disp(sigma);
        break;
    else
        for i = 1:N
            user(i).sigma(count+1,:) = sigma(i,:);
        end
    end
end

%% to plot the convergence figure
% to finde the index of the pure strategy
pure_index = zeros(1,N);
for i = 1:N
    [maxi,pure_index(i)] = max(sigma(i,:));
end
% start plotting
figure(1);
iter_num = 1:count_num;
for i = 1:N
    plot(iter_num,user(i).sigma(:,pure_index(i)));
    hold on;
end
grid on;