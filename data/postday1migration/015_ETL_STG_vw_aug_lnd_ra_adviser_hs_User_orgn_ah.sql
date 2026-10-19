USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_orgn_ah]    Script Date: 9/5/2026 7:57:38 PM ******/
DROP VIEW if exists [dv].[vw_aug_lnd_ra_adviser_hs_User_orgn_ah]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_orgn_ah]    Script Date: 9/5/2026 7:57:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dv].[vw_aug_lnd_ra_adviser_hs_User_orgn_ah]
AS
select distinct 
	[User Entity Id] = [ADVISER ID]
	,[Status] = IIF([STATUS]='',NULL,[STATUS])
	,[Sub Status] = IIF([SUB STATUS]='',NULL,[SUB STATUS])
	,[Xplan ID] = IIF([XPLAN ID]='',NULL,[XPLAN ID])
	,[LICENSEE]
	,[map_date] 
from [ADVICE_ETL_STG].[lnd].[ra_adviser] (nolock)
where [map_date] is not null
and [LICENSEE] in ('Bridges', 'Shadforth', 'Navara')	-- to allow both AFSLs
GO
