% clear all;clc
global mi N utility_matrix prob_index_matrix
mi = 4;
N = 2;
load('u.mat', 'utility_matrix')
%% Erev-Roth Learning
z = zeros(N,mi);
e = zeros(N,mi);
sigma = zeros(N,mi);
count = 0;
count_num = 500;
for i = 1:N
    user(i).sigma = zeros(count_num,mi);
end
while 1
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