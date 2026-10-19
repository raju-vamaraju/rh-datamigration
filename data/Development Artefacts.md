# Development Artefacts for Salesforce Migration Project
## 1. IDS Folders
### a. Development folder
- E:\Development\DataVault\Data Stream DV\20260409 Day1 Migration
### b. IDS files
1. Source files
i. Z:\RA-Pdrive\UAT\IDS\AdviserHUB-RA
- \<yyyyMMdd\>_RA_D_ASFCSA_ControlDate.csv
- \<yyyyMMdd\>_RA_D_CSA_ControlDate.csv
- \<yyyyMMdd\>_RA_D_Adviser.csv
2. Work files
i. 
3. Output files

## 2. IDS Scripts
In folder "E:\LocalExec\UAT"
1. run_pyLoad_IDS-RA.cmd
2. pyLoad_csvToDv-RA.py
## 3. IDS Database Changes

## 4. DataLoader Config and Jobs
1. E:\LocalExec\UAT\RHUAT\DataLoader
- conf\process-conf.xml
- conf\database-conf.xml
- bin\AdviserDailyExtract.bat
- bin\ASFCSACaseDVDeleteSQL.bat
- bin\ASFCSACaseDVUpsertSQL.bat
- bin\ASFCSAControlDateDailyExtract.bat
- bin\CSACaseDVDeleteSQL.bat
- bin\CSACaseDVUpsertSQL.bat
- bin\CSAControlDateDailyExtract.bat
## 5. Task Scheduler Jobs
