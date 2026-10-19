Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Reviews_Accounted-ALL]
go

create view [sfrhd].[vw_upsert_Reviews_Accounted-ALL] as
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
,cte_ASN_Indicator_History as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASN_Indicator_History__c] i (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
    join [SalesforceMigration].[sfrhd].[ASN_Indicator_History__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Reviews_Accounted__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Reviews_Accounted__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Indicator_Score__c]
    ,s.[Name]
    ,[ASN_Indicator_History__c] = coalesce(asi.[Id-tgt],s.[ASN_Indicator_History__c]+'+')
    ,[Assurance_Review__c] = coalesce(ar.[Id-tgt],s.[Assurance_Review__c]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_ASN_Indicator_History] asi
    on asi.[id-src] = s.[ASN_Indicator_History__c]
left join [cte_Assurance_Review] ar
    on ar.[id-src] = s.[Assurance_Review__c]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[ASN_Indicator_History__c],'') is not null
--and nullif(asi.[id-tgt],'') is not null)
--or nullif(s.[ASN_Indicator_History__c],'') is null
--)
--and ((nullif(s.[Assurance_Review__c],'') is not null
--and nullif(ar.[id-tgt],'') is not null)
--or nullif(s.[Assurance_Review__c],'') is null
--)
go
