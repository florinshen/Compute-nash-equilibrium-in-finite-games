function u = utility_find(player_index,strategy_index)
% to find the corresponding utility of the p'th player adopting the s'th strategy
	mi=5;N=3;
	persistent utility_martrix;
	if isempty(utility_martrix)
		utility_martrix=10.*rand(mi^N,N);
	end
	u = utility_martrix(strategy_index,player_index);
end
