% ====================================================================================
% CPLEX 
% ====================================================================================
clear 
load regionCPLEX.mat
% load globalCPLEX.mat 

yalmip('clear');

%% define constraints
cons = [];

%% variables
x = intvar(satNum,areatargetNum);
for j=1:areatargetNum
    r(j)=hjtp(j)-w(:,j)'*x(:,j);
end
%% objectives
maxr=max(r);

%% constraints
for i = 1:satNum
    for j=1:areatargetNum
        count(i,j)=min(x(i,j),1);
    end
end

cons = [cons, sum(x,2)+(sum(count,2)-1)<=timeduration];

for i=1:satNum
    for j=1:areatargetNum
        cons = [cons, x(i,j)>=0];
    end
end

st = clock;

%% find the solution
options = sdpsettings('solver','cplex','verbose',2,'debug',1);
optimize(cons,maxr);

et = clock;
cplexTime = etime(et,st);

%% Get the result
x = double(x);
maxr = double(maxr);






