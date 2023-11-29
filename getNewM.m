function Mvalue = getNewM( tpid,hj,timepart, timeduration,para )
%GETM The normalization parameter M is calculated for each tp

wimax = 0;
wimax = max(timepart{tpid,1}(:,10))*timeduration;

hjsitamax = max(hj(find(hj(:,2) == tpid),6));

Mvalue = (1-exp(-wimax/para))*(exp(hjsitamax/para));


end

