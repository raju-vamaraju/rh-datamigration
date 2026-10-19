USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_csa_controldate_hs_Control_Date]    Script Date: 9/5/2026 8:00:44 PM ******/
DROP VIEW if exists [dv].[vw_aug_lnd_ra_csa_controldate_hs_Control_Date]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_csa_controldate_hs_Control_Date]    Script Date: 9/5/2026 8:00:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dv].[vw_aug_lnd_ra_csa_controldate_hs_Control_Date]
AS
select distinct 
	[custom_object_name] = 'CSA_Case_DV__c'
	,[max_extract_date] = [MAX(EXTRACT_DATE__C)]
	,[record_count] = [COUNT(ID)]
	,[map_date] = iif([map_date]>getdate()-1,getdate()-1,[map_date])
from [ADVICE_ETL_STG].[lnd].[ra_csa_controldate] (nolock)
where [map_date] is not null
GO
