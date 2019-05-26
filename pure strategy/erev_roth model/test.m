clear all;clc
xk = [-1,1,2,3];
pb = [0.3,0.2,0.4,0.1];
vec = zeros(1,10000);
for i = 1:length(vec)
    vec(i) = random_choice(xk,pb);
end
figure(1);
hist(vec);