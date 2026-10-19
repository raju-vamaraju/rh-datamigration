USE [SalesforceMigration]
GO

DROP VIEW if exists [sfrhd].[vw_upsert_Library_Text-ALL]
GO

/****** Object:  View [sfrhd].[vw_upsert_Library_Text-ALL]    Script Date: 9/1/2026 4:03:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [sfrhd].[vw_upsert_Library_Text-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Master_Questions as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Master_Questions__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Master_Questions__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_MasterQuestions_Targetedreviews as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[MasterQuestions_Targetedreviews__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[MasterQuestions_Targetedreviews__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Library_Text__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Library_Text__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actions_Required__c]
    ,s.[Expiry_Date__c]
    ,s.[External_ID__c]
    ,s.[Findings__c]
    ,s.[Name]
    ,[Master_Question__c] = coalesce(mq.[Id-tgt],'')
    ,[Targeted_Assurance_Question_Bank__c] = coalesce(mqt.[Id-tgt],'')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Master_Questions] mq
    on mq.[id-src] = s.[Master_Question__c]
left join [cte_MasterQuestions_Targetedreviews] mqt
    on mqt.[id-src] = s.[Targeted_Assurance_Question_Bank__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Master_Question__c],'') is not null
and nullif(mq.[id-tgt],'') is not null)
or nullif(s.[Master_Question__c],'') is null
)
and ((nullif(s.[Targeted_Assurance_Question_Bank__c],'') is not null
and nullif(mqt.[id-tgt],'') is not null)
or nullif(s.[Targeted_Assurance_Question_Bank__c],'') is null
)
GO

