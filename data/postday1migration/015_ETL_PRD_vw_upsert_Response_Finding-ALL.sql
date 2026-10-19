Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Response_Finding-ALL]
go

create view [sfrhd].[vw_upsert_Response_Finding-ALL] as
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
,cte_Question_Responses as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Question_Responses__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Question_Responses__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Response_Finding__c] s (nolock)
    join [SalesforceMigration].[sf].[Question_Responses__c] c
        on c.[Id] = s.[Incident__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Response_Finding__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actions_Taken__c]
    ,s.[ASN_Indicator__c]
    ,s.[Due_Date__c]
    ,s.[Findings__c]
    ,s.[Name]
    ,s.[Root_Cause__c]
    ,[Master_Question__c] = coalesce(rmq.[Id-tgt],s.[Master_Question__c]+'+')
    ,[MasterQuestions_Targetedreviews__c] = coalesce(rqt.[Id-tgt],s.[MasterQuestions_Targetedreviews__c]+'+')
    ,[Incident__c] = coalesce(rqr.[Id-tgt],s.[Incident__c]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Master_Questions] rmq
    on rmq.[Id-src] = s.[Master_Question__c]
left join [cte_MasterQuestions_Targetedreviews] rqt
    on rqt.[Id-src] = s.[MasterQuestions_Targetedreviews__c]
left join [cte_Question_Responses] rqr
    on rqr.[Id-src] = s.[Incident__c]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Master_Question__c],'') is not null
--and nullif(rmq.[id-tgt],'') is not null)
--or nullif(s.[Master_Question__c],'') is null
--)
--and ((nullif(s.[MasterQuestions_Targetedreviews__c],'') is not null
--and nullif(rqt.[id-tgt],'') is not null)
--or nullif(s.[MasterQuestions_Targetedreviews__c],'') is null
--)
--and ((nullif(s.[Incident__c],'') is not null
--and nullif(rqr.[id-tgt],'') is not null)
--or nullif(s.[Incident__c],'') is null
--)
go
