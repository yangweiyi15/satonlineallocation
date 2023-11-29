function utility = getNewUtility( si, allopairtp, Mvalue,para )
%GETNEWUTILITY caculate the utility funciton for satellite 'si' under the allocation file 'allopairtp'

utility = 0;
relatask = allopairtp(find(allopairtp(:,2)==si),1);
for j=1:length(relatask)
    hjvalue = allopairtp(find(allopairtp(:,2)==si&allopairtp(:,1)==relatask(j)),6);
    wijsum = sum(allopairtp(allopairtp(:,1)==relatask(j),5));
    wijsumnosi = sum(allopairtp(allopairtp(:,2)~=si&allopairtp(:,1)==relatask(j),5));
    utility = utility + exp((hjvalue-wijsumnosi)/para)-exp((hjvalue-wijsum)/para);
end
utility = utility/Mvalue;

end
