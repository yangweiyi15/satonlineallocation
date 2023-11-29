function avalloc = getInitialAlloc( avsatall,timepart,tp, hj,timeduration,punish)

avalloc=[];% [id Taskid satid xij wij xij*wij taskload]
count = 1;
for i=1:length(avsatall)
    avtask = []; %[taskid task_remain_load]
    avtask = timepart{tp,1}(find(timepart{tp,1}(:,2)==avsatall(i)),1);
    avtask = timepart{tp,1}(find(timepart{tp,1}(:,2)==avsatall(i)),1);
    % Consider the case where there is only one visible task
    if avtask<2
        wij = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(1) & timepart{tp,1}(:,2)==avsatall(i)),10);
        hjvalue = hj(find(hj(:,2)==tp & hj(:,1) == avtask(1)),6);
        for timealloc = 1:timeduration
            avalloc = [avalloc; count avtask(1) avsatall(i) timealloc wij timealloc*wij hjvalue timealloc*wij];
            count = count + 1;
        end
    else% Consider the case of multiple visible tasks
        % allocate to one task
        for j=1:length(avtask(:,1))
            wij = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtask(j) & timepart{tp,1}(:,2)==avsatall(i)),10);
            hjvalue = hj(find(hj(:,2)==tp & hj(:,1) == avtask(j)),6);
            avalloc = [avalloc; count avtask(j) avsatall(i) timeduration wij timeduration*wij hjvalue timeduration*wij];
            count = count + 1;
            avalloc = [avalloc; count avtask(j) avsatall(i) (timeduration-punish) wij (timeduration-punish)*wij hjvalue (timeduration-punish)*wij];
            count = count + 1;
        end
        % allocate to one more task
        if length(avtask(:,1))>1
            avtaskcomb = combntns(avtask,2);
            for j=1:length(avtaskcomb(:,1))
                hjvalue1 = hj(find(hj(:,2)==tp & hj(:,1) == avtaskcomb(j,1)),6);
                hjvalue2 = hj(find(hj(:,2)==tp & hj(:,1) == avtaskcomb(j,2)),6);
                wij1 = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtaskcomb(j,1) & timepart{tp,1}(:,2)==avsatall(i)),10);
                wij2 = timepart{tp,1}(find(timepart{tp,1}(:,1)==avtaskcomb(j,2) & timepart{tp,1}(:,2)==avsatall(i)),10);
                time1= timeduration - punish*2;
                while time1>0
                    time2 = timeduration - punish - time1;
                    avalloc = [avalloc;
                        count avtaskcomb(j,1) avsatall(i) time1 wij1 time1*wij1 hjvalue1 (time1*wij1+time2*wij2);
                        count avtaskcomb(j,2) avsatall(i) time2 wij2 time2*wij2 hjvalue2 (time1*wij1+time2*wij2)];
                    count = count + 1;
                    time1 = time1 - 1;
                end
            end
        end
    end
end

end
