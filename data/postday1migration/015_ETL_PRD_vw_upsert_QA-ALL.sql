Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_QA-ALL]
go

create view [sfrhd].[vw_upsert_QA-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
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
    where 1=1
)
,cte_Assurance_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[QA__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[QA__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Debrief__c]
    ,s.[Debrief_Notes__c]
    ,s.[Draft_Report__c]
    ,s.[Final_Report__c]
    ,s.[Interim_Report__c]
    ,s.[Name]
    ,s.[Other_Discussion_Points__c]
    ,s.[QA_Completed_On__c]
    ,s.[QA_Date__c]
    ,s.[QA_Outcome__c]
    ,s.[QA_Status__c]
    ,s.[QA_Type__c]
    ,s.[Questionnaire_Launched_On__c]
    ,s.[Questionnaire_Status__c]
    ,s.[Review_Questionnaire__c]
    ,s.[Scope_Strategies__c]
    ,[Practice__c] = coalesce(a.[Id-tgt],s.[Practice__c]+'+')
    ,[Review__c] = coalesce(ar.[Id-tgt],s.[Review__c]+'+')
    ,[Adviser__c] = coalesce(c.[Id-tgt],s.[Adviser__c]+'+')
    ,[RecordTypeId] = coalesce(rtt.[Id-tgt],'')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] a
    on a.[id-src] = s.[Practice__c]
left join [cte_Assurance_Review] ar
    on ar.[id-src] = s.[Review__c]
left join [cte_Contact] c
    on c.[id-src] = s.[Adviser__c]
left join [cte_RecordType] rtt
    on rtt.[id-src] = s.[RecordTypeId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Practice__c],'') is not null
--and nullif(a.[id-tgt],'') is not null)
--or nullif(s.[Practice__c],'') is null
--)
--and ((nullif(s.[Review__c],'') is not null
--and nullif(ar.[id-tgt],'') is not null)
--or nullif(s.[Review__c],'') is null
--)
--and ((nullif(s.[Adviser__c],'') is not null
--and nullif(c.[id-tgt],'') is not null)
--or nullif(s.[Adviser__c],'') is null
--)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rtt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
