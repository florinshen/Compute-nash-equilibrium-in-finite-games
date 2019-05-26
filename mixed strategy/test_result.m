% To test the result
global N mi
for i = 1:N
	summ = sum(x((mi*(i-1)+1):mi*i));
	disp(['the sum of probibility of player ',num2str(i),' is',' ',num2str(summ)]);
end

[c_result , ceq ] = nonlin(x);
index = find(c_result(:)>1e-10);
if ~isempty(index)
    for i = 1:length(index)
        disp(c_result(index(i)));
    end
end