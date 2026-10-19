USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_exp_xport_asf_csa_case_delete]    Script Date: 9/6/2026 12:47:42 AM ******/
DROP VIEW if exists [dv].[vw_exp_xport_asf_csa_case_delete]
GO

/****** Object:  View [dv].[vw_exp_xport_asf_csa_case_delete]    Script Date: 9/6/2026 12:47:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************************
Name:			[dv].[vw_exp_xport_asf_csa_case_delete]
Object Type:	Create View Script
Created: 		Amit Kumar
Description: 	View for loading Delta Delete records from [dv].[exp_xport_asf_csa_case] export table into AdviserHUB
Primary Keys:	None
Foreign Keys:	None
	
Modifications:
Date			Name					Description
17/09/2024		Amit Kumar				Initial version
23/09/2024		Amit Kumar				Changed the filters to fix the issue with picking up incorrect delta records
*****************************************************************************************************/

CREATE view [dv].[vw_exp_xport_asf_csa_case_delete]
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
		and h.[dv_tenant_id] = 'RA' --AdviserHUB PROD
)
--select * from [cte_ctrdate]
select
	(CASE WHEN COALESCE([Licensee], '')  = '' THEN '#N/A' ELSE [Licensee] END) AS [Licensee]
	,(CASE WHEN [EntityId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [EntityId]) END) AS [EntityId]
	,(CASE WHEN COALESCE([EntityName], '')  = '' THEN '#N/A' ELSE [EntityName] END) AS [EntityName]
	,(CASE WHEN COALESCE([PaymentPeriod], '')  = '' THEN '#N/A' ELSE [PaymentPeriod] END) AS [PaymentPeriod]
	,(CASE WHEN COALESCE([SupplierCode], '')  = '' THEN '#N/A' ELSE [SupplierCode] END) AS [SupplierCode]
	,(CASE WHEN COALESCE([ProductName], '')  = '' THEN '#N/A' ELSE [ProductName] END) AS [ProductName]
	,(CASE WHEN COALESCE([ProductCode], '')  = '' THEN '#N/A' ELSE [ProductCode] END) AS [ProductCode]
	,(CASE WHEN COALESCE([MainRevenueType], '')  = '' THEN '#N/A' ELSE [MainRevenueType] END) AS [MainRevenueType]
	,(CASE WHEN COALESCE([RevenueType], '')  = '' THEN '#N/A' ELSE [RevenueType] END) AS [RevenueType]
	,(CASE WHEN COALESCE([PolicyNumber], '')  = '' THEN '#N/A' ELSE [PolicyNumber] END) AS [PolicyNumber]
	,(CASE WHEN [ThreadId] IS NULL THEN '#N/A' ELSE CONVERT(VARCHAR(20), [ThreadId]) END) AS [ThreadId]
	,CONVERT(VARCHAR(255), asf.[IntegrationID], 2) AS [IntegrationID]
	,'No' AS [IsActive]
from [ADVICE_DATAVAULT_STG].[dv].[exp_xport_asf_csa_case-ra] (nolock) asf
join
	(select a.IntegrationId from 
		(select IntegrationId, max(case [is_current] when 1 then 1 else 0 end) as IsCurrentMax
		from [ADVICE_DATAVAULT_STG].[dv].[exp_xport_asf_csa_case-ra]
		group by IntegrationId) a
	where a.IsCurrentMax = 0) non_curr_asf
	on asf.IntegrationID = non_curr_asf.IntegrationID
join [cte_ctrdate] ctrdt
	--on ctrdt.[map_date] >= asf.[dv_start_date]
	--and ctrdt.[map_date] >= asf.[dv_end_date] 
	--and ctrdt.[last_map_date] < asf.[dv_end_date] 
	--and ctrdt.[last_map_date] >= asf.[dv_start_date]
	on asf.[dv_end_date] > ctrdt.[last_map_date]
	and asf.[dv_end_date] <= ctrdt.[map_date]
GO
