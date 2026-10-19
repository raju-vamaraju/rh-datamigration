Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Snapshot_Data-ALL]
go

create view [sfrhd].[vw_upsert_Snapshot_Data-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Area_of_Advice as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Area_of_Advice__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Area_of_Advice__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
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
    from [SalesforceMigration].[sf].[Snapshot_Data__c] s (nolock)
    join [SalesforceMigration].[sf].[Question_Responses__c] c
        on c.[Id] = s.[Incident__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Snapshot_Data__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,[Case_Status__c] = ''
    ,s.[Case_Type__c]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,s.[Shapshot_Frequency__c]
    ,s.[Snapshot_Date__c]
    ,s.[Snapshot_Type__c]
    ,s.[Status__c]
    ,s.[Vetting_Reason__c]
    ,s.[Vetting_Status__c]
    ,[Area_of_Advice__c] = coalesce(raa.[Id-tgt],s.[Area_of_Advice__c]+'+')
    ,[Case__c] = coalesce(rc.[Id-tgt],s.[Case__c]+'+')
    ,[Incident__c] = coalesce(rqr.[Id-tgt],s.[Incident__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Area_of_Advice] raa
    on raa.[Id-src] = s.[Area_of_Advice__c]
left join [cte_Case] rc
    on rc.[Id-src] = s.[Case__c]
left join [cte_Question_Responses] rqr
    on rqr.[Id-src] = s.[Incident__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Area_of_Advice__c],'') is not null
--and nullif(raa.[id-tgt],'') is not null)
--or nullif(s.[Area_of_Advice__c],'') is null
--)
--and ((nullif(s.[Case__c],'') is not null
--and nullif(rc.[id-tgt],'') is not null)
--or nullif(s.[Case__c],'') is null
--)
--and ((nullif(s.[Incident__c],'') is not null
--and nullif(rqr.[id-tgt],'') is not null)
--or nullif(s.[Incident__c],'') is null
--)
go
