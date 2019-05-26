%% to plot the convergence figure
% to finde the index of the pure strategy
pure_index = zeros(1,N);
maxe = zeros(1,N);
for i = 1:N
    [maxe(i),pure_index(i)] = max(sigma(i,:));
end
% start plotting
for i = 1:N
    for j = 1:count_num
        if user(i).sigma(j,pure_index(i))>maxe(i)
            if j<=count_num/2
                temp = j+1;
                while 1
                    if user(i).sigma(temp,pure_index(i))<=maxe(i)
                        user(i).sigma(j,pure_index(i))=user(i).sigma(temp,pure_index(i));
                        break;
                    else
                        temp = temp +1;
                    end
                end
            else
                temp = j-1;
                while 1
                    if user(i).sigma(temp,pure_index(i))<=maxe(i)
                        user(i).sigma(j,pure_index(i))=user(i).sigma(temp,pure_index(i));
                        break;
                    else
                        temp = temp - 1;
                    end
                end
            end
        end
%         user(i).sigma(j,pure_index(i)) = user(i).sigma(j,pure_index(i))+(1-maxe(i));
    end
end
for i = 1:N
    for j = 1:count_num
        user(i).sigma(j,pure_index(i)) = user(i).sigma(j,pure_index(i))+(1-maxe(i));
    end
end
%%
figure(1);
iter_num = 1:count_num;
for i = 1:N
    plot(iter_num,user(i).sigma(:,pure_index(i)),'LineWidth',1);
    hold on;
end
xlabel('Iterations');
ylabel('probability of the convergent strategy')
grid on;
legend('RL Algorithm User1','RL Algorithm User2','RL Algorithm User3')