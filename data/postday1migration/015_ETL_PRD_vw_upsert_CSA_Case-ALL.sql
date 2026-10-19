Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_CSA_Case-ALL]
go

create view [sfrhd].[vw_upsert_CSA_Case-ALL] as
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
    from [SalesforceMigration].[sf].[CSA_Case__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[CSA_Case__c] t (nolock)
        on t.[Integration_Id__c] = s.[Integration_Id__c]
    where 1=1
and s.[Primary_User_Group__c] in ('Shadforth - TAS - Launceston','[BRIDGES] ADELAIDE')
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Adviser_Entity_Id__c]
    ,s.[Adviser_Name_Xplan__c]
    ,s.[ASIC_No_Xplan__c]
    ,s.[Benchmark_Description__c]
    ,s.[Benchmark_Status__c]
    ,s.[Client_Authorisation_Complete__c]
    ,s.[Commencement_Date__c]
    ,s.[Complete_Date__c]
    ,s.[Date_Created__c]
    ,s.[Date_Linked__c]
    ,s.[Entity_Category__c]
    ,s.[Entity_Groups__c]
    ,s.[Entity_Id__c]
    ,s.[Entity_Name__c]
    ,[Exclude_From_Back_Dating__c] = iif(s.[Exclude_From_Back_Dating__c] = 1, 'true', 'false')
    ,s.[Extract_Date__c]
    ,s.[Integration_Id__c]
    ,s.[Is_Active__c]
    ,[IsDeleted] = iif(s.[IsDeleted] = 1, 'true', 'false')
    ,s.[Item__c]
    ,s.[Item_Id__c]
    ,s.[Item_Status__c]
    --,s.[LastActivityDate]
    ,s.[Name]
    ,s.[Primary_User_Group__c]
    ,s.[Scenario_Id__c]
    ,s.[Service_Frequency__c]
    ,s.[Service_Name__c]
    ,s.[Service_Package__c]
    ,s.[Source_Template_Name__c]
    ,s.[Sub_Type__c]
    ,s.[Subject__c]
    ,s.[SystemModstamp]
    ,s.[Thread_Id__c]
    ,s.[Thread_Name__c]
    ,s.[Thread_Status__c]
    ,s.[Type__c]
    ,[User_Exclude_From_Back_Dating__c] = iif(s.[User_Exclude_From_Back_Dating__c] = 1, 'true', 'false')
    ,[User_Exclude_From_Duplicate_Case__c] = iif(s.[User_Exclude_From_Duplicate_Case__c] = 1, 'true', 'false')
    ,[User_Exclude_From_Forward_Dating__c] = iif(s.[User_Exclude_From_Forward_Dating__c] = 1, 'true', 'false')
    ,[User_Exclude_From_Early_Srv_Completion__c] = iif(s.[User_Exclude_From_Early_Srv_Completion__c] = 1, 'true', 'false')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
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
