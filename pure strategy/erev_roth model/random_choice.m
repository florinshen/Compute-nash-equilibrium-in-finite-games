function choice = random_choice(xk,prob)
   %% generate random number under discrete probability distribution
   counter = 0;
   choice = 0;
   for i = 1:length(xk)
       if  prob(i) ~= 0
          counter = counter + 1;
       end
   end
   
   %% reconstructe the xk and prob vector
   xk_rc = zeros(1,counter);
   prob_rc = zeros(1,counter);
   index = 0;
   for i = 1:length(xk)
       if prob(i) ~= 0
           index = index + 1;
           xk_rc(index) = xk(i);
           prob_rc(index) = prob(i);
       end
   end
   
   %% calculate cumulative probability
   cum_prob = zeros(1,counter);
   for i = 1:counter
        for j = 1:i
            cum_prob(i) = cum_prob(i) + prob_rc(j);
        end
   end
   
   %% to generate the random choice
   random_seed = rand;
   if random_seed <= cum_prob(1)
       choice = xk_rc(1);
   else
       for i = 1:length(cum_prob)-1
           if (random_seed > cum_prob(i))&&(random_seed <= cum_prob(i+1))
               choice = xk_rc(i+1);
           end
       end
   end
end