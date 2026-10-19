USE [SalesforceMigration]
GO

DROP VIEW if exists [sfrhd].[vw_upsert_CampaignMember-ALL]
GO

create view [sfrhd].[vw_upsert_CampaignMember-ALL] as
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
)
,cte_Campaign as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Campaign] i (nolock)
    join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
        on r.[Metazoa_External_Id__c] = i.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[CampaignMember] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Campaign] tc (nolock)
        on tc.[Metazoa_External_Id__c] = s.[Id]
    left join [SalesforceMigration].[sfrhd].[CampaignMember] t (nolock)
        on t.[CampaignId] = tc.[Id]
        and t.[Name] = s.[Name]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[City]
    ,s.[CompanyOrAccount]
    ,s.[Country]
    ,s.[Description]
    ,[DoNotCall] = iif(s.[DoNotCall] = 1, 'true', 'false')
    ,s.[Email]
    ,s.[Fax]
    ,s.[FirstName]
    ,s.[FirstRespondedDate]
    ,[HasOptedOutOfEmail] = iif(s.[HasOptedOutOfEmail] = 1, 'true', 'false')
    ,[HasOptedOutOfFax] = iif(s.[HasOptedOutOfFax] = 1, 'true', 'false')
    ,[HasResponded] = iif(s.[HasResponded] = 1, 'true', 'false')
    ,s.[LastName]
    ,s.[LeadSource]
    ,s.[Licensee_text__c]
    ,s.[MobilePhone]
    ,s.[Name]
    ,s.[Phone]
    ,s.[PostalCode]
    ,s.[Salutation]
    ,s.[State]
    ,s.[Status]
    ,s.[Street]
    ,s.[Title]
    ,s.[Type]
    ,[LeadOrContactId] = coalesce(ra.[Id-tgt],'')
    ,[CampaignId] = coalesce(rcp.[Id-tgt],'')
    ,[ContactId] = coalesce(rc.[Id-tgt],'')
    ,[LeadOrContactOwnerId] = coalesce(ruat.[Id],'')
    ,[LeadId] = ''  --coalesce(x.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Campaign] rcp
    on rcp.[Id-src] = s.[CampaignId]
left join [cte_Contact] ra
    on ra.[Id-src] = s.[LeadOrContactId]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[ContactId]
left join [cte_User] ruat
    on ruat.[Metazoa_External_ID__c] = s.[LeadOrContactOwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[CampaignId],'') is not null
and nullif(rcp.[id-tgt],'') is not null)
or nullif(s.[CampaignId],'') is null
)
and ((nullif(s.[LeadOrContactId],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[LeadOrContactId],'') is null
)
and ((nullif(s.[ContactId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[ContactId],'') is null
)
and ((nullif(s.[LeadOrContactOwnerId],'') is not null
and nullif(ruat.[id],'') is not null)
or nullif(s.[LeadOrContactOwnerId],'') is null
)
GO
