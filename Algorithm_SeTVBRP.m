clear
load region.mat
% load global.mat
warning('off');

% This is the code for algorithm SeTVBRP
% The result is storage in 'result_record', which is the result of 50 runs

% The formula of 'result_record' is [worst_result best_result average_result CPUtime var_result opt_sol_num]
% The task load is represent by 'hjtp', and the 'avsatall' represent all satellite that visible to all grids

timepart{tp,1} = sortrows(timepart{tp,1},1);

Mvalue = getNewM( tp,hj,timepart, timeduration,verepsilon );

avalloc = getInitialAlloc(avsatall,timepart,tp, hj,timeduration,punish);

result_record = [];
result_for_r = [];
iteration_all = [];
for r = 1:maxR
    rng(r);% Set random seed
    verepsilon = 15.4;
    verepsilon_initial = 15.4;
    pttest = [];
    iteration_inf = []; % [t objective_value]
    pcord = [];
    
    % Get Initial Solution
    [allopairtp,avtask,ctime] = getInitialSol(timepart,tp,avsatall,hj,timeduration,areatargetNum,punish);
    
    st = clock;
    
    Mvalue = getNewM(  tp,hj,timepart,timeduration,verepsilon );
    
    for t=1:maxT
        if max(ctime(:,2))>0
            
            if t>=tau*maxT
                verepsilon = max(1,verepsilon_initial-(t-tau*maxT)*xi);
                Mvalue = getNewM(  tp,hj,timepart, timeduration,verepsilon );
            end
            
            % secect a satellite si in random way
            si = avsatall(randperm(numel(avsatall),1)); 
            % Suppose that choosing in trun instead of randomly would give better results than random selection
            % si = avsatall(mod(t-1,length(avsatall))+1);
            % 'lastt' represent the last allocation file of satellite 'si'
            lastt = allopairtp(find(allopairtp(:,2)==si),:);
            allopairtpnosi = allopairtp(find(allopairtp(:,2)~=si),:);% define the allocation file without 'si' of last iteration
            avtask = timepart{tp,1}(find(timepart{tp,1}(:,2)==si),1);% avtask = [taskid remain_task_load radio]
            
            avallocsi = avalloc(find(avalloc(:,3)==si),:);
            
            % the top w(t)% actions with the largest wij are selected
            avallocsi = sortrows(avallocsi,-8);
            selectsnum = ceil(min(omega_L+varphi*t,1)*length(avallocsi(:,1)));
            pcord = [pcord;t length(avallocsi(:,1)) min(omega_L+varphi*t,1) selectsnum];
            selectsall = avallocsi(1:selectsnum,1);
            selects = unique(selectsall(:,1),'rows');
            avallocsi = avallocsi(ismember(avallocsi(:,1),selects),:);
            
            ltUvalue = getNewUtility (si,allopairtp,Mvalue,verepsilon);
            betterac = [];
            
            if length(avallocsi(:,1))>0
                % For each possible task, caculate its utility function and
                % record its value greater than 'ltUvalue'
                j=1;
                while j<length(avallocsi(:,1))
                    if avallocsi(j,1) == avallocsi(j+1,1)
                        allopairtpnew = [allopairtpnosi; avallocsi(j,2:7);avallocsi(j+1,2:7)];
                        
                        ttUvalue = getNewUtility(si,allopairtpnew,Mvalue,verepsilon);
                        
                        if ttUvalue>ltUvalue
                            betterac = [betterac; avallocsi(j,1) ttUvalue];
                        end
                        j=j+2;
                    else
                        allopairtpnew = [allopairtpnosi; avallocsi(j,2:7)];
                        
                        ttUvalue = getNewUtility(si,allopairtpnew,Mvalue,verepsilon);
                        
                        if ttUvalue>ltUvalue
                            betterac = [betterac;avallocsi(j,1) ttUvalue];
                        end
                        j=j+1;
                    end
                end
                
                % For the last individual calculation that may have been missed
                if avallocsi(end,4)>8
                    allopairtpnew = [allopairtpnosi; avallocsi(end,2:7)];
                    ttUvalue = getNewUtility(si,allopairtpnew,Mvalue,verepsilon);
                    if ttUvalue>ltUvalue
                        betterac = [betterac;avallocsi(end,1) ttUvalue];
                    end
                end
            end
            
            
            % select the update action
            if length(betterac)>0
                pr = rand(1,1);
                if pr>vartheta
                    selectid = betterac(ceil(rand(1,1)*(length(betterac(:,1)))),1);
                    selectact = avallocsi(find(avallocsi(:,1)==selectid),2:7);
                    allopairtp = [allopairtpnosi; selectact];
                end
            end
            
            % caculate the objective value under current allocation file
            ctime = [];
            for j = 1:areatargetNum
                exesat = allopairtp(find(allopairtp(:,1)==j),:);
                wijall = sum(exesat(:,5));
                rvalue = hj(find(hj(:,2)==tp & hj(:,1)==j),6)-wijall;
                ctime = [ctime;j rvalue];
            end
            iteration_inf = [iteration_inf;r t max(ctime(:,2))];
            
        end
        
    end
    et = clock;
    [r etime(et,st) iteration_inf(end,3) ]
    result_for_r = [result_for_r; r etime(et,st) iteration_inf(end,3)];
    iteration_all = [iteration_all; iteration_inf];
end

[max(result_for_r(:,3)) min(result_for_r(:,3)) mean(result_for_r(:,3)) mean(result_for_r(:,2)) var(result_for_r(:,3)) length(find(result_for_r(:,3)==0))]
result_record = [result_record;max(result_for_r(:,3)) min(result_for_r(:,3)) mean(result_for_r(:,3)) mean(result_for_r(:,2)) var(result_for_r(:,3)) length(find(result_for_r(:,3)==0))];







