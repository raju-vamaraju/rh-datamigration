Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Question_Group-ALL]
go

create view [sfrhd].[vw_upsert_Question_Group-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Question_Group__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Question_Group__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Description__c]
    ,s.[EDP_External_Id__c]
    ,s.[External_ID__c]
    ,s.[Group_Number__c]
    ,s.[Name]
    ,s.[Questionnaire__c]
    ,s.[Section_Title__c]
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and s.[id-tgt] is null
go
