function a = lsearch_powell_m(facname,xk,d_x,p1,muk)
bt = 100;
q = length(muk);
aa = 0:0.01:1;
ps = zeros(101,1);
for i = 1:101,
    ai = aa(i);
    xdi = xk + ai*d_x;
    fack = feval(facname,xdi);
    ak = fack(2:p1);
    ck = fack((p1+1):(p1+q));
    ps(i) = fack(1) + bt*sum(ak.^2)- muk'*ck;
end
[psm,ind] = min(ps);
a1 = aa(ind);
ind1 = find(muk <= 1e-5);
s1 = length(ind1);
if s1 == 0,
   a = 0.95*a1;
else
   dk = zeros(s1,1);
   for i = 1:s1,
       for j = 1:101,
           aj = aa(j);
           xdj = xk + aj*d_x;
           fcj = feval(facname,xdj);
           ckj = fcj((p1+1):(p1+q));
           ps(j) = ckj(ind1(i));
       end
       ind2 = find(ps < 0);
       s2 = length(ind2);
       if s2 == 0,
          dk(i) = 1;
       else
          dk(i) = aa(ind2(1)-1);
       end
   end
   a2 = min(dk);
   a = 0.95*min(a1,a2);
end 