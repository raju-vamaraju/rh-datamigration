Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Wealth_Central_Adoption-ALL]
go

create view [sfrhd].[vw_upsert_Wealth_Central_Adoption-ALL] as
with cte_Admin as (
    select top 1
        [Id]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Name] = 'Admin User'
    and [IsActive] = 1
)
,cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
    from [SalesforceMigration].[sf].[Wealth_Central_Adoption__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Wealth_Central_Adoption__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Access_before_1_Oct_2021__c]
    ,[Access_before_1_Oct_2021_C__c] = iif(s.[Access_before_1_Oct_2021_C__c] = 1, 'true', 'false')
    ,s.[Adviser_Moved_Practice__c]
    ,s.[Advocate__c]
    ,s.[Comments__c]
    ,s.[Comments_Non_HTML__c]
    ,s.[Committing_to_Adoption_Program__c]
    ,s.[Good_candidate_for_WC__c]
    ,s.[Historic_IOOF_pilot_participant__c]
    ,s.[Level_of_WC_access_unlocked__c]
    ,s.[MLC_Pilot_participant__c]
    ,s.[Name]
    ,s.[Not_interested_ready__c]
    ,s.[Peer_Group__c]
    ,s.[Reason_Why__c]
    ,s.[Successfully_embedded_WC__c]
    ,s.[Terminated_access__c]
    ,[Practice__c] = coalesce(ra.[Id-tgt],s.[Practice__c]+'+')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],s.[Adviser__c]+'+')
    ,[NominatedChampionAdviser__c] = coalesce(rcn.[Id-tgt],s.[NominatedChampionAdviser__c]+'+')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],s.[RecordTypeId]+'+')
    ,[User__c] = coalesce(ruo.[Id],s.[User__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[Practice__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_Contact] rcn
    on rcn.[Id-src] = s.[NominatedChampionAdviser__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
cross join [cte_Admin] ad
left join [cte_User] ruo
    on ruo.[Metazoa_External_ID__c] = s.[User__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Practice__c],'') is not null
--and nullif(ra.[id-tgt],'') is not null)
--or nullif(s.[Practice__c],'') is null
--)
--and ((nullif(s.[Adviser__c],'') is not null
--and nullif(rc.[id-tgt],'') is not null)
--or nullif(s.[Adviser__c],'') is null
--)
--and ((nullif(s.[NominatedChampionAdviser__c],'') is not null
--and nullif(rcn.[id-tgt],'') is not null)
--or nullif(s.[NominatedChampionAdviser__c],'') is null
--)
--and ((nullif(s.[RecordTypeId],'') is not null
--and nullif(rrt.[id-tgt],'') is not null)
--or nullif(s.[RecordTypeId],'') is null
--)
--and ((nullif(s.[User__c],'') is not null
--and nullif(ruo.[id],'') is not null)
--or nullif(s.[User__c],'') is null
--)
go
