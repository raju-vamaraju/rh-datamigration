with cte_raw as (
SELECT distinct
    [Id]
    ,[Integration_Id__c]
    ,[CSAIntegrationID] = concat(''
				    --, COALESCE([licensee], '') ,'|'
				    , COALESCE([Entity_Id__c], '') ,'|'
				    , COALESCE([Benchmark_Description__c], '') ,'|'
				    , COALESCE([Item__c], '') ,'|'
				    , COALESCE([Item_Id__c], '') ,'|'
				    , COALESCE([Thread_Id__c], '') ,'|'
				    )
    ,[external_id]
	,[Adviser__c]
	,[Adviser_Entity_Id__c]
	,[Adviser_Name_Xplan__c]
	,[ASIC_No_Xplan__c]
	,[Benchmark_Description__c]
	,[Benchmark_Status__c]
	,[Case_Overdue_Days__c]
	,[Client_Authorisation_Complete__c]
	,[Commencement_Date__c]
	,[Complete_Date__c]
	,[CreatedById]
	,[CreatedDate]
	,[CSASwitchoffcutoffDays__c]
	,[Date_Created__c]
	,[Date_Linked__c]
	,[Entity_Category__c]
	,[Entity_Groups__c]
	,[Entity_Id__c]
	,[Entity_Name__c]
	,[Exclude_From_Back_Dating__c]
	,[Extract_Date__c]
	,[Is_Active__c]
	,[IsDeleted]
	,[Item__c]
	,[Item_Id__c]
	,[Item_Status__c]
	,[LastActivityDate]
	,[LastModifiedById]
	,[LastModifiedDate]
	,[Name]
	,[OwnerId]
	,[Primary_User_Group__c]
	,[Scenario_Id__c]
	,[Scheduled_Run_Date__c]
	,[Service_Frequency__c]
	,[Service_Name__c]
	,[Service_Package__c]
	,[Source_Template_Name__c]
	,[Sub_Type__c]
	,[Subject__c]
	,[SystemModstamp]
	,[Thread_Id__c]
	,[Thread_Name__c]
	,[Thread_Status__c]
	,[Type__c]
	,[User_Exclude_From_Back_Dating__c]
	,[User_Exclude_From_Duplicate_Case__c]
	,[User_Exclude_From_Forward_Dating__c]
	,[UserExcludeFrom_Early_Service_Completion__c]
FROM [ADVICE_ETL_PRD].[sf].[CSA_Case_dv__c]
)
,cte_dup as (
select [CSAIntegrationID], [count] = count(distinct [Id])
from [cte_raw]
group by [CSAIntegrationID]
having count(distinct [Id]) > 1
)
select r.*
from [cte_raw] r
join [cte_dup] d
    on d.[CSAIntegrationID] = r.[CSAIntegrationID]
order by r.[CSAIntegrationID]
