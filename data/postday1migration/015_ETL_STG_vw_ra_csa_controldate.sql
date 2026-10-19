USE [ADVICE_ETL_STG]
GO

/****** Object:  View [lnd].[vw_ra_csa_controldate]    Script Date: 9/5/2026 8:50:51 PM ******/
DROP VIEW if exists [lnd].[vw_ra_csa_controldate]
GO

/****** Object:  View [lnd].[vw_ra_csa_controldate]    Script Date: 9/5/2026 8:50:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************************
	Name:			[lnd].[vw_ra_csa_controldate]
	Object Type:	Create View Script
	Created: 		Rato Li
	Description: 	View for loading AH CSA ControlDate file
	Primary Keys:	None
	Foreign Keys:	None
	
	Modifications:
	Date			Name					Description
	08/04/2026		Rato Li					Initial version
*****************************************************************************************************/
CREATE view [lnd].[vw_ra_csa_controldate] as
SELECT
	[MAX(EXTRACT_DATE__C)]
	,[COUNT(ID)]
	--,[map_date]
FROM [lnd].[ra_csa_controldate]
GO
