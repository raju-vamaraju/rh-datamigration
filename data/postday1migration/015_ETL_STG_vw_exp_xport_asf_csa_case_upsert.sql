USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_exp_xport_asf_csa_case_upsert]    Script Date: 9/6/2026 12:36:59 AM ******/
DROP VIEW if exists [dv].[vw_exp_xport_asf_csa_case_upsert]
GO

/****** Object:  View [dv].[vw_exp_xport_asf_csa_case_upsert]    Script Date: 9/6/2026 12:36:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************************
Name:			[dv].[vw_exp_xport_asf_csa_case_upsert]
Object Type:	Create View Script
Created: 		Amit Kumar
Description: 	View for loading Delta Upsert records from [dv].[exp_xport_asf_csa_case] export table into AdviserHUB
Primary Keys:	None
Foreign Keys:	None
	
Modifications:
Date			Name					Description
17/09/2024		Amit Kumar				Initial version
*****************************************************************************************************/

CREATE view [dv].[vw_exp_xport_asf_csa_case_upsert]
AS
with cte_ten as (
	select * from (
		values
			('B')
			,('S')
	) as a ([dv_tenant_id])
)
,cte_date as (
	select [map_date] = max([last_seen])
	from [ADVICE_DATAVAULT_PRD].[dv].[l_Client_csaCase] h (nolock)
	join [cte_ten] t on t.[dv_tenant_id] = h.[dv_tenant_id]
)
--select * from [cte_date]
,cte_ctrdate as (
	select 
		/*max extract date represents the date of data upload, and 
		the map date for that data load would be a day before that date*/
		[last_map_date] = dateadd(dd,-1,hs.[max_extract_date])
		,[map_date] = t.[map_date]
	from [ADVICE_DATAVAULT_STG].[dv].[h_Control_Date] h (nolock)
	join [cte_date] t on t.[map_date] <= h.[last_seen]
	join [ADVICE_DATAVAULT_STG].[dv].[hs_Control_Date] hs (nolock)
		on hs.[h_surKey_Control_Date] = h.[h_surKey_Control_Date]	
		and getdate() >= hs.[dv_start_date]
		and getdate() < hs.[dv_end_date]
	where h.[custom_object_name] = 'ASF_CSA_Case_DV__c'
		and h.[dv_tenant_id] = 'RA'
)
--,cte_Contact as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Contact] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--)
--select * from [cte_ctrdate]
SELECT top 10000
	[Licensee] = (CASE WHEN COALESCE([Licensee], '')  = '' THEN '#N/A' ELSE [Licensee] END)
	,[EntityId] = (CASE WHEN [EntityId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [EntityId]) END)
	,[EntityName] = (CASE WHEN COALESCE([EntityName], '')  = '' THEN '#N/A' ELSE [EntityName] END)
	,[CommPayClientId] = (CASE WHEN [CommPayClientId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [CommPayClientId]) END)
	,[CommPayClientName] = (CASE WHEN COALESCE([CommPayClientName], '')  = '' THEN '#N/A' ELSE [CommPayClientName] END)
	,[AdviserEntityId] = (CASE WHEN [AdviserEntityId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [AdviserEntityId]) END)
	,[AdviserName] = (CASE WHEN COALESCE([AdviserName], '')  = '' THEN '#N/A' ELSE [AdviserName] END)
	,[AdviserSFID] = (CASE WHEN COALESCE([AdviserSFID], '')  = '' THEN '#N/A' ELSE [AdviserSFID] END)
	--,[AdviserSFID] = (CASE WHEN COALESCE([AdviserSFID], '')  = '' THEN '#N/A' ELSE c.[id-tgt] END)
	,[AuthorisedRepNo] = (CASE WHEN COALESCE([AuthorisedRepNo], '')  = '' THEN '#N/A' ELSE [AuthorisedRepNo] END)
	,[EntityCategory] = (CASE WHEN COALESCE([EntityCategory], '')  = '' THEN '#N/A' ELSE [EntityCategory] END)
	,[CommPayClientCategory] = (CASE WHEN COALESCE([CommPayClientCategory], '')  = '' THEN '#N/A' ELSE [CommPayClientCategory] END)
	,[CommPayContact] = (CASE WHEN COALESCE([CommPayContact], '')  = '' THEN '#N/A' ELSE [CommPayContact] END)
	,[AccountName] = (CASE WHEN COALESCE([AccountName], '')  = '' THEN '#N/A' ELSE [AccountName] END)
	,[AccountCode] = (CASE WHEN COALESCE([AccountCode], '')  = '' THEN '#N/A' ELSE [AccountCode] END)
	,[StatementNumber] = (CASE WHEN [StatementNumber] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(10), [StatementNumber]) END)
	,[StatementRecordDate] = [dv].[dtOffsetForUTC]([StatementRecordDate])
	,[PaymentPeriod] = (CASE WHEN COALESCE([PaymentPeriod], '')  = '' THEN '#N/A' ELSE [PaymentPeriod] END)
	,[PaymentPeriodStart] = [dv].[dtOffsetForUTC]([PaymentPeriodStart])
	,[PaymentPeriodEnd] = [dv].[dtOffsetForUTC]([PaymentPeriodEnd])
	,[SupplierName] = (CASE WHEN COALESCE([SupplierName], '')  = '' THEN '#N/A' ELSE [SupplierName] END)
	,[SupplierCode] = (CASE WHEN COALESCE([SupplierCode], '')  = '' THEN '#N/A' ELSE [SupplierCode] END)
	,[ProductName] = (CASE WHEN COALESCE([ProductName], '')  = '' THEN '#N/A' ELSE [ProductName] END)
	,[ProductCode] = (CASE WHEN COALESCE([ProductCode], '')  = '' THEN '#N/A' ELSE [ProductCode] END)
	,[MainRevenueType] = (CASE WHEN COALESCE([MainRevenueType], '')  = '' THEN '#N/A' ELSE [MainRevenueType] END)
	,[RevenueType] = (CASE WHEN COALESCE([RevenueType], '')  = '' THEN '#N/A' ELSE [RevenueType] END)
	,[PolicyNumber] = (CASE WHEN COALESCE([PolicyNumber], '')  = '' THEN '#N/A' ELSE [PolicyNumber] END)
	,[NetAmount] = (CASE WHEN [NetAmount] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(14), [NetAmount]) END)
	,[GSTAmount] = (CASE WHEN [GSTAmount] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(14), [GSTAmount]) END)
	,[ThreadId] = (CASE WHEN [ThreadId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [ThreadId]) END)
	,[ThreadName] = (CASE WHEN COALESCE([ThreadName], '')  = '' THEN '#N/A' ELSE [ThreadName] END)
	,[ThreadStatus] = (CASE WHEN COALESCE([ThreadStatus], '')  = '' THEN '#N/A' ELSE [ThreadStatus] END)
	,[EntityGroups] = (CASE WHEN COALESCE([EntityGroups], '')  = '' THEN '#N/A' ELSE [EntityGroups] END)
	,[DateCreated] = [dv].[dtOffsetForUTC]([DateCreated])
	,[ScenarioId] = (CASE WHEN [ScenarioId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [ScenarioId]) END)
	,[CommencementDate] = [dv].[dtOffsetForUTC]([CommencementDate])
	,[CSAEndDate] = [dv].[dtOffsetForUTC]([CSAEndDate])
	,[ClientAuthorisationComplete] = (CASE WHEN COALESCE([ClientAuthorisationComplete], '')  = '' THEN '#N/A' ELSE [ClientAuthorisationComplete] END)
	,[CompleteDate] = [dv].[dtOffsetForUTC]([CompleteDate])
	,[HasLinkedCSACase] = (CASE WHEN [HasLinkedCSACase] IS NULL THEN '#N/A' WHEN HasLinkedCSACase = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[HasLinkedASFRevenue] = (CASE WHEN [HasLinkedASFRevenue] IS NULL THEN '#N/A' WHEN HasLinkedASFRevenue = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[UnallocatedRevenueUnknownClient] = (CASE WHEN [UnallocatedRevenueUnknownClient] IS NULL THEN '#N/A' WHEN UnallocatedRevenueUnknownClient = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[UnallocatedRevenueUnknownAdviser] = (CASE WHEN [UnallocatedRevenueUnknownAdviser] IS NULL THEN '#N/A' WHEN UnallocatedRevenueUnknownAdviser = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[ASFPriorToFirstCSA] = (CASE WHEN [ASFPriorToFirstCSA] IS NULL THEN '#N/A' WHEN ASFPriorToFirstCSA = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[NewClientASFPriorToFirstCSA] = (CASE WHEN [NewClientASFPriorToFirstCSA] IS NULL THEN '#N/A' WHEN NewClientASFPriorToFirstCSA = 1 THEN 'TRUE' ELSE 'FALSE' END)
	,[IntegrationID] = CONVERT(VARCHAR(255), [IntegrationID], 2)
	,[ExtractDate] = [dv].[dtOffsetForUTC](convert(datetime, dateadd(dd, 1, ctrdt.[map_date])))
	,[IsActive] = 'Yes'
FROM [ADVICE_DATAVAULT_STG].[dv].[exp_xport_asf_csa_case-ra] (nolock) asf
join [cte_ctrdate] ctrdt
	on ctrdt.[map_date] >= asf.[dv_start_date]
	and ctrdt.[map_date] < asf.[dv_end_date] 
	and ctrdt.[last_map_date] < asf.[dv_start_date]
	--on '2026-07-01' < asf.[dv_start_date]
--left join [cte_Contact] c
--	on c.[id-src] COLLATE SQL_Latin1_General_CP1_CI_AS
--    = asf.[AdviserSFID] COLLATE SQL_Latin1_General_CP1_CI_AS
GO
