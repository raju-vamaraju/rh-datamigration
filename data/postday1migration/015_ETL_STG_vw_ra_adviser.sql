USE [ADVICE_ETL_STG]
GO

/****** Object:  View [lnd].[vw_ra_adviser]    Script Date: 9/5/2026 8:49:13 PM ******/
DROP VIEW if exists [lnd].[vw_ra_adviser]
GO

/****** Object:  View [lnd].[vw_ra_adviser]    Script Date: 9/5/2026 8:49:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************************
	Name:			[lnd].[vw_ra_adviser]
	Object Type:	Create View Script
	Created: 		Rato Li
	Description: 	View for loading RA Adviser file
	Primary Keys:	None
	Foreign Keys:	None
	
	Modifications:
	Date			Name					Description
	08/04/2026		Rato Li					Initial version
*****************************************************************************************************/
CREATE view [lnd].[vw_ra_adviser] as
SELECT [ADVISER ID]
      ,[PREFERRED NAME]
      ,[FIRST NAME]
      ,[LAST NAME]
      ,[ASIC NUMBER]
      ,[LICENSEE]
      ,[ASIC START DATE]
      ,[ASIC CEASED DATE]
      ,[STATUS]
      ,[SUB STATUS]
      ,[PARTNER AFSL]
	  ,[XPLAN ID]
      --,[map_date]
  FROM [lnd].[ra_adviser]
GO
