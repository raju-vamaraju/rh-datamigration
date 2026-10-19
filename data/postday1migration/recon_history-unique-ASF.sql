with cte_raw as (
SELECT distinct
    [Id]
    ,[Integration_Id__c]
    ,[ASFIntegrationID] = concat( ''
        , COALESCE([Adviser_Name__c], '') ,'|'
        , COALESCE([CommPay_Contact__c], '') ,'|'
        , COALESCE(UPPER([Entity_Name__c]), '') ,'|'
        , COALESCE([Account_Name__c], '') ,'|'
        , COALESCE([Account_Code__c], '') ,'|'
        , COALESCE([Statement_Number__c], '') ,'|'
        , COALESCE([Statement_Record_Date__c], '') ,'|'
        , COALESCE([Payment_Period__c], '') ,'|'
        , COALESCE([Payment_Period_Start__c], '') ,'|'
        , COALESCE([Payment_Period_End__c], '') ,'|'
        , COALESCE([CommPay_Client_Id__c], '') ,'|'
        , COALESCE([CommPay_Client_Name__c], '') ,'|'
        , COALESCE([Supplier_Name__c], '') ,'|'
        , COALESCE([Supplier_Code__c], '') ,'|'
        , COALESCE([Product_Name__c], '') ,'|'
        , COALESCE([Policy_Number__c], '') ,'|'
        , COALESCE([Main_Revenue_Type__c], '') ,'|'
        , COALESCE([Revenue_Type__c], '') ,'|'
        , COALESCE([Net_Amount__c], '') ,'|'
        , COALESCE([GST_Amount__c], '') ,'|'
        , COALESCE([Commencement_Date__c], '') ,'|'
        , COALESCE([Complete_Date__c], '') ,'|'
        , COALESCE([Is_Active__c], '') ,'|'
        , COALESCE([Thread_Id__c], '') ,'|'
        , COALESCE([Extract_Date__c], '') ,'|'
        )
        ,[external_id]
    ,[Account_Code__c]
    ,[Account_Name__c]
    ,[Adviser__c]
    ,[Adviser_Entity_Id__c]
    ,[Adviser_Name__c]
    ,[ASF_Prior_To_First_CSA__c]
    ,[ASIC_No_Xplan__c]
    ,[Client_Authorisation_Complete__c]
    ,[Commencement_Date__c]
    ,[CommPay_Client_Category__c]
    ,[CommPay_Client_Id__c]
    ,[CommPay_Client_Name__c]
    ,[CommPay_Contact__c]
    ,[Complete_Date__c]
    ,[CreatedById]
    ,[CreatedDate]
    ,[CSA_End_Date__c]
    ,[Date_Created__c]
    ,[Entity_Category__c]
    ,[Entity_Groups__c]
    ,[Entity_Id__c]
    ,[Entity_Name__c]
    ,[Extract_Date__c]
    ,[GST_Amount__c]
    ,[Has_Linked_ASF_Revenue__c]
    ,[Has_Linked_CSA_Case__c]
    ,[Is_Active__c]
    ,[IsDeleted]
    ,[LastActivityDate]
    ,[LastModifiedById]
    ,[LastModifiedDate]
    ,[Licensee__c]
    ,[Main_Revenue_Type__c]
    ,[Name]
    ,[Net_Amount__c]
    ,[New_Client_ASF_Prior_To_First_CSA__c]
    ,[OwnerId]
    ,[Payment_Period__c]
    ,[Payment_Period_End__c]
    ,[Payment_Period_Start__c]
    ,[Policy_Number__c]
    ,[Product_Code__c]
    ,[Product_Name__c]
    ,[Revenue_Type__c]
    ,[Scenario_Id__c]
    ,[Statement_Number__c]
    ,[Statement_Record_Date__c]
    ,[Supplier_Code__c]
    ,[Supplier_Name__c]
    ,[SystemModstamp]
    ,[Thread_Id__c]
    ,[Thread_Name__c]
    ,[Thread_Status__c]
    ,[Unallocated_Revenue_Unknown_Adviser__c]
    ,[Unallocated_Revenue_Unknown_Client__c]
FROM [ADVICE_ETL_PRD].[sf].[ASF_CSA_Case_dv__c]
where 1=1
and [Licensee__c] = 'Shadforth'
)
,cte_dup as (
select [ASFIntegrationID], [count] = count(distinct [Id])
from [cte_raw]
group by [ASFIntegrationID]
having count(distinct [Id]) > 1
)
select r.*
from [cte_raw] r
join [cte_dup] d
    on d.[ASFIntegrationID] = r.[ASFIntegrationID]
order by r.[ASFIntegrationID]
