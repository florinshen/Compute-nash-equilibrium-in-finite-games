% SQP algorithm for nonlinear problems with 
%     facname: function that evaluates the objective and 
%              constraint functions
%       gname: function that evaluates the gradient of the 
%              objective and constraint functions
%       zname: function that evaluates the Hessian of the 
%              objective and constraint functions
%          x0: initial point
%   lmd0, mu0: initial Lagrange multipliers
%        epsi: termination tolerance
% Output:
%   xs: solution point
%   fs: objective function evaluated at xs.
%   k: number of iterations at convergence
function [xs,fs,k] = sqp_general(facname,gname,x0,p,q,epsi)
xk = x0(:);
n = length(xk);
p1 = p + 1;
In = eye(n);
Zk = In;
fack = feval(facname,xk);
ak = fack(2:p1);
ck = fack((p1+1):(p1+q));
Gk = feval(gname,xk);
gk = Gk(:,1);
Aek = Gk(:,2:p1)';
Aik = Gk(:,(p1+1):(p1+q))';
k = 0;
d = 1;
while d >= epsi,
   d_x = qp_general(Zk,gk,Aek,-ak,Aik,-ck,zeros(n,1),epsi);
   dd = Aik*(xk+d_x) + ck;
   ind = find(dd <= 1e-5);
   ssi = length(ind);
   muk = zeros(q,1);
   if ssi == 0,
      lmd = inv(Aek*Aek')*Aek*(Zk*d_x+gk);
   else
      Aaik = Aik(ind,:);
      Aak = [Aek; Aaik];
      zmu = inv(Aak*Aak')*Aak*(Zk*d_x+gk);
      lmd = zmu(1:p);
      mukh = zmu(p1:end);
      muk(ind) = mukh;
   end
   ala = lsearch_powell_m(facname,xk,d_x,p1,muk);
   d_x = ala*d_x;
   xk = xk + d_x;
   Gk1 = feval(gname,xk);
   gk1 = Gk1(:,1);
   Aek1 = Gk1(:,2:p1)';
   Aik1 = Gk1(:,(p1+1):(p1+q))';
   gama_k = (gk1-gk)-(Aek1-Aek)'*lmd-(Aik1-Aik)'*muk;
   qk = Zk*d_x;
   dg = d_x'*gama_k;
   ww = d_x'*qk;
   if dg >= 0.2*ww,
      thet = 1;
   else
      thet = 0.8*ww/(ww-dg);
   end
   eta = thet*gama_k + (1-thet)*qk;
   phi = 1/ww;
   cta = 1/(d_x'*eta);
   Zk = Zk + cta*(eta*eta') - phi*(qk*qk');
   Aek = Aek1;
   Aik = Aik1;
   gk = gk1;
   fack = feval(facname,xk);
   ak = fack(2:p1);
   ck = fack((p1+1):(p1+q));
   k = k + 1;
   d = norm(d_x);
end
xs = xk;
fs = fack(1);