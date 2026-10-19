Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Email_Log-Run2Upsert]
go

create view [sfrhd].[vw_upsert_Email_Log-Run2Upsert] as
/*
    RUN 2 - After loading CSA_Fee_Switch_Off_History__c, join Email_Log__c with CSA_Fee_Switch_Off_History__c
            to find the new CSA_Fee_Switch_Off_History__c and store in its empty column.
        - UPSERT mode
*/
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
    where 1=1
)
,cte_FSO as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[CSA_Fee_Switch_Off_History__c] i (nolock)
    join [SalesforceMigration].[sf].[Email_Log__c] e
        on e.[Fee_Switch_Off_History__c] = i.[Id]
    join [SalesforceMigration].[sfrhd].[Email_Log__c] re
        on re.[Metazoa_External_ID__c] = e.[Id]
    join [SalesforceMigration].[sfrhd].[CSA_Fee_Switch_Off_History__c] r
        on r.[Email_Log__c] = re.[Id]
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    left join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
    where 1=1
)
,cte_Third_Party_Provider as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Third_Party_Provider_Name__c]
        ,[Name-tgt] = r.[Third_Party_Provider_Name__c]
    from [SalesforceMigration].[sf].[Third_Party_Provider__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Third_Party_Provider__c] r (nolock)
        on r.[Third_Party_Provider_Name__c] = i.[Third_Party_Provider_Name__c]
)
/* Pass 2 - FSO loaded already */
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Email_Log__c] s (nolock)
    join [SalesforceMigration].[sf].[CSA_Fee_Switch_Off_History__c] c (nolock)
        on c.[Id] = s.[Fee_Switch_Off_History__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    join [SalesforceMigration].[sfrhd].[Email_Log__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Email__c]
    ,s.[Email_Sent_Date__c]
    ,s.[Email1__c]
    ,s.[Email2__c]
    ,[First_Notification_Sent__c] = iif(s.[First_Notification_Sent__c] = 1, 'true', 'false')
    ,s.[First_Notification_Sent_Date__c]
    ,[Second_Notification_Sent__c] = iif(s.[Second_Notification_Sent__c] = 1, 'true', 'false')
    ,s.[Second_Notification_Sent_Date__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
    /* Pass 1 - FSO not loaded yet */
    --,[Fee_Switch_Off_History__c] = ''
    /* Pass 2 - FSO loaded already */
    ,[Fee_Switch_Off_History__c] = coalesce(rfso.[Id-tgt],'')
    ,[Knowledge__c] = ''
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Third_Party_Provider__c] = coalesce(tpp.[Id-tgt],'')
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_FSO] rfso
    on rfso.[Id-src] = s.[Fee_Switch_Off_History__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_Third_Party_Provider] tpp
    on tpp.[Id-src] = s.[Third_Party_Provider__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Fee_Switch_Off_History__c],'') is not null
and nullif(rfso.[id-tgt],'') is not null)
or nullif(s.[Fee_Switch_Off_History__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Third_Party_Provider__c],'') is not null
and nullif(tpp.[id-tgt],'') is not null)
or nullif(s.[Third_Party_Provider__c],'') is null
)
go
