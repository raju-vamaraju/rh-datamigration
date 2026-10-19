USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_legal]    Script Date: 9/5/2026 7:56:12 PM ******/
DROP VIEW IF EXISTS [dv].[vw_aug_lnd_ra_adviser_hs_User_legal]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_legal]    Script Date: 9/5/2026 7:56:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dv].[vw_aug_lnd_ra_adviser_hs_User_legal]
AS
select distinct 
	[User Entity Id] = [ADVISER ID]
	,[Authorised Rep No] = null
	,[ASIC No] = iif([ASIC NUMBER]='',NULL,[ASIC NUMBER])
	,[AFSL Number] = null
	,[AFSL Name] = null
	,[LICENSEE]
	,[ASIC Start Date] = IIF([ASIC START DATE]='',null,[ASIC START DATE])
	,[ASIC Ceased Date] = IIF([ASIC CEASED DATE]='',NULL,[ASIC CEASED DATE])
	,[map_date] 
from [ADVICE_ETL_STG].[lnd].[ra_adviser] (nolock)
where [map_date] is not null
and [LICENSEE] in ('Bridges', 'Shadforth', 'Navara')	-- to allow both AFSLs
GO
