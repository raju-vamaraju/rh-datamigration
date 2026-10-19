Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_EmailTemplate-ALL]
go

create view [sfrhd].[vw_upsert_EmailTemplate-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_BrandTemplate as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[BrandTemplate] i (nolock)
    join [SalesforceMigration].[sfrhd].[BrandTemplate] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    and nullif(i.[DeveloperName],'') is not null
)
,cte_EnhancedLetterhead as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[EnhancedLetterhead] i (nolock)
    join [SalesforceMigration].[sfrhd].[EnhancedLetterhead] r (nolock)
        on r.[Name] = i.[Name]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and nullif(i.[DeveloperName],'') is not null
)
,cte_Folder as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Folder] i (nolock)
    join [SalesforceMigration].[sfrhd].[Folder] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    and nullif(i.[DeveloperName],'') is not null
)
,cte_Organization as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Organization] i (nolock)
    cross join [SalesforceMigration].[sfrhd].[Organization] r (nolock)
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[EmailTemplate] s (nolock)
    left join [SalesforceMigration].[sfrhd].[EmailTemplate] t (nolock)
        on t.[DeveloperName] = s.[DeveloperName]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ApiVersion]
    ,s.[Body]
    ,s.[Description]
    ,s.[DeveloperName]
    ,s.[Encoding]
    ,s.[FolderName]
    ,s.[HtmlValue]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,[IsBuilderContent] = iif(s.[IsBuilderContent] = 1, 'true', 'false')
    ,s.[LastUsedDate]
    ,s.[Markup]
    ,s.[Name]
    ,s.[NamespacePrefix]
    ,s.[RelatedEntityType]
    ,s.[Subject]
    ,s.[TemplateStyle]
    ,s.[TemplateType]
    ,s.[TimesUsed]
    ,s.[UiType]
    ,[BrandTemplateId] = coalesce(bt.[Id-tgt],'')
    ,[EnhancedLetterheadId] = coalesce(el.[Id-tgt],'')
    ,[FolderId] = coalesce(f.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_BrandTemplate] bt
    on bt.[id-src] = s.[BrandTemplateId]
left join [cte_EnhancedLetterhead] el
    on el.[id-src] = s.[EnhancedLetterheadId]
left join [cte_Folder] f
    on f.[id-src] = s.[FolderId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[BrandTemplateId],'') is not null
and nullif(bt.[id-tgt],'') is not null)
or nullif(s.[BrandTemplateId],'') is null
)
and ((nullif(s.[EnhancedLetterheadId],'') is not null
and nullif(el.[id-tgt],'') is not null)
or nullif(s.[EnhancedLetterheadId],'') is null
)
and ((nullif(s.[FolderId],'') is not null
and nullif(f.[id-tgt],'') is not null)
or nullif(s.[FolderId],'') is null
)
union all
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ApiVersion]
    ,s.[Body]
    ,s.[Description]
    ,s.[DeveloperName]
    ,s.[Encoding]
    ,s.[FolderName]
    ,s.[HtmlValue]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,[IsBuilderContent] = iif(s.[IsBuilderContent] = 1, 'true', 'false')
    ,s.[LastUsedDate]
    ,s.[Markup]
    ,s.[Name]
    ,s.[NamespacePrefix]
    ,s.[RelatedEntityType]
    ,s.[Subject]
    ,s.[TemplateStyle]
    ,s.[TemplateType]
    ,s.[TimesUsed]
    ,s.[UiType]
    ,[BrandTemplateId] = coalesce(bt.[Id-tgt],'')
    ,[EnhancedLetterheadId] = coalesce(el.[Id-tgt],'')
    ,[FolderId] = coalesce(f.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_BrandTemplate] bt
    on bt.[id-src] = s.[BrandTemplateId]
left join [cte_EnhancedLetterhead] el
    on el.[id-src] = s.[EnhancedLetterheadId]
left join [cte_Organization] f
    on f.[id-src] = s.[FolderId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[BrandTemplateId],'') is not null
and nullif(bt.[id-tgt],'') is not null)
or nullif(s.[BrandTemplateId],'') is null
)
and ((nullif(s.[EnhancedLetterheadId],'') is not null
and nullif(el.[id-tgt],'') is not null)
or nullif(s.[EnhancedLetterheadId],'') is null
)
and ((nullif(s.[FolderId],'') is not null
and nullif(f.[id-tgt],'') is not null)
or nullif(s.[FolderId],'') is null
)
go
