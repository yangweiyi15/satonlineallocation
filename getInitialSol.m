function [allopairtp,avtask,ctime] = getInitialSol(timepart,tp,avsatall,hj,timeduration,areatargetNum,punish)
%GETINITIALSOL 此处显示有关此函数的摘要
%   此处显示详细说明
allopairtp = [];%[taskid satid xij wij xij*wij taskload]

for i=1:length(avsatall)
    avtask = []; %[taskid task_remain_load]
    avtask = timepart{tp,1}(find(timepart{tp,1}(:,2)==avsatall(i)),1);
    avtask = avtask(randperm(size(avtask,1)),:); 
    if length(allopairtp) > 0
        for j =1:length(avtask(:,1))
            hjvalue = hj(find(hj(:,2)==tp & hj(:,1) == avtask(j,1)),6);
            wijsum = sum(allopairtp(find(allopairtp(:,1) == avtask(j,1)),5));
            avtask(j,2) = hjvalue - wijsum;
            wij = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(j,1) & timepart{tp,1}(:,2)==avsatall(i)),10);
            avtask(j,3) = wij;
        end
        avtask = sortrows(avtask,-3);
        avtask = sortrows(avtask,-2);
        timeremain = timeduration;
        for j=1:length(avtask(:,1))
            wij = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(j,1) & timepart{tp,1}(:,2)==avsatall(i)),10);
            if wij*timeremain > avtask(j,2)
                timealloc = floor(avtask(j,2)/wij);
            else
                timealloc = timeremain;
            end
            hjvalue = hj(find(hj(:,2)==tp & hj(:,1) == avtask(j,1)),6);
            allopairtp = [allopairtp; avtask(j,1) avsatall(i) timealloc wij timealloc*wij hjvalue];
            if timealloc ~= timeduration
                timeremain = timeremain - timealloc - punish;
            else
                timeremain = timeremain - timealloc;
            end
            if timeremain <= 0
                break;
            end
        end
    else
        if length(avtask(:,1))>1
            for j=1:length(avtask(:,1))
                avtask(j,2) = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(j,1) & timepart{tp,1}(:,2)==avsatall(i)),10);
            end
        end
        avtask = sortrows(avtask,-2);
        wij = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(1,1) & timepart{tp,1}(:,2)==avsatall(i)),10);
        hjvalue = hj(find(hj(:,2)==tp & hj(:,1) == avtask(1,1)),6);
        allopairtp = [allopairtp; avtask(1,1) avsatall(i) timeduration wij timeduration*wij hjvalue];
    end
    
end
allopairtp = sortrows(allopairtp,2);

% calculate the objective value under current allocation file
ctime = [];% [j objective_value]
for j = 1:areatargetNum
    exesat = allopairtp(find(allopairtp(:,1)==j),:);
    wijall = sum(exesat(:,5));
    rvalue = hj(find(hj(:,2)==tp & hj(:,1)==j),6)-wijall;
    ctime = [ctime;j rvalue];
end
end

