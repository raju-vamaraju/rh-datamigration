Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Target-ALL]
go

create view [sfrhd].[vw_upsert_Target-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Target__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Target__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actual__c]
    ,s.[End_Date__c]
    ,s.[Name]
    ,s.[Points_Achieved_SFG__c]
    ,s.[Shading__c]
    ,s.[Shading_Comments__c]
    ,s.[Start_date__c]
    ,s.[Target__c]
    ,[User__c] = coalesce(u.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_User] u
    on u.[Metazoa_External_ID__c] = s.[User__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[User__c],'') is not null
and nullif(u.[id],'') is not null)
or nullif(s.[User__c],'') is null
)
go
