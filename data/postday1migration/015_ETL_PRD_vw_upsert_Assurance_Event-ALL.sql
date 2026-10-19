Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Assurance_Event-ALL]
go

create view [sfrhd].[vw_upsert_Assurance_Event-ALL] as
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
,cte_Incident_File_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Incident_File_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Assurance_Event__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Assurance_Event__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Closed_Date__c]
    ,s.[Comments__c]
    ,s.[Event_Record_Sub_Type__c]
    ,s.[Event_Record_Type__c]
    ,s.[Event_Referral_Date__c]
    ,s.[Event_Scope__c]
    ,s.[Event_Scope_Comment__c]
    ,s.[Event_Status__c]
    ,s.[Name]
    ,s.[Number_Of_Client_Files__c]
    ,s.[Number_Of_Unique_Advisers__c]
    ,s.[Review_Count__c]
    ,[Related_Incident__c] = coalesce(rc.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Event_Lead__c] = coalesce(ru.[Id],'')
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Incident_File_Review] rc
    on rc.[Id-src] = s.[Related_Incident__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] ru
    on ru.[Metazoa_External_ID__c] = s.[Event_Lead__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Related_Incident__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Related_Incident__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Event_Lead__c],'') is not null
and nullif(ru.[id],'') is not null)
or nullif(s.[Event_Lead__c],'') is null
)
go
