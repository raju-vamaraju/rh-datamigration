# Automated running of the IDS processes in Rhombus UAT RHUAT
## 1. Downloading Extract_Date of ASF_CSA_Case_dv from RHUAT to file
``` cmd
Task Scheduler
Job - "UAT - AH ASFCSAControllDate Daily - Extract"
Triggers - 5am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
```
## 2. Downloading Extract_Date of CSA_Case_dv from RHUAT to file
``` cmd
Task Scheduler
Job - "UAT - AH CSAControlDate Daily - Extract"
Triggers - 5:05am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
```
## 3. Downloading the Adviser details from RUHAT to file
``` cmd
Task Scheduler
Job - "UAT - AH Adviser Daily - Extract"
Triggers - 5:10am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
```
## 4. Transferring ASF Extract Date from file to table [ADVICE_ETL_STG].[lnd].[ra_asfcsa_controldate]
## 5. Transferring CSA Extract Date from file to table [ADVICE_ETL_STG].[lnd].[ra_csa_controldate]
## 6. Transferring Adviser details from file to table [ADVICE_ETL_STG].[lnd].[ra_adviser]
## 7. Generate ASF export table [ADVICE_DATAVAULT_STG].[dv].[exp_xport_asf_csa_case-sfg]
## 8. Generate CSA export table [ADVICE_DATAVAULT_STG].[dv].[exp_xport_csa_case-sfg]
``` cmd
Task Scheduler
Job - "UAT - runPy Load IDS files"
Triggers - 8:30am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
```
## 9. Upload ASF export table to RHUAT via DataLoader
``` cmd
Task Scheduler
Job - "UAT - AH ASF CSA Case DV Upsert"
Triggers - 9am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
```
## 10. Upload CSA export table to RHUAT via DataLoader
``` cmd
Task Scheduler
Job - "UAT - AH CSA Case DV Upsert"
Triggers - 9:30am every Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
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
