Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_A1_Support_Staff_Registrations-ALL]
go

create view [sfrhd].[vw_upsert_A1_Support_Staff_Registrations-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
--,cte_Account as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Account] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
--        --on r.[Name] = replace(i.[Name],'Shadforth','Navara')
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        --and r.[Licensee__c] = 'Shadforth'
--    where 1=1
--    --and i.[Licensee__c] = 'Shadforth'
--)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
--,cte_Profile as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Profile] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Profile] r (nolock)
--        on r.[Name] = i.[Name]
--    where 1=1
--    and isnull(r.[Name],'') is not null
--)
--,cte_UserRole as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[UserRole] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[UserRole] r (nolock)
--        on r.[Name] = i.[Name]
--    where 1=1
--    and isnull(r.[Name],'') is not null
--    -- 'Shadforth Head Office Customer User' is missing in RH
--)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[A1_Support_Staff_Registrations__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[A1_Support_Staff_Registrations__c] t (nolock)
        on t.[Email_Address__c] = s.[Email_Address__c]
--        and t.[Licensee__c] = 'Shadforth'
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Approval_Status__c]
    ,s.[Email_Address__c]
    ,s.[First_Name__c]
    ,s.[Last_Name__c]
    ,s.[Name]
    ,s.[Role__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
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
go
