% train_model.m
% Date : 2019.3.29
% reproduce the paper "Gaming and Learning Approaches for
% multi-user computation offloading"
% the erev-roth reinforcement learning algorithm
% number of strategies mi = 4 
% number of players   N = 3
clear all;
% clc
global mi N utility_matrix prob_index_matrix
mi = 4;
N = 3;
speed_up_factor = [1, 0.5, 0.2, 0.8];
%% Initial the Erev-Roth model
z = zeros(N,mi);
e = zeros(N,mi);
sigma = zeros(N,mi);
count = 0;
count_num = 1000;
utility_matrix = zeros(mi^N,N);
for i = 1:N
    user(i).sigma = zeros(count_num,mi);
end

% initial the z vector and sigma vector
for i = 1:N
    user(i).release_t = 20*rand;
    user(i).process_t = 10+90*rand;
    user(i).communication_t = (10+90*rand)/5;
    for j = 1:mi
        if j ==1
            z(i,j) = user(i).process_t;
        else
            z(i,j) = user(i).process_t/speed_up_factor(j);
        end
    end
    sigma(i,:) = z(i,:)./sum(z(i,:));
end
flag = 0;
offloading_decision = zeros(1,N);
completion_time = zeros(1,N);
%% start the erev-roth learning iteration
while 1

    for i = 1:N
        offloading_decision(i) = random_choice(1:mi,sigma(i,:));
    end
    
    for i = 1:N
        if offloading_decision(i) == 1
            completion_time(i) = user(i).process_t + user(i).release_t;
        else
            compete = [];
            compete = find(offloading_decision(:) == offloading_decision(i));
            r_c_time = zeros(1,length(compete));
            r_c_time_i = user(i).communication_t +...
                user(i).release_t;
            for j = 1:length(compete)
                r_c_time(j) = user(compete(j)).communication_t +...
                    user(compete(j)).release_t;
            end
            [min_value,min_index] = min(r_c_time);
            if compete(min_index) == i
                completion_time(i) = ...
                speed_up_factor(offloading_decision(i))*user(i).process_t +...
                user(i).release_t +...
                user(i).communication_t;
            else
                completion_time(i) = ...
                speed_up_factor(offloading_decision(compete(min_index)))*user(compete(min_index)).process_t +...
                user(compete(min_index)).release_t +...
                user(compete(min_index)).communication_t +...
                speed_up_factor(offloading_decision(i))*user(i).process_t;                    
                for k = 1:length(compete)
                    if (r_c_time(k)<r_c_time_i)&&(r_c_time(k)>r_c_time(min_index))
                        completion_time(i) = completion_time(i) + ...
                            speed_up_factor(offloading_decision(compete(k)))*user(compete(k)).process_t;
                    end
                end                               
            end
        end
    end

%% learn in this time of offloading
    for i = 1:N
        local_time = user(i).release_t + user(i).process_t;
        if completion_time(i) - local_time > 1e-6
            e(i,:) = zeros(1,mi);
            e(i,1) = 1;
            z(i,:) = z(i,:) + ((completion_time(i)-local_time)).*e(i,:);
         elseif local_time - completion_time(i) > 1e-6
            e(i,:) = zeros(1,mi);
            e(i,offloading_decision(i)) = 1;
            z(i,:) = z(i,:)+(local_time-completion_time(i)).*e(i,:);
        end
        sigma(i,:) = z(i,:)./sum(z(i,:));
    end
    
    for i = 1:N
        clr_vec = [];
        clr_vec = find(sigma(i,:)<0.05);
        for j = 1:length(clr_vec)
            sigma(i,clr_vec(j)) = 0;
        end
        sigma(i,:) = sigma(i,:)./sum(sigma(i,:));
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
    
    for i = 1:N
        user(i).release_t = 20*rand;
        user(i).process_t = 10+90*rand;
        user(i).communication_t = (10+90*rand)/5;
    end
    
end
mean(completion_time)
% to plot the convergence figure
% to finde the index of the pure strategy
pure_index = zeros(1,N);
for i = 1:N
    [maxi,pure_index(i)] = max(sigma(i,:));
end
%% start plotting
figure(1);
iter_num = 1:count_num;
for i = 1:N
    plot(iter_num,user(i).sigma(:,pure_index(i)),'LineWidth',1);
    hold on;
end
% legend('RL Algorithm:User 1','RL Algorithm:User 2','RL Algorithm:User 3');
legend('用户1','用户2','用户3')
grid on;
% xlabel('Iterations');
xlabel('迭代次数')
% ylabel('probability of the convergent strategy')
ylabel('收敛策略的概率')