Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Area_of_Advice-ALL]
go

create view [sfrhd].[vw_upsert_Area_of_Advice-ALL] as
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
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_Product2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Product2] i (nolock)
    join [SalesforceMigration].[sfrhd].[Product2] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_tgt as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sfrhd].[Area_of_Advice__c] s (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] t (nolock)
        on t.[Id] = s.[Adviser__c]
        --and t.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Area_of_Advice__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[Adviser__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Current_File_Number_for_Phase__c]
    ,s.[Current_Vetting_Phase__c]
    ,s.[Document_Received_Date__c]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,s.[Next_Vetting_Phase__c]
    ,s.[Number_of_Files_Approved__c]
    ,s.[Number_of_Files_in_Phase_Approved__c]
    ,s.[Number_of_Files_in_Phase_Not_Approved__c]
    ,s.[Number_of_Files_Not_Approved__c]
    ,s.[Number_of_Files_Submitted__c]
    ,[Reason_for_Vetting__c] = coalesce(s.[Reason_for_Vetting__c],'')
    ,s.[Vetting_Cleared_Date__c]
    ,s.[Vetting_Start_Date__c]
    ,s.[Vetting_Status__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
    ,[Area_of_Advice__c] = coalesce(rp.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_Product2] rp
    on rp.[Id-src] = s.[Area_of_Advice__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Area_of_Advice__c],'') is not null
and nullif(rp.[id-tgt],'') is not null)
or nullif(s.[Area_of_Advice__c],'') is null
)
go
