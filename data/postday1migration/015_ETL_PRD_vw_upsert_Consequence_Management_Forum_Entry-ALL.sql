Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Consequence_Management_Forum_Entry-ALL]
go

create view [sfrhd].[vw_upsert_Consequence_Management_Forum_Entry-ALL] as
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
,cte_Assurance_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
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
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Client_s_impacted__c]
    ,s.[CMF__c]
    ,s.[Consequences__c]
    ,s.[Description__c]
    ,s.[EDP_External_Id__c]
    ,s.[Explanation_to_support_Consequences__c]
    ,s.[Meeting_date__c]
    ,s.[Name]
    ,s.[Nature_of_client_detriment__c]
    ,s.[Potential_dollar_loss_or_detriment__c]
    ,s.[Received_Date__c]
    ,s.[Recommendation__c]
    ,s.[Root_Cause_s__c]
    ,s.[Significant_Issue_Patterns__c]
    ,s.[Source_of_Submission__c]
    ,[Practice__c] = coalesce(ra.[Id-tgt],'')
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],s.[Assurance_Review__c]+'+')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[Practice__c]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Practice__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Practice__c],'') is null
)
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(rar.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
