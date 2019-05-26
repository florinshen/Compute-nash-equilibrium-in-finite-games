% main_test.m
% Date : 2019.3.16
% reproduce the paper "Gaming and Learning Approaches for
% multi-user computation offloading"
% number of strategies mi = 5 
% number of players   N = 3
% length of vetor X  mi*N+N = (mi+1)*n = 18
clear all;clc
global mi N  
mi = 4;
N = 3;
speed_up_factor = [1, 0.5, 0.01, 0.8];
for i = 1:N
    user(i).release_t = 20*rand;
    user(i).process_t = 10+90*rand;
    user(i).communication_t = (10+90*rand)/5;
end
%% Erev-Roth RL model
z = zeros(N,mi);
e = zeros(N,mi);
sigma = zeros(N,mi);
count = 0;
for i = 1:N
    for j = 1:mi
        if j ==1
            z(i,j) = user(i).process_t;
        else
            z(i,j) = user(i).process_t/speed_up_factor(j);
        end
    end
end
while 1
    for i = 1:N
        user(i).release_t = 20*rand;
        user(i).process_t = 10+90*rand;
        user(i).communication_t = (10+90*rand)/5;
    end
    z = zeros(N,mi);
    e = zeros(N,mi);
    for i = 1:N
        for j = 1:mi
            if j ==1
                z(i,j) = user(i).process_t;
            else
                z(i,j) = user(i).process_t/speed_up_factor(j);
            end
        end
    end
    
    for i = 1:N
        for j = 2:mi
            completion_time = user(i).process_t*speed_up_factor(j)+...
                              user(i).communication_t;
            local_time = user(i).process_t;
            if local_time > completion_time
                e(i,:) = zeros(1,mi);
                e(i,j) = 1;
                z(i,:) = z(i,:)+(local_time-completion_time).*e(i,:);
            else
                e(i,:) = zeros(1,mi);
                e(i,1) = 1;
                z(i,:) = z(i,:)+(completion_time-local_time).*e(i,:);
            end
        end
        sigma(i,:) = z(i,:)./sum(z(i,:));
    end
    count = count + 1;
    if count == 100
        disp(sigma);
        break;
    end
end