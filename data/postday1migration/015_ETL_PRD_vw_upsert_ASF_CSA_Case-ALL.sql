Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_ASF_CSA_Case-ALL]
go

create view [sfrhd].[vw_upsert_ASF_CSA_Case-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_src as (
    select --top 200
        s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[ASF_CSA_Case__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[ASF_CSA_Case__c] t (nolock)
        on t.[Integration_Id__c] = s.[Integration_Id__c]
    where 1=1
and s.[Entity_Groups__c] in ('Shadforth - TAS - Launceston','[BRIDGES] ADELAIDE')
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Account_Code__c]
    ,s.[Account_Name__c]
    ,s.[Adviser_Entity_Id__c]
    ,s.[Adviser_Name__c]
    ,[ASF_Prior_To_First_CSA__c] = iif(s.[ASF_Prior_To_First_CSA__c] = 1, 'true', 'false')
    ,s.[ASIC_No_Xplan__c]
    ,s.[Client_Authorisation_Complete__c]
    ,s.[Commencement_Date__c]
    ,s.[CommPay_Client_Category__c]
    ,s.[CommPay_Client_Id__c]
    ,s.[CommPay_Client_Name__c]
    ,s.[CommPay_Contact__c]
    ,s.[Complete_Date__c]
    ,s.[CSA_End_Date__c]
    ,s.[Date_Created__c]
    ,s.[Entity_Category__c]
    ,s.[Entity_Groups__c]
    ,s.[Entity_Id__c]
    ,s.[Entity_Name__c]
    ,s.[Extract_Date__c]
    ,s.[GST_Amount__c]
    ,[Has_Linked_ASF_Revenue__c] = iif(s.[Has_Linked_ASF_Revenue__c] = 1, 'true', 'false')
    ,[Has_Linked_CSA_Case__c] = iif(s.[Has_Linked_CSA_Case__c] = 1, 'true', 'false')
    ,s.[Integration_Id__c]
    ,s.[Is_Active__c]
    ,[IsDeleted] = iif(s.[IsDeleted] = 1, 'true', 'false')
    ,s.[LastActivityDate]
    ,s.[LastReferencedDate]
    ,s.[LastViewedDate]
    ,s.[Licensee__c]
    ,s.[Main_Revenue_Type__c]
    ,s.[Name]
    ,s.[Net_Amount__c]
    ,[New_Client_ASF_Prior_To_First_CSA__c] = iif(s.[New_Client_ASF_Prior_To_First_CSA__c] = 1, 'true', 'false')
    ,s.[Payment_Period__c]
    ,s.[Payment_Period_End__c]
    ,s.[Payment_Period_Start__c]
    ,s.[Policy_Number__c]
    ,s.[Product_Code__c]
    ,s.[Product_Name__c]
    ,s.[Revenue_Type__c]
    ,s.[Scenario_Id__c]
    ,s.[Statement_Number__c]
    ,s.[Statement_Record_Date__c]
    ,s.[Supplier_Code__c]
    ,s.[Supplier_Name__c]
    ,s.[SystemModstamp]
    ,s.[Thread_Id__c]
    ,s.[Thread_Name__c]
    ,s.[Thread_Status__c]
    ,[Unallocated_Revenue_Unknown_Adviser__c] = iif(s.[Unallocated_Revenue_Unknown_Adviser__c] = 1, 'true', 'false')
    ,[Unallocated_Revenue_Unknown_Client__c] = iif(s.[Unallocated_Revenue_Unknown_Client__c] = 1, 'true', 'false')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
go
