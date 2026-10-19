Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_QA_Assignment_Hisotry-ALL]
go

create view [sfrhd].[vw_upsert_QA_Assignment_Hisotry-ALL] as
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
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[QA_Assignment_Hisotry__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[QA_Assignment_Hisotry__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Name]
    ,s.[QA_Type__c]
    ,[Assurance_Review__c] = coalesce(ar.[Id-tgt],s.[Assurance_Review__c]+'+')
    ,[QA_Officer__c] = coalesce(u.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Assurance_Review] ar
    on ar.[id-src] = s.[Assurance_Review__c]
left join [cte_User] u
    on u.[Metazoa_External_ID__c] = s.[QA_Officer__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(ar.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[QA_Officer__c],'') is not null
and nullif(u.[Id],'') is not null)
or nullif(s.[QA_Officer__c],'') is null
)
go
