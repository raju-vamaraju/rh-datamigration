Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Qualification-ALL]
go

create view [sfrhd].[vw_upsert_Qualification-ALL] as
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_Qualification_Type as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Qualification_Type__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Qualification_Type__c] r (nolock)
        on r.[Name] = i.[Name]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_Registered_Training_Organisation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Registered_Training_Organisation__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Registered_Training_Organisation__c] r (nolock)
        on r.[Name] = i.[Name]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Qualification__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c
        on c.[Id] = s.[Adviser__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Qualification__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,s.[Other_Qualification__c]
    ,s.[Other_Registered_Training_Organisation__c]
    ,s.[Qualification_Course_Status__c]
    ,s.[Qualification_TypeNew__c]
    ,[Specialist_Accreditation__c] = iif(s.[Specialist_Accreditation__c] = 1, 'true', 'false')
    ,s.[Subject_Name__c]
    ,[TASA__c] = iif(s.[TASA__c] = 1, 'true', 'false')
    ,s.[Year_Obtained__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
    ,[Qualification_Type__c] = coalesce(rqt.[Id-tgt],'')
    ,[Registered_Training_Organisation__c] = coalesce(rto.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_Qualification_Type] rqt
    on rqt.[Id-src] = s.[Qualification_Type__c]
left join [cte_Registered_Training_Organisation] rto
    on rto.[Id-src] = s.[Registered_Training_Organisation__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Qualification_Type__c],'') is not null
and nullif(rqt.[id-tgt],'') is not null)
or nullif(s.[Qualification_Type__c],'') is null
)
and ((nullif(s.[Registered_Training_Organisation__c],'') is not null
and nullif(rto.[id-tgt],'') is not null)
or nullif(s.[Registered_Training_Organisation__c],'') is null
)
go
