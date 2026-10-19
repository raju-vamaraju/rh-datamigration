Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_SelectedQuestions_Targetedreviews-ALL]
go

create view [sfrhd].[vw_upsert_SelectedQuestions_Targetedreviews-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
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
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_MasterQuestions_Targetedreviews as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[MasterQuestions_Targetedreviews__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[MasterQuestions_Targetedreviews__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Name] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Name] in ('Bridges', 'Shadforth')
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[SelectedQuestions_Targetedreviews__c] s (nolock)
    join [SalesforceMigration].[sf].[Assurance_Review__c] c
        on c.[Id] = s.[Assurance_Review__c] 
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = c.[Practice__c]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[SelectedQuestions_Targetedreviews__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,[Cloned__c] = iif(s.[Cloned__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Question_Number__c]
    ,s.[Question_Text__c]
    ,s.[Sorting_Index__c]
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],s.[Assurance_Review__c]+'+')
    ,[MasterQuestions_Targetedreviews__c] = coalesce(rmqt.[Id-tgt],s.[MasterQuestions_Targetedreviews__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_MasterQuestions_Targetedreviews] rmqt
    on rmqt.[Id-src] = s.[MasterQuestions_Targetedreviews__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Assurance_Review__c],'') is not null
--and nullif(rar.[id-tgt],'') is not null)
--or nullif(s.[Assurance_Review__c],'') is null
--)
--and ((nullif(s.[MasterQuestions_Targetedreviews__c],'') is not null
--and nullif(rmqt.[id-tgt],'') is not null)
--or nullif(s.[MasterQuestions_Targetedreviews__c],'') is null
--)
go
