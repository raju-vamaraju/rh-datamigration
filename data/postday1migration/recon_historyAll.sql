with cte_hist as (
    select distinct *
    FROM [ADVICE_ETL_PRD].[sf].[CSA_Fee_Switch_Off_History__c] h (nolock)
    where 1=1
    and [Licensee__c] = 'Shadforth'
--and [Name] in ('FSO-005094','FSO-005115')
--and [asf_csa_case_dv__c] is not null
--and h.[ASF_CSA_Case_dv__c] = 'a26Mq000003CnywIAC'
and h.[CSA_Case_dv__c] = 'a25Mq000001fgP6IAI'
--order by h.[Name]
)
,cte_ASF as (
    select
        i.*
        ,[ASFKey] = concat( ''
                        , COALESCE(i.[Adviser_Name__c], '') ,'|'
                        , COALESCE(i.[CommPay_Contact__c], '') ,'|'
                        , COALESCE(UPPER(i.[Entity_Name__c]), '') ,'|'
                        , COALESCE(i.[Account_Name__c], '') ,'|'
                        , COALESCE(i.[Account_Code__c], '') ,'|'
                        , COALESCE(i.[Statement_Number__c], '') ,'|'
                        , COALESCE(i.[Statement_Record_Date__c], '') ,'|'
                        , COALESCE(i.[Payment_Period__c], '') ,'|'
                        , COALESCE(i.[Payment_Period_Start__c], '') ,'|'
                        , COALESCE(i.[Payment_Period_End__c], '') ,'|'
                        , COALESCE(i.[CommPay_Client_Id__c], '') ,'|'
                        , COALESCE(i.[CommPay_Client_Name__c], '') ,'|'
                        , COALESCE(i.[Supplier_Name__c], '') ,'|'
                        , COALESCE(i.[Supplier_Code__c], '') ,'|'
                        , COALESCE(i.[Product_Name__c], '') ,'|'
                        , COALESCE(i.[Policy_Number__c], '') ,'|'
                        , COALESCE(i.[Main_Revenue_Type__c], '') ,'|'
                        , COALESCE(i.[Revenue_Type__c], '') ,'|'
                        , COALESCE(i.[Net_Amount__c], '') ,'|'
                        , COALESCE(i.[GST_Amount__c], '') ,'|'
                        , COALESCE(i.[Commencement_Date__c], '') ,'|'
                        , COALESCE(i.[Complete_Date__c], '') ,'|'
                        , COALESCE(i.[Is_Active__c], '') ,'|'
                        , COALESCE(i.[Thread_Id__c], '') ,'|'
                        --, COALESCE(i.[Extract_Date__c], '') ,'|'
                    )
    from [ADVICE_ETL_PRD].[sf].[ASF_CSA_Case_dv__c] i (nolock)
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
--and [Thread_Id__c] = '413411' -- '371610' -- '367178' --'419422'   --'383596'
--and [Name] in ('ASF2754051','ASF2874641')
)
--select h.*
--from [cte_hist] h
--join [cte_ASF] a
--    on a.[Id] = h.[ASF_CSA_Case_dv__c]
,cte_CSA as (
    select
        i.*
        ,[CSAKey] = concat(''
				        , COALESCE(i.[Entity_Id__c], '') ,'|'
				        , COALESCE(i.[Benchmark_Description__c], '') ,'|'
				        , COALESCE(i.[Item__c], '') ,'|'
				        , COALESCE(i.[Item_Id__c], '') ,'|'
				        , COALESCE(i.[Thread_Id__c], '') ,'|'
				    )
    from [ADVICE_ETL_PRD].[sf].[CSA_Case_dv__c] i (nolock)
    join [ADVICE_ETL_PRD].[sf].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
        and c.[Licensee__c] = 'Shadforth'
)
--select * from [cte_CSA] where [Thread_Id__c] = '386081'
,cte_fullHist as (
    SELECT a.[ASFKey]
        ,c.[CSAKey]
        ,h.*
    -- select count(*)
    from [cte_hist] h
    join [cte_ASF] a (nolock)
        on a.[Id] = h.[ASF_CSA_Case_dv__c]
    join [cte_CSA] c (nolock)
        on c.[Id] = h.[CSA_Case_dv__c]
) 
--select * from [cte_fullHist]
,cte_ASF_sfg as (
    select
        i.*
        ,[ASFKey] = concat( ''
                        , COALESCE(i.[Adviser_Name__c], '') ,'|'
                        , COALESCE(i.[CommPay_Contact__c], '') ,'|'
                        , COALESCE(UPPER(i.[Entity_Name__c]), '') ,'|'
                        , COALESCE(i.[Account_Name__c], '') ,'|'
                        , COALESCE(i.[Account_Code__c], '') ,'|'
                        , COALESCE(i.[Statement_Number__c], '') ,'|'
                        , COALESCE(i.[Statement_Record_Date__c], '') ,'|'
                        , COALESCE(i.[Payment_Period__c], '') ,'|'
                        , COALESCE(i.[Payment_Period_Start__c], '') ,'|'
                        , COALESCE(i.[Payment_Period_End__c], '') ,'|'
                        , COALESCE(i.[CommPay_Client_Id__c], '') ,'|'
                        , COALESCE(i.[CommPay_Client_Name__c], '') ,'|'
                        , COALESCE(i.[Supplier_Name__c], '') ,'|'
                        , COALESCE(i.[Supplier_Code__c], '') ,'|'
                        , COALESCE(i.[Product_Name__c], '') ,'|'
                        , COALESCE(i.[Policy_Number__c], '') ,'|'
                        , COALESCE(i.[Main_Revenue_Type__c], '') ,'|'
                        , COALESCE(i.[Revenue_Type__c], '') ,'|'
                        , COALESCE(i.[Net_Amount__c], '') ,'|'
                        , COALESCE(i.[GST_Amount__c], '') ,'|'
                        , COALESCE(i.[Commencement_Date__c], '') ,'|'
                        , COALESCE(i.[Complete_Date__c], '') ,'|'
                        , COALESCE(i.[Is_Active__c], '') ,'|'
                        , COALESCE(i.[Thread_Id__c], '') ,'|'
                        --, COALESCE(i.[Extract_Date__c], '') ,'|'
                    )
    from [ADVICE_ETL_PRD].[sfrhd].[ASF_CSA_Case_dv__c] i (nolock)
    where 1=1
    and i.[Licensee__c] = 'Navara'
)
,cte_CSA_sfg as (
    select
        i.*
        ,[CSAKey] = concat(''
				        , COALESCE(i.[Entity_Id__c], '') ,'|'
				        , COALESCE(i.[Benchmark_Description__c], '') ,'|'
				        , COALESCE(i.[Item__c], '') ,'|'
				        , COALESCE(i.[Item_Id__c], '') ,'|'
				        , COALESCE(i.[Thread_Id__c], '') ,'|'
				    )
    from [ADVICE_ETL_PRD].[sfrhd].[CSA_Case_dv__c] i (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
        and c.[Licensee__c] = 'Navara'
where 1=1
and i.[Thread_Id__c] = '386081'
)
--,cte_recon_csa as (
select
    [Id-hist] = h.[Id]
    ,h.[ASF_CSA_Case_dv__c]
    ,h.[CSA_Case_dv__c]
    ,[CSAKey-src] = a.[CSAKey]
    ,[CSAKey-tgt] = af.[CSAKey]
    ,[Adviser__c-src] = a.[Adviser__c]
    ,[Adviser__c-tgt] = af.[Adviser__c]
    ,[Adviser_Entity_Id__c-src] = a.[Adviser_Entity_Id__c]
    ,[Adviser_Entity_Id__c-tgt] = af.[Adviser_Entity_Id__c]
    ,[Adviser_Name_Xplan__c-src] = a.[Adviser_Name_Xplan__c]
    ,[Adviser_Name_Xplan__c-tgt] = af.[Adviser_Name_Xplan__c]
    ,[ASIC_No_Xplan__c-src] = a.[ASIC_No_Xplan__c]
    ,[ASIC_No_Xplan__c-tgt] = af.[ASIC_No_Xplan__c]
    ,[Benchmark_Description__c-src] = a.[Benchmark_Description__c]
    ,[Benchmark_Description__c-tgt] = af.[Benchmark_Description__c]
    ,[Benchmark_Status__c-src] = a.[Benchmark_Status__c]
    ,[Benchmark_Status__c-tgt] = af.[Benchmark_Status__c]
    ,[Case_Overdue_Days__c-src] = a.[Case_Overdue_Days__c]
    ,[Case_Overdue_Days__c-tgt] = af.[Case_Overdue_Days__c]
    ,[Client_Authorisation_Complete__c-src] = a.[Client_Authorisation_Complete__c]
    ,[Client_Authorisation_Complete__c-tgt] = af.[Client_Authorisation_Complete__c]
    ,[Commencement_Date__c-src] = a.[Commencement_Date__c]
    ,[Commencement_Date__c-tgt] = af.[Commencement_Date__c]
    ,[Complete_Date__c-src] = a.[Complete_Date__c]
    ,[Complete_Date__c-tgt] = af.[Complete_Date__c]
    ,[CreatedById-src] = a.[CreatedById]
    ,[CreatedById-tgt] = af.[CreatedById]
    ,[CreatedDate-src] = a.[CreatedDate]
    ,[CreatedDate-tgt] = af.[CreatedDate]
    ,[CSASwitchoffcutoffDays__c-src] = a.[CSASwitchoffcutoffDays__c]
    ,[CSASwitchoffcutoffDays__c-tgt] = af.[CSASwitchoffcutoffDays__c]
    ,[Date_Created__c-src] = a.[Date_Created__c]
    ,[Date_Created__c-tgt] = af.[Date_Created__c]
    ,[Date_Linked__c-src] = a.[Date_Linked__c]
    ,[Date_Linked__c-tgt] = af.[Date_Linked__c]
    ,[Entity_Category__c-src] = a.[Entity_Category__c]
    ,[Entity_Category__c-tgt] = af.[Entity_Category__c]
    ,[Entity_Groups__c-src] = a.[Entity_Groups__c]
    ,[Entity_Groups__c-tgt] = af.[Entity_Groups__c]
    ,[Entity_Id__c-src] = a.[Entity_Id__c]
    ,[Entity_Id__c-tgt] = af.[Entity_Id__c]
    ,[Entity_Name__c-src] = a.[Entity_Name__c]
    ,[Entity_Name__c-tgt] = af.[Entity_Name__c]
    ,[Exclude_From_Back_Dating__c-src] = a.[Exclude_From_Back_Dating__c]
    ,[Exclude_From_Back_Dating__c-tgt] = af.[Exclude_From_Back_Dating__c]
    ,[Extract_Date__c-src] = a.[Extract_Date__c]
    ,[Extract_Date__c-tgt] = af.[Extract_Date__c]
    ,[Id-src] = a.[Id]
    ,[Id-tgt] = af.[Id]
    ,[Integration_Id__c-src] = a.[Integration_Id__c]
    ,[Integration_Id__c-tgt] = af.[Integration_Id__c]
    ,[Is_Active__c-src] = a.[Is_Active__c]
    ,[Is_Active__c-tgt] = af.[Is_Active__c]
    ,[IsDeleted-src] = a.[IsDeleted]
    ,[IsDeleted-tgt] = af.[IsDeleted]
    ,[Item__c-src] = a.[Item__c]
    ,[Item__c-tgt] = af.[Item__c]
    ,[Item_Id__c-src] = a.[Item_Id__c]
    ,[Item_Id__c-tgt] = af.[Item_Id__c]
    ,[Item_Status__c-src] = a.[Item_Status__c]
    ,[Item_Status__c-tgt] = af.[Item_Status__c]
    ,[LastActivityDate-src] = a.[LastActivityDate]
    ,[LastActivityDate-tgt] = af.[LastActivityDate]
    ,[LastModifiedById-src] = a.[LastModifiedById]
    ,[LastModifiedById-tgt] = af.[LastModifiedById]
    ,[LastModifiedDate-src] = a.[LastModifiedDate]
    ,[LastModifiedDate-tgt] = af.[LastModifiedDate]
    ,[Name-src] = a.[Name]
    ,[Name-tgt] = af.[Name]
    ,[OwnerId-src] = a.[OwnerId]
    ,[OwnerId-tgt] = af.[OwnerId]
    ,[Primary_User_Group__c-src] = a.[Primary_User_Group__c]
    ,[Primary_User_Group__c-tgt] = af.[Primary_User_Group__c]
    ,[Scenario_Id__c-src] = a.[Scenario_Id__c]
    ,[Scenario_Id__c-tgt] = af.[Scenario_Id__c]
    ,[Scheduled_Run_Date__c-src] = a.[Scheduled_Run_Date__c]
    ,[Scheduled_Run_Date__c-tgt] = af.[Scheduled_Run_Date__c]
    ,[Service_Frequency__c-src] = a.[Service_Frequency__c]
    ,[Service_Frequency__c-tgt] = af.[Service_Frequency__c]
    ,[Service_Name__c-src] = a.[Service_Name__c]
    ,[Service_Name__c-tgt] = af.[Service_Name__c]
    ,[Service_Package__c-src] = a.[Service_Package__c]
    ,[Service_Package__c-tgt] = af.[Service_Package__c]
    ,[Source_Template_Name__c-src] = a.[Source_Template_Name__c]
    ,[Source_Template_Name__c-tgt] = af.[Source_Template_Name__c]
    ,[Sub_Type__c-src] = a.[Sub_Type__c]
    ,[Sub_Type__c-tgt] = af.[Sub_Type__c]
    ,[Subject__c-src] = a.[Subject__c]
    ,[Subject__c-tgt] = af.[Subject__c]
    ,[SystemModstamp-src] = a.[SystemModstamp]
    ,[SystemModstamp-tgt] = af.[SystemModstamp]
    ,[Thread_Id__c-src] = a.[Thread_Id__c]
    ,[Thread_Id__c-tgt] = af.[Thread_Id__c]
    ,[Thread_Name__c-src] = a.[Thread_Name__c]
    ,[Thread_Name__c-tgt] = af.[Thread_Name__c]
    ,[Thread_Status__c-src] = a.[Thread_Status__c]
    ,[Thread_Status__c-tgt] = af.[Thread_Status__c]
    ,[Type__c-src] = a.[Type__c]
    ,[Type__c-tgt] = af.[Type__c]
    ,[User_Exclude_From_Back_Dating__c-src] = a.[User_Exclude_From_Back_Dating__c]
    ,[User_Exclude_From_Back_Dating__c-tgt] = af.[User_Exclude_From_Back_Dating__c]
    ,[User_Exclude_From_Duplicate_Case__c-src] = a.[User_Exclude_From_Duplicate_Case__c]
    ,[User_Exclude_From_Duplicate_Case__c-tgt] = af.[User_Exclude_From_Duplicate_Case__c]
    ,[User_Exclude_From_Forward_Dating__c-src] = a.[User_Exclude_From_Forward_Dating__c]
    ,[User_Exclude_From_Forward_Dating__c-tgt] = af.[User_Exclude_From_Forward_Dating__c]
    ,[UserExcludeFrom_Early_Service_Completion__c-src] = a.[UserExcludeFrom_Early_Service_Completion__c]
    ,[UserExcludeFrom_Early_Service_Completion__c-tgt] = af.[UserExcludeFrom_Early_Service_Completion__c]
from [cte_hist] h
join [cte_CSA] a
    on h.[CSA_Case_dv__c] = a.[Id]
left join [cte_CSA_sfg] af
    on af.[CSAKey] = a.[CSAKey]
)
,cte_anal_csa as (
select *
from [cte_recon_csa]
where 1=1
and [Adviser_Entity_Id__c-src] = '3716196'  --'342354'
and [Benchmark_Description__c-src] = 'Review Meeting Held'
and [Entity_Id__c-src] = '3755078'  --'690235'
and [Thread_Id__c-src] = '419422'   --'383596'
)
,cte_recon_asf as (
select
    [Id-hist] = h.[Id]
    ,h.[ASF_CSA_Case_dv__c]
    ,h.[CSA_Case_dv__c]
    ,[ASFKey-src] = a.[ASFKey]
    ,[ASFKey-tgt] = af.[ASFKey]
    ,[Account_Code__c-src] = a.[Account_Code__c]
    ,[Account_Code__c-tgt] = af.[Account_Code__c]
    ,[Account_Name__c-src] = a.[Account_Name__c]
    ,[Account_Name__c-tgt] = af.[Account_Name__c]
    ,[Adviser__c-src] = a.[Adviser__c]
    ,[Adviser__c-tgt] = af.[Adviser__c]
    ,[Adviser_Entity_Id__c-src] = a.[Adviser_Entity_Id__c]
    ,[Adviser_Entity_Id__c-tgt] = af.[Adviser_Entity_Id__c]
    ,[Adviser_Name__c-src] = a.[Adviser_Name__c]
    ,[Adviser_Name__c-tgt] = af.[Adviser_Name__c]
    ,[ASF_Prior_To_First_CSA__c-src] = a.[ASF_Prior_To_First_CSA__c]
    ,[ASF_Prior_To_First_CSA__c-tgt] = af.[ASF_Prior_To_First_CSA__c]
    ,[ASIC_No_Xplan__c-src] = a.[ASIC_No_Xplan__c]
    ,[ASIC_No_Xplan__c-tgt] = af.[ASIC_No_Xplan__c]
    ,[Client_Authorisation_Complete__c-src] = a.[Client_Authorisation_Complete__c]
    ,[Client_Authorisation_Complete__c-tgt] = af.[Client_Authorisation_Complete__c]
    ,[Commencement_Date__c-src] = a.[Commencement_Date__c]
    ,[Commencement_Date__c-tgt] = af.[Commencement_Date__c]
    ,[CommPay_Client_Category__c-src] = a.[CommPay_Client_Category__c]
    ,[CommPay_Client_Category__c-tgt] = af.[CommPay_Client_Category__c]
    ,[CommPay_Client_Id__c-src] = a.[CommPay_Client_Id__c]
    ,[CommPay_Client_Id__c-tgt] = af.[CommPay_Client_Id__c]
    ,[CommPay_Client_Name__c-src] = a.[CommPay_Client_Name__c]
    ,[CommPay_Client_Name__c-tgt] = af.[CommPay_Client_Name__c]
    ,[CommPay_Contact__c-src] = a.[CommPay_Contact__c]
    ,[CommPay_Contact__c-tgt] = af.[CommPay_Contact__c]
    ,[Complete_Date__c-src] = a.[Complete_Date__c]
    ,[Complete_Date__c-tgt] = af.[Complete_Date__c]
    ,[CreatedById-src] = a.[CreatedById]
    ,[CreatedById-tgt] = af.[CreatedById]
    ,[CreatedDate-src] = a.[CreatedDate]
    ,[CreatedDate-tgt] = af.[CreatedDate]
    ,[CSA_End_Date__c-src] = a.[CSA_End_Date__c]
    ,[CSA_End_Date__c-tgt] = af.[CSA_End_Date__c]
    ,[Date_Created__c-src] = a.[Date_Created__c]
    ,[Date_Created__c-tgt] = af.[Date_Created__c]
    ,[Entity_Category__c-src] = a.[Entity_Category__c]
    ,[Entity_Category__c-tgt] = af.[Entity_Category__c]
    ,[Entity_Groups__c-src] = a.[Entity_Groups__c]
    ,[Entity_Groups__c-tgt] = af.[Entity_Groups__c]
    ,[Entity_Id__c-src] = a.[Entity_Id__c]
    ,[Entity_Id__c-tgt] = af.[Entity_Id__c]
    ,[Entity_Name__c-src] = a.[Entity_Name__c]
    ,[Entity_Name__c-tgt] = af.[Entity_Name__c]
    ,[Extract_Date__c-src] = a.[Extract_Date__c]
    ,[Extract_Date__c-tgt] = af.[Extract_Date__c]
    ,[GST_Amount__c-src] = a.[GST_Amount__c]
    ,[GST_Amount__c-tgt] = af.[GST_Amount__c]
    ,[Has_Linked_ASF_Revenue__c-src] = a.[Has_Linked_ASF_Revenue__c]
    ,[Has_Linked_ASF_Revenue__c-tgt] = af.[Has_Linked_ASF_Revenue__c]
    ,[Has_Linked_CSA_Case__c-src] = a.[Has_Linked_CSA_Case__c]
    ,[Has_Linked_CSA_Case__c-tgt] = af.[Has_Linked_CSA_Case__c]
    ,[Id-src] = a.[Id]
    ,[Id-tgt] = af.[Id]
    ,[Integration_Id__c-src] = a.[Integration_Id__c]
    ,[Integration_Id__c-tgt] = af.[Integration_Id__c]
    ,[Is_Active__c-src] = a.[Is_Active__c]
    ,[Is_Active__c-tgt] = af.[Is_Active__c]
    ,[IsDeleted-src] = a.[IsDeleted]
    ,[IsDeleted-tgt] = af.[IsDeleted]
    ,[LastActivityDate-src] = a.[LastActivityDate]
    ,[LastActivityDate-tgt] = af.[LastActivityDate]
    ,[LastModifiedById-src] = a.[LastModifiedById]
    ,[LastModifiedById-tgt] = af.[LastModifiedById]
    ,[LastModifiedDate-src] = a.[LastModifiedDate]
    ,[LastModifiedDate-tgt] = af.[LastModifiedDate]
    ,[Licensee__c-src] = a.[Licensee__c]
    ,[Licensee__c-tgt] = af.[Licensee__c]
    ,[Main_Revenue_Type__c-src] = a.[Main_Revenue_Type__c]
    ,[Main_Revenue_Type__c-tgt] = af.[Main_Revenue_Type__c]
    ,[Name-src] = a.[Name]
    ,[Name-tgt] = af.[Name]
    ,[Net_Amount__c-src] = a.[Net_Amount__c]
    ,[Net_Amount__c-tgt] = af.[Net_Amount__c]
    ,[New_Client_ASF_Prior_To_First_CSA__c-src] = a.[New_Client_ASF_Prior_To_First_CSA__c]
    ,[New_Client_ASF_Prior_To_First_CSA__c-tgt] = af.[New_Client_ASF_Prior_To_First_CSA__c]
    ,[OwnerId-src] = a.[OwnerId]
    ,[OwnerId-tgt] = af.[OwnerId]
    ,[Payment_Period__c-src] = a.[Payment_Period__c]
    ,[Payment_Period__c-tgt] = af.[Payment_Period__c]
    ,[Payment_Period_End__c-src] = a.[Payment_Period_End__c]
    ,[Payment_Period_End__c-tgt] = af.[Payment_Period_End__c]
    ,[Payment_Period_Start__c-src] = a.[Payment_Period_Start__c]
    ,[Payment_Period_Start__c-tgt] = af.[Payment_Period_Start__c]
    ,[Policy_Number__c-src] = a.[Policy_Number__c]
    ,[Policy_Number__c-tgt] = af.[Policy_Number__c]
    ,[Product_Code__c-src] = a.[Product_Code__c]
    ,[Product_Code__c-tgt] = af.[Product_Code__c]
    ,[Product_Name__c-src] = a.[Product_Name__c]
    ,[Product_Name__c-tgt] = af.[Product_Name__c]
    ,[Revenue_Type__c-src] = a.[Revenue_Type__c]
    ,[Revenue_Type__c-tgt] = af.[Revenue_Type__c]
    ,[Scenario_Id__c-src] = a.[Scenario_Id__c]
    ,[Scenario_Id__c-tgt] = af.[Scenario_Id__c]
    ,[Statement_Number__c-src] = a.[Statement_Number__c]
    ,[Statement_Number__c-tgt] = af.[Statement_Number__c]
    ,[Statement_Record_Date__c-src] = a.[Statement_Record_Date__c]
    ,[Statement_Record_Date__c-tgt] = af.[Statement_Record_Date__c]
    ,[Supplier_Code__c-src] = a.[Supplier_Code__c]
    ,[Supplier_Code__c-tgt] = af.[Supplier_Code__c]
    ,[Supplier_Name__c-src] = a.[Supplier_Name__c]
    ,[Supplier_Name__c-tgt] = af.[Supplier_Name__c]
    ,[SystemModstamp-src] = a.[SystemModstamp]
    ,[SystemModstamp-tgt] = af.[SystemModstamp]
    ,[Thread_Id__c-src] = a.[Thread_Id__c]
    ,[Thread_Id__c-tgt] = af.[Thread_Id__c]
    ,[Thread_Name__c-src] = a.[Thread_Name__c]
    ,[Thread_Name__c-tgt] = af.[Thread_Name__c]
    ,[Thread_Status__c-src] = a.[Thread_Status__c]
    ,[Thread_Status__c-tgt] = af.[Thread_Status__c]
    ,[Unallocated_Revenue_Unknown_Adviser__c-src] = a.[Unallocated_Revenue_Unknown_Adviser__c]
    ,[Unallocated_Revenue_Unknown_Adviser__c-tgt] = af.[Unallocated_Revenue_Unknown_Adviser__c]
    ,[Unallocated_Revenue_Unknown_Client__c-src] = a.[Unallocated_Revenue_Unknown_Client__c]
    ,[Unallocated_Revenue_Unknown_Client__c-tgt] = af.[Unallocated_Revenue_Unknown_Client__c]
from [cte_hist] h
join [cte_ASF] a
    on h.[ASF_CSA_Case_dv__c] = a.[Id]
left join [cte_ASF_sfg] af
    on af.[ASFKey] = a.[ASFKey]
)
,cte_anal_asf as (
select *
from [cte_recon_asf]
where 1=1
--and [Adviser_Entity_Id__c-src] = '342228' -- '3716196'  --'342354'
--and [Entity_Id__c-src] = '3755078'  --'690235'
--and [Thread_Id__c-src] = '413411' -- '371610' -- '367178' --'419422'   --'383596'
)
select *
from [cte_recon_asf]
where 1=1
--and [ASFKey-tgt] is not null
--and [Supplier_Code__c-src] in ('Fee For Service')
and [ASF_CSA_Case_dv__c] = 'a26Mq000003n48PIAQ'
order by
    coalesce([ASFKey-src],[ASFKey-tgt])