Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_PSA-ALL]
go

create view [sfrhd].[vw_upsert_PSA-ALL] as
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
--and i.[Id] = '0016F00002YKl2zQAD'
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[PSA__c] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[Practice_Name__c]
        and a.[Licensee__c] in ('Bridges','Shadforth')
    left join [SalesforceMigration].[sfrhd].[PSA__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Average_AQR_Score__c]
    ,s.[Comments__c]
    ,s.[EDP_External_Id__c]
    ,[Is_Active__c] = iif(s.[Is_Active__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Number_Of_Open_Tasks__c]
    ,[On_Watch_List_Manually__c] = iif(s.[On_Watch_List_Manually__c] = 1, 'true', 'false')
    ,s.[Review_Date__c]
    ,s.[Review_Score__c]
    ,s.[Status__c]
    ,s.[Unanswered_Questions__c]
    ,s.[Upcoming_Task_Due_Date__c]
    ,[Practice_Name__c] = coalesce(a.[Id-tgt],'')
    ,[Secondary_Contact__c] = coalesce(c.[Id-tgt],'')
    ,[Licensee_Supervisor_Name__c] = coalesce(u.[Id],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] a
    on a.[id-src] = s.[Practice_Name__c]
left join [cte_Contact] c
    on c.[id-src] = s.[Secondary_Contact__c]
left join [cte_User] u
    on u.[Metazoa_External_ID__c] = s.[Licensee_Supervisor_Name__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Secondary_Contact__c],'') is not null
and nullif(c.[id-tgt],'') is not null)
or nullif(s.[Secondary_Contact__c],'') is null
)
and ((nullif(s.[Licensee_Supervisor_Name__c],'') is not null
and nullif(u.[id],'') is not null)
or nullif(s.[Licensee_Supervisor_Name__c],'') is null
)
GO
