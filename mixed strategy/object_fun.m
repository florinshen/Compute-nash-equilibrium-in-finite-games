function total_u=object_fun(x)
	global mi N utility_matrix prob_index_matrix
	total_u = 0; 
	single_u = zeros(1,N);
	sigma = zeros(N,mi);
	for i=1:N
		sigma(i,:) = x(((i-1)*mi+1):i*mi);
	end
	beta = zeros(1,N);
	beta = x(i*mi+1:end);
% 	prob_index_matrix = zeros(N,mi^N);
% 	for i = 1:N
%         const = mi^(N-i);
%         prob_index_matrix(i,:) = repmat(reshape(repmat((1:mi)',1,const)',1,mi*const),1,mi^(i-1));
% 	end
	prob_matrix = ones(1,mi^N);
%   compute the prob_matrix
	for i = 1:mi^N
		for j = 1:N
			prob_matrix(i) = prob_matrix(i)*sigma(j,prob_index_matrix(j,i));
		end
	end
	
%   compute the single utility of each player
%    for i = 1:N
%		for j = 1:mi^N
%			single_u(i) = single_u(i) + prob_matrix(j)*utility_find(i,j);
%		end
%   end

% compute the single utility of each player adopting corresponding strategies
	single_u = prob_matrix*utility_matrix;
	
	total_u = sum(single_u-beta');
end                                
