
SELECT * FROM [SalesforceMigration].[dbo].[AttachmentMigrationLedger]

SELECT * FROM [SalesforceMigration].[dbo].[FileMigrationLedger]

SELECT * FROM [SalesforceMigration].[dbo].[MigrationRun]

SELECT * FROM [SalesforceMigration].[dbo].[ObjectMigrationLedger]

SELECT * FROM [SalesforceMigration].[dbo].[ParentMapping]

SELECT *
FROM [SalesforceMigration].[dbo].[sf_file_items] (nolock)

SELECT [status], count(*) 
FROM [SalesforceMigration].[dbo].[sf_file_items] (nolock)
group by [status]
order by [status]

-- truncate table [SalesforceMigration].[dbo].[sf_file_items]

SELECT [prefix]=left([source_parent_id],3), count(*) 
FROM [SalesforceMigration].[dbo].[sf_file_links] (nolock)
group by left([source_parent_id],3)
order by left([source_parent_id],3)
/*
prefix	(No column name)
001		36	-- Account
00T		6709	-- OpportunityShare
00X		5	-- EmailTemplate
500		9	-- Case
a09		11212	-- Assurance_Review__c
a0F		3332	-- Incident_File_Review__c
a0H		26		-- PSA__c
a0N		71400	-- Question_Responses__c
*/

SELECT * FROM [SalesforceMigration].[dbo].[sf_file_links] (nolock)
-- truncate table [SalesforceMigration].[dbo].[sf_file_links]
SELECT * FROM [SalesforceMigration].[dbo].[sf_file_migration_ledger]
;
/* check migration status */
SELECT [Status]
      ,count(*)
  FROM [SalesforceMigration].[dbo].[AttachmentMigrationLedger]
group by [Status]
order by [Status]
