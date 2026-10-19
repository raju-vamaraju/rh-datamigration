USE [ADVICE_DATAVAULT_STG]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_private]    Script Date: 9/5/2026 7:58:46 PM ******/
DROP VIEW if exists [dv].[vw_aug_lnd_ra_adviser_hs_User_private]
GO

/****** Object:  View [dv].[vw_aug_lnd_ra_adviser_hs_User_private]    Script Date: 9/5/2026 7:58:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dv].[vw_aug_lnd_ra_adviser_hs_User_private]
AS
select distinct 
	[User Entity Id] = [ADVISER ID]
	,[Surname] = IIF([LAST NAME]='',NULL,[LAST NAME])
	,[First Name] = IIF([FIRST NAME]='',NULL,[FIRST NAME])
	,[User Entity Name] = null
	,[Preferred Name] = IIF([PREFERRED NAME]='',NULL,[PREFERRED NAME])
	,[LICENSEE]
	,[map_date] 
from [ADVICE_ETL_STG].[lnd].[ra_adviser] (nolock)
where [map_date] is not null
and [LICENSEE] in ('Bridges', 'Shadforth', 'Navara')	-- to allow both AFSLs
GO
