function [c,ceq] = nonlin(x)
	global mi N utility_matrix prob_index_matrix
	sigma = zeros(N,mi);
	for i=1:N
		sigma(i,:) = x(((i-1)*mi+1):i*mi);
	end
	beta = zeros(1,N);
	beta = x(i*mi+1:end);
	
	c = zeros(N*(mi^N),1);
	
% 	prob_index_matrix = zeros(N,mi^N);
% 	for i = 1:N
%         const = mi^(N-i);
%         prob_index_matrix(i,:) = repmat(reshape(repmat((1:mi)',1,const)',1,mi*const),1,mi^(i-1));
% 	end
	
	% compute the prob_matrix
	prob_matrix = ones(N,mi^N);
	for k = 1:N
		for i = 1:mi^N
			for j = 1:N
				if j ~= k
					prob_matrix(k,i) = prob_matrix(k,i)*sigma(j,prob_index_matrix(j,i));
				end
			end
		end
	end
	
	% compute the c matrix
	for i = 1:N
		c(((mi^N)*(i-1)+1):(mi^N)*i) = beta(i)-prob_matrix(i,:)'.*utility_matrix(:,i);
	end
	ceq = [];
end