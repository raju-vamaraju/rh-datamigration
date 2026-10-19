# How to run the updated scripts in Rhombus UAT RHUAT
## 1. Downloading Extract_Date of ASF_CSA_Case_dv from RHUAT to file
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin\
ASFCSAControlDateDailyExtract.bat > ASFCSAControlDateDailyExtract.out
```
## 2. Downloading Extract_Date of CSA_Case_dv from RHUAT to file
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin\
CSAControlDateDailyExtract.bat > CSAControlDateDailyExtract.out
```
## 3. Downloading the Adviser details from RUHAT to file
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin\
AdviserDailyExtract.bat > AdviserDailyExtract.out
```
## 4. Transferring ASF Extract Date from file to table [ADVICE_ETL_STG].[lnd].[ra_asfcsa_controldate]
``` cmd
cd E:\LocalExec\UAT
call "C:/ProgramData/anaconda3/condabin/activate.bat" ids
python "E:/LocalExec/UAT/pyLoad_csvToDv-RA.py" --opt1 "\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA" --opt2 "Rhombus-SQL-Ser" --opt3 "ADVICE_ETL_STG" --opt4 "lnd" --opt5 "ra_asfcsa_controldate" --opt6 "ra" --opt7 "RA" --opt8 "RA_D_ASFCSA_ControlDate" --opt9 "ra" --opt12="no" --opt14="no"
conda deactivate
```
Sample output:
``` quote
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260429_RA_D_ASFCSA_ControlDate.csv
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260507_RA_D_ASFCSA_ControlDate.csv
New file found and started processing...
(1, 4)
Calling Powershell to load file into table view...
Return code given to Python script is: 0
stdout: b'sqlBulkInsert.ps1 :: csvFilePath: \\\\xplansqldb.file.core.windows.net\\sqldb\\RA-Pdrive\\UAT\\IDS\\AdviserHUB-RA\\20260507_RA_D_ASFCSA_ControlDate.csv\nsqlBulkInsert.ps1 :: serverInstance: Rhombus-SQL-Ser\nsqlBulkInsert
.ps1 :: database: ADVICE_ETL_STG\nsqlBulkInsert.ps1 :: tableName: [lnd].[vw_ra_asfcsa_controldate]\nsqlBulkInsert.ps1 :: timeout: 12000\nsqlBulkInsert.ps1 :: fieldDelim: ,\nsqlBulkInsert.ps1 :: quoted: True\nParsing CSV file...\nC
reating Datatable...\nAdding rows from CSV file to Datatable...\nWriting to SQL Server...\nElapsed time: 0:0:0\n'
stderr: b''
Updating [map_date]...
Executing loadFromFile sproc - [dv].[loadFromFile_lnd_ra_asfcsa_controldate]...
Updating File Control records...
New file processing completed..
```
Checking. Detail checking can be done inside the database. SQL script can be found in "ETL_STG-checkETL-ra_controlDates.sql" in folder "E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration"
``` sql
Use [ADVICE_ETL_STG]
go
select * from [lnd].[ra_asfcsa_controldate]
```
Expected Output
1. [MAX(EXTRACT_DATE__C)] - the date of the last upload of ASF CSA data to RUHUAT via DataLoader
2. [map_date] - date of downloading the ASF extract date; should match with the file name 20260507_RA_D_ASFCSA_ControlDate.csv
``` quote
MAX(EXTRACT_DATE__C)	COUNT(ID)	map_date
2026-05-07	876939	2026-05-07
```
## 5. Transferring CSA Extract Date from file to table [ADVICE_ETL_STG].[lnd].[ra_csa_controldate]
``` cmd
cd E:\LocalExec\UAT
call "C:/ProgramData/anaconda3/condabin/activate.bat" ids
python "E:/LocalExec/UAT/pyLoad_csvToDv-RA.py" --opt1 "\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA" --opt2 "Rhombus-SQL-Ser" --opt3 "ADVICE_ETL_STG" --opt4 "lnd" --opt5 "ra_csa_controldate" --opt6 "ra" --opt7 "RA" --opt8 "RA_D_CSA_ControlDate" --opt9 "ra" --opt12="no" --opt14="no"
conda deactivate
```
Sample output:
``` quote
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260429_RA_D_CSA_ControlDate.csv
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260504_RA_D_CSA_ControlDate.csv
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260507_RA_D_CSA_ControlDate.csv
New file found and started processing...
(1, 4)
Calling Powershell to load file into table view...
Return code given to Python script is: 0
stdout: b'sqlBulkInsert.ps1 :: csvFilePath: \\\\xplansqldb.file.core.windows.net\\sqldb\\RA-Pdrive\\UAT\\IDS\\AdviserHUB-RA\\20260507_RA_D_CSA_ControlDate.csv\nsqlBulkInsert.ps1 :: serverInstance: Rhombus-SQL-Ser\nsqlBulkInsert.ps
1 :: database: ADVICE_ETL_STG\nsqlBulkInsert.ps1 :: tableName: [lnd].[vw_ra_csa_controldate]\nsqlBulkInsert.ps1 :: timeout: 12000\nsqlBulkInsert.ps1 :: fieldDelim: ,\nsqlBulkInsert.ps1 :: quoted: True\nParsing CSV file...\nCreatin
g Datatable...\nAdding rows from CSV file to Datatable...\nWriting to SQL Server...\nElapsed time: 0:0:0\n'
stderr: b''
Updating [map_date]...
Executing loadFromFile sproc - [dv].[loadFromFile_lnd_ra_csa_controldate]...
Updating File Control records...
New file processing completed...
```
Checking. Detail checking can be done inside the database. SQL script can be found in "ETL_STG-checkETL-ra_controlDates.sql" in folder "E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration"
``` sql
Use [ADVICE_ETL_STG]
go
select * from [lnd].[ra_csa_controldate]
```
Expected Output
1. [MAX(EXTRACT_DATE__C)] - the date of the last upload of CSA data to RUHUAT via DataLoader
2. [map_date] - date of downloading the CSA extract date; should match with the file name 20260507_RA_D_CSA_ControlDate.csv
``` quote
MAX(EXTRACT_DATE__C)	COUNT(ID)	map_date
2026-05-07	89132	2026-05-07
```
## 6. Transferring Adviser details from file to table [ADVICE_ETL_STG].[lnd].[ra_adviser]
``` cmd
cd E:\LocalExec\UAT
call "C:/ProgramData/anaconda3/condabin/activate.bat" ids
python "E:/LocalExec/UAT/pyLoad_csvToDv-RA.py" --opt1 "\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA" --opt2 "Rhombus-SQL-Ser" --opt3 "ADVICE_ETL_STG" --opt4 "lnd" --opt5 "ra_adviser" --opt6 "ra" --opt7 "RA" --opt8 "RA_D_Adviser" --opt9 "ra" --opt12="no" --opt14="no"
conda deactivate
```
Sample output:
``` quote
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260423_RA_D_Adviser.csv
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260429_RA_D_Adviser.csv
\\xplansqldb.file.core.windows.net\sqldb\RA-Pdrive\UAT\IDS\AdviserHUB-RA\20260507_RA_D_Adviser.csv
New file found and started processing...
(1518, 14)
Calling Powershell to load file into table view...
Return code given to Python script is: 0
stdout: b'sqlBulkInsert.ps1 :: csvFilePath: \\\\xplansqldb.file.core.windows.net\\sqldb\\RA-Pdrive\\UAT\\IDS\\AdviserHUB-RA\\20260507_RA_D_Adviser.csv\nsqlBulkInsert.ps1 :: serverInstance: Rhombus-SQL-Ser\nsqlBulkInsert.ps1 :: dat
abase: ADVICE_ETL_STG\nsqlBulkInsert.ps1 :: tableName: [lnd].[vw_ra_adviser]\nsqlBulkInsert.ps1 :: timeout: 12000\nsqlBulkInsert.ps1 :: fieldDelim: ,\nsqlBulkInsert.ps1 :: quoted: True\nParsing CSV file...\nCreating Datatable...\n
Adding rows from CSV file to Datatable...\nWriting to SQL Server...\nElapsed time: 0:0:0\n'
stderr: b''
Updating [map_date]...
Executing loadFromFile sproc - [dv].[loadFromFile_lnd_ra_adviser]...
Updating File Control records...
New file processing completed...
```
Checking. Detail checking can be done inside the database. SQL script can be found in "ETL_STG-checkETL-ra_adviser.sql" in folder "E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration"
``` sql
Use [ADVICE_DATAVAULT_STG]
go
-- Landing ra_adviser
SELECT min([map_date]), max([map_date]), count(*)
  FROM [ADVICE_ETL_STG].[lnd].[ra_adviser]
```
Expected output:
``` quote
(No column name)	(No column name)	(No column name)
2026-05-07	2026-05-07	1518
```
## 7. Generate ASF export table [ADVICE_DATAVAULT_STG].[dv].[exp_xport_asf_csa_case-sfg]
``` sql
USE [ADVICE_DATAVAULT_STG]
GO
DECLARE	@return_value int
EXEC	@return_value = [dv].[gen_exp_xport_asf_csa_case-sfg]
SELECT	'Return Value' = @return_value
GO
```
Sample output:
``` quote
Return Value
1
(1 row affected)
(857919 rows affected)
(879833 rows affected)
(876939 rows affected)
(2369445 rows affected)
(6 rows affected)
(1 row affected)
(1 row affected)
Completion time: 2026-05-08T13:51:54.5616192+10:00
```
Checking. Detail checking can be done inside the database. SQL script can be found in "ETL_DATAVAULT-check-asf.sql" in folder "E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration"
``` quote
```
## 8. Generate CSA export table [ADVICE_DATAVAULT_STG].[dv].[exp_xport_csa_case-sfg]
``` sql
USE [ADVICE_DATAVAULT_STG]
GO
DECLARE	@return_value int
EXEC	@return_value = [dv].[gen_exp_xport_csa_case-sfg]
SELECT	'Return Value' = @return_value
GO
```
Sample output:
``` quote
Return Value
330
(1 row affected)
(256728 rows affected)
(225 rows affected)
(89007 rows affected)
(88427 rows affected)
(330 rows affected)
(1 row affected)
(1 row affected)
Completion time: 2026-05-08T14:07:49.7564717+10:00
```
Checking. Detail checking can be done inside the database. SQL script can be found in "ETL_DATAVAULT-check-csa.sql" in folder "E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration"
``` quote
Use [ADVICE_DATAVAULT_STG]
go
select [Licensee],[is_current],[count]=count(*)
FROM [ADVICE_DATAVAULT_STG].[dv].[exp_xport_csa_case-sfg]
where 1=1
and [is_current] = 1
group by [Licensee],[is_current]
order by [Licensee],[is_current]
;
SELECT *
FROM [ADVICE_DATAVAULT_STG].[dv].[exp_xport_csa_case-sfg]
where 1=1
and [is_current] = 1
and [Licensee] = 'Navara'
and [AdviserSFID] is null
go
```
## 9. Upload ASF export table to RHUAT via DataLoader
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin
ASFCSACaseDVUpsertSQL.bat > ASFCSACaseDVUpsertSQL.out
```
Checking - In log file in "E:\LocalExec\UAT\RHUAT\DataLoader\bin\ASFCSACaseDVUpsertSQL.out", look at the last line for any error.
``` quote
...
2026-05-08 14:22:18,398 INFO  [ASFCSACaseDVUpsert] progress.NihilistProgressAdapter setSubTask (NihilistProgressAdapter.java:78) - Retrieving Bulk Job Results
2026-05-08 14:24:14,145 INFO  [ASFCSACaseDVUpsert] progress.NihilistProgressAdapter doneSuccess (NihilistProgressAdapter.java:63) - The operation has fully completed.  There were 876939 successful upserts and 0 errors.
```
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin
ASFCSACaseDVDeleteSQL.bat > ASFCSACaseDVDeleteSQL.out
```
Checking - In log file in "E:\LocalExec\UAT\RHUAT\DataLoader\bin\ASFCSACaseDVDeleteSQL.out", look at the last line for any error.
``` quote
...
2026-05-08 14:27:24,312 INFO  [ASFCSACaseDVDeleteSQL] progress.NihilistProgressAdapter setSubTask (NihilistProgressAdapter.java:78) - Retrieving Bulk Job Results
2026-05-08 14:27:25,065 INFO  [ASFCSACaseDVDeleteSQL] progress.NihilistProgressAdapter doneSuccess (NihilistProgressAdapter.java:63) - The operation has fully completed.  There were 161 successful upserts and 0 errors.
```
## 10. Upload CSA export table to RHUAT via DataLoader
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin
CSACaseDVUpsertSQL.bat > CSACaseDVUpsertSQL.out
```
Checking - Log file in "E:\LocalExec\UAT\RHUAT\DataLoader\bin\CSACaseDVUpsertSQL.out"
``` quote
...
2026-05-08 14:29:47,730 INFO  [CSACaseDVUpsert] progress.NihilistProgressAdapter setSubTask (NihilistProgressAdapter.java:78) - Retrieving Bulk Job Results
2026-05-08 14:29:59,096 INFO  [CSACaseDVUpsert] progress.NihilistProgressAdapter doneSuccess (NihilistProgressAdapter.java:63) - The operation has fully completed.  There were 88427 successful upserts and 0 errors.
```
``` cmd
cd E:\LocalExec\UAT\RHUAT\DataLoader\bin
CSACaseDVDeleteSQL.bat > CSACaseDVDeleteSQL.out
```
Checking - Log file in "E:\LocalExec\UAT\RHUAT\DataLoader\bin\CSACaseDVUpsertSQL.out"
``` quote
...
2026-05-08 14:34:32,135 INFO  [CSACaseDVDeleteSQL] progress.NihilistProgressAdapter setSubTask (NihilistProgressAdapter.java:78) - Retrieving Bulk Job Results
2026-05-08 14:34:36,734 INFO  [CSACaseDVDeleteSQL] progress.NihilistProgressAdapter doneSuccess (NihilistProgressAdapter.java:63) - The operation has fully completed.  There were 35354 successful upserts and 0 errors.
```
## 11. Trigger DataSync in CRMA RHUAT
1. Object "ASF_CSA_Case_dv__c"
2. Object "CSA_Case_dv__c"
## 12. Trigger Dataflow "Analytics Dataflow IDS"
1. Dataflow "Analytics Dataflow IDS"
## 13. Check CSA dashboards in RHUAT
1. CSA - ASF Overview - IDS
2. CSA Activity Tracking - IDS
3. CSA DataIntegrity Issues - IDS
