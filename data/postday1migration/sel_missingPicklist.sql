with cte_sf as (
SELECT distinct [Sub_Task__c]
FROM [ADVICE_ETL_PRD].[sf].[Task]
)
,cte_re as (
SELECT distinct [Sub_Task__c]
FROM [ADVICE_ETL_PRD].[sfrhd].[Task]
)
select s.[Sub_Task__c]
from [cte_sf] s
left join [cte_re] r
	on r.[Sub_Task__c] = s.[Sub_Task__c]
where 1=1
and r.[Sub_Task__c] is null
order by s.[Sub_Task__c]
;
