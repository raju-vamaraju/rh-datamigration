Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_InitiativeChecklist-ALL]
go

create view [sfrhd].[vw_upsert_InitiativeChecklist-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Client_Service_Model_Implementation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Client_Service_Model_Implementation__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Client_Service_Model_Implementation__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_LookupName as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[LookupName__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[LookupName__c] r (nolock)
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
    from [SalesforceMigration].[sf].[InitiativeChecklist__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[InitiativeChecklist__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Action_Required__c]
    ,s.[Assessment_Type__c]
    ,s.[Close_Date__c]
    ,s.[CyberSecurity_Remediation_Comment__c]
    ,s.[Due_Date__c]
    ,s.[Issue_Identified__c]
    ,s.[Name]
    ,s.[Practice_ID__c]
    ,s.[Priority__c]
    ,s.[Start_Date__c]
    ,s.[Status__c]
    ,[Initiative_Implementation__c] = coalesce(csmi.[Id-tgt],s.[Initiative_Implementation__c]+'+')
    ,[SecurityMeasure__c] = coalesce(ln.[Id-tgt],s.[SecurityMeasure__c]+'+')
    ,[RecordTypeId] = coalesce(rtt.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Client_Service_Model_Implementation] csmi
    on csmi.[id-src] = s.[Initiative_Implementation__c]
left join [cte_LookupName] ln
    on ln.[id-src] = s.[SecurityMeasure__c]
left join [cte_RecordType] rtt
    on rtt.[id-src] = s.[RecordTypeId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Initiative_Implementation__c],'') is not null
--and nullif(csmi.[id-tgt],'') is not null)
--or nullif(s.[Initiative_Implementation__c],'') is null
--)
--and ((nullif(s.[SecurityMeasure__c],'') is not null
--and nullif(ln.[id-tgt],'') is not null)
--or nullif(s.[SecurityMeasure__c],'') is null
--)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rtt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
