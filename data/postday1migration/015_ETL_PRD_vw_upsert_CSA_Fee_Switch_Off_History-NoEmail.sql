Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_CSA_Fee_Switch_Off_History-NoEmail]
go

create view [sfrhd].[vw_upsert_CSA_Fee_Switch_Off_History-NoEmail] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_ASF as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASF_CSA_Case__c] i
    join [SalesforceMigration].[sfrhd].[ASF_CSA_Case__c] r
        on r.[Integration_Id__c] = i.[Integration_Id__c]
)
,cte_ASF_v as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASF_CSA_Case_dv__c] i
    join [SalesforceMigration].[sfrhd].[ASF_CSA_Case_dv__c] r
        on r.[Integration_Id__c] = i.[Integration_Id__c]
)
,cte_CSA as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[CSA_Case__c] i
    join [SalesforceMigration].[sfrhd].[CSA_Case__c] r
        on r.[Integration_Id__c] = i.[Integration_Id__c]
)
,cte_CSA_v as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[CSA_Case_dv__c] i
    join [SalesforceMigration].[sfrhd].[CSA_Case_dv__c] r
        on r.[Integration_Id__c] = i.[Integration_Id__c]
)
,cte_src as (
    select s.*
    from [SalesforceMigration].[sf].[CSA_Fee_Switch_Off_History__c] s (nolock)
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
    and s.[Email_Log__c] is null
)
select
    [Id] = ''
    ,[Metazoa_External_ID__c] = coalesce(s.[Id],'')
    ,s.[Email_Sent_Status__c]
    ,s.[Email_sub_status__c]
    ,s.[Error_Message__c]
    ,s.[Name]
    ,[Processed_to_send_email__c] = iif(s.[Processed_to_send_email__c] = 1, 'true', 'false')
    ,[ASF_CSA_Case__c] = coalesce(a.[Id-tgt],'')
    ,[CSA_Case__c] = coalesce(c.[Id-tgt],'')
    ,[ASF_CSA_Case_dv__c] = coalesce(av.[Id-tgt],'')
    ,[CSA_Case_dv__c] = coalesce(cv.[Id-tgt],'')
    ,[Email_Log__c] = ''
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_ASF] a 
    on a.[id-src] = s.[ASF_CSA_Case__c]
left join [cte_CSA] c
    on c.[id-src] = s.[CSA_Case__c]
left join [cte_ASF_v] av
    on av.[id-src] = s.[ASF_CSA_Case_dv__c]
left join [cte_CSA_v] cv
    on cv.[id-src] = s.[CSA_Case_dv__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
go
