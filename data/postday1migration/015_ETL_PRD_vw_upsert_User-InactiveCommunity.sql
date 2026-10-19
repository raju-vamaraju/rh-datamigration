USE [SalesforceMigration]
GO

/****** Object:  View [sfrhd].[vw_upsert_User-InactiveCommunity]    Script Date: 8/27/2026 3:49:01 PM ******/
DROP VIEW if exists [sfrhd].[vw_upsert_User-InactiveCommunity]
GO

/****** Object:  View [sfrhd].[vw_upsert_User-ALL]    Script Date: 8/27/2026 3:49:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [sfrhd].[vw_upsert_User-InactiveCommunity] as
with cte_Admin as (
    select top 1
        [Id]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Name] = 'Admin User'
    and [IsActive] = 1
)
,cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Profile as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Profile] i (nolock)
    join [SalesforceMigration].[sfrhd].[Profile] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and isnull(r.[Name],'') is not null
)
,cte_UserRole as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[UserRole] i (nolock)
    join [SalesforceMigration].[sfrhd].[UserRole] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
    where 1=1
    and isnull(r.[Name],'') is not null
)
/* Users 
    - NOT associated with Account and Contact 
    - [IsActive] = 0
    - UserLicense in ('Customer Community Plus','Customer Community Plus Login')
*/
,cte_portalUser as (
    select
        [User.Id-src] = c.[Portal_User_ID__c]
        ,[Contact.Id-src] = rc.[Metazoa_External_Id__c]
        ,[Contact.Id-tgt] = rc.[Id]
    from [sf].[Contact] c
    join [sf].[User] u
	    on u.[Id] = c.[Portal_User_ID__c]
	    and u.[IsActive] = 0
	    and u.[ContactId] is null
    join [sfrhd].[Contact] rc
	    on rc.[Metazoa_External_Id__c] = c.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
        ,[Profile-src] = p.[Name]
        ,[UserLicenseId-src] = p.[UserLicenseId]
        ,[UserLicense-src] = ul.[Name]
    from [SalesforceMigration].[sf].[User] s (nolock)
    join [SalesforceMigration].[sf].[Profile] p (nolock)
        on p.[Id] = s.[ProfileId]
    join [SalesforceMigration].[sf].[UserLicense] ul (nolock)
        on ul.[Id] = p.[UserLicenseId]
    left join [SalesforceMigration].[sfrhd].[User] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and (s.[Licensee__c] like '%Bridges%'
    or s.[Licensee__c] like '%Shadforth%'
    )
    and ul.[Name] in ('Customer Community Plus','Customer Community Plus Login')
    and s.[AccountId] is null
    and s.[ContactId] is null
    and s.[IsActive] = 0
and t.[Id] is null
)
select --top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[AboutMe]
    ,s.[Address]
    ,s.[Adviser_Name__c]
    ,s.[AdviserONE_Licensee__c]
    ,s.[Alias]
    ,s.[Allow_To_Updates_CyberSecurity__c]
    ,s.[BadgeText]
    ,s.[BannerPhotoUrl]
    ,s.[CallCenterId]
    ,s.[City]
    ,s.[CommunityNickname]
    ,s.[CompanyName]
    ,s.[Contact_Record_Type__c]
    -- reestablish special mapping of Portal User with Contact
    --,[ContactId] = coalesce(rc.[id-tgt],'')
    ,[ContactId] = coalesce(pu.[Contact.Id-tgt],'')
    ,[ContactID_18x__c] = coalesce(rc.[id-tgt],'')
    ,s.[Country]
    ,[AccountId] = coalesce(ram.[id-tgt],'')
    ,s.[DefaultGroupNotificationFrequency]
    ,s.[DelegatedApproverId]
    ,s.[Department]
    ,s.[DigestFrequency]
    ,s.[Division]
    ,s.[DNU_Referral_Partner_Visibility__c]
    ,s.[EDP_External_Id__c]
    ,[Email] = iif(s.[Email] like '%.invalid', s.[Email], concat(s.[Email],'.invalid'))
    ,s.[Email_Signature__c]
    ,s.[EmailEncodingKey]
    ,s.[EmailPreferencesAutoBcc]
    ,s.[EmailPreferencesAutoBccStayInTouch]
    ,s.[EmailPreferencesStayInTouchReminder]
    ,s.[EmployeeNumber]
    ,s.[EndDay]
    ,s.[Extension]
    ,s.[Fax]
    --,s.[FederationIdentifier]     -- for use of SSO; not enabled in Rhombus
    ,[FederationIdentifier] = ''    -- set to blank to avoid duplicate error when migrating from SF to RH
    ,s.[FirstName]
    ,s.[ForecastEnabled]
    ,s.[FullPhotoUrl]
    ,s.[GeocodeAccuracy]
    ,s.[Internal_ReferralPartner__c]
    ,[IsActive] = 0
    ,s.[IsExtIndicatorVisible]
    ,s.[IsPortalEnabled]
    ,s.[IsProfilePhotoActive]
    ,s.[LanguageLocaleKey]
    ,s.[LastLoginDate]
    ,s.[LastName]
    ,s.[LastReferencedDate]
    ,s.[LastViewedDate]
    ,s.[Latitude]
    ,[Licensee__c] = replace(replace(replace(replace(replace(replace(s.[Licensee__c],'Dealer Associates',''),'Alliances',''),'Actuate',''),'FSP',''),'Lonsdale',''),'IOOF Finance Choice','')
    ,[licenseesupervisor__c] = coalesce(rus.[id],'')
    ,s.[LocaleSidKey]
    ,s.[Location__c]
    ,s.[Longitude]
    ,s.[Manager__c]
    ,[ManagerId] = coalesce(rum.[id],'')
    ,s.[MediumBannerPhotoUrl]
    ,s.[MediumPhotoUrl]
    ,s.[MobilePhone]
    ,s.[Name]
    ,s.[OfflinePdaTrialExpirationDate]
    ,s.[OfflineTrialExpirationDate]
    ,s.[OutOfOfficeMessage]
    ,s.[PasswordExpirationDate]
    ,s.[Phone]
    ,s.[PortalRole]
    ,s.[Position__c]
    ,s.[PostalCode]
    ,s.[ReceivesAdminInfoEmails]
    ,s.[ReceivesInfoEmails]
    ,s.[Referral_Partner_Visibility__c]
    ,s.[Secondary_Email__c]
    ,s.[SenderEmail]
    ,s.[SenderName]
    ,s.[Signature]
    ,s.[Signature__c]
    ,s.[Signature_text__c]
    ,s.[SmallBannerPhotoUrl]
    ,s.[SmallPhotoUrl]
    ,s.[StartDay]
    ,s.[State]
    ,s.[StayInTouchNote]
    ,s.[StayInTouchSignature]
    ,s.[StayInTouchSubject]
    ,s.[Street]
    ,s.[SuAccessExpirationDate]
    ,s.[SystemModstamp]
    ,s.[Team__c]
    ,s.[TimeZoneSidKey]
    ,s.[Title]
    ,s.[User_Record_URL__c]
    ,s.[UserID_18x__c]
    ,[Username] = case
                    when s.[Username] = 'kirstkirsten.combe@insigniafinancial.com.auen.combe@insigniafinancial.com.au' then 'kirsten.combe@insigniafinancial.com.au.rhuat'
                    else s.[Username]+'.rhuat'
                end
    ,s.[UserPermissionsAvantgoUser]
    ,s.[UserPermissionsCallCenterAutoLogin]
    ,s.[UserPermissionsInteractionUser]
    ,s.[UserPermissionsKnowledgeUser]
    ,s.[UserPermissionsMarketingUser]
    ,s.[UserPermissionsOfflineUser]
    ,s.[UserPermissionsSFContentUser]
    ,s.[UserPermissionsSupportUser]
    ,s.[UserPreferencesActivityRemindersPopup]
    ,s.[UserPreferencesCacheDiagnostics]
    ,s.[UserPreferencesContentEmailAsAndWhen]
    ,s.[UserPreferencesContentNoEmail]
    ,s.[UserPreferencesCreateLEXAppsWTShown]
    ,s.[UserPreferencesDisableAllFeedsEmail]
    ,s.[UserPreferencesDisableBookmarkEmail]
    ,s.[UserPreferencesDisableChangeCommentEmail]
    ,s.[UserPreferencesDisableEndorsementEmail]
    ,s.[UserPreferencesDisableFileShareNotificationsForApi]
    ,s.[UserPreferencesDisableFollowersEmail]
    ,s.[UserPreferencesDisableLaterCommentEmail]
    ,s.[UserPreferencesDisableLikeEmail]
    ,s.[UserPreferencesDisableMentionsPostEmail]
    ,s.[UserPreferencesDisableMessageEmail]
    ,s.[UserPreferencesDisableProfilePostEmail]
    ,s.[UserPreferencesDisableSharePostEmail]
    ,s.[UserPreferencesDisCommentAfterLikeEmail]
    ,s.[UserPreferencesDisMentionsCommentEmail]
    ,s.[UserPreferencesDisProfPostCommentEmail]
    ,s.[UserPreferencesEnableAutoSubForFeeds]
    ,s.[UserPreferencesEventRemindersCheckboxDefault]
    ,s.[UserPreferencesExcludeMailAppAttachments]
    ,s.[UserPreferencesFavoritesShowTopFavorites]
    ,s.[UserPreferencesFavoritesWTShown]
    ,s.[UserPreferencesGlobalNavBarWTShown]
    ,s.[UserPreferencesGlobalNavGridMenuWTShown]
    ,s.[UserPreferencesHasCelebrationBadge]
    ,s.[UserPreferencesHasSentWarningEmail]
    ,s.[UserPreferencesHasSentWarningEmail238]
    ,s.[UserPreferencesHasSentWarningEmail240]
    ,s.[UserPreferencesHideBiggerPhotoCallout]
    ,s.[UserPreferencesHideBrowseProductRedirectConfirmation]
    ,s.[UserPreferencesHideChatterOnboardingSplash]
    ,s.[UserPreferencesHideCSNDesktopTask]
    ,s.[UserPreferencesHideCSNGetChatterMobileTask]
    ,s.[UserPreferencesHideEndUserOnboardingAssistantModal]
    ,s.[UserPreferencesHideLightningMigrationModal]
    ,s.[UserPreferencesHideOnlineSalesAppWelcomeMat]
    ,s.[UserPreferencesHideS1BrowserUI]
    ,s.[UserPreferencesHideSecondChatterOnboardingSplash]
    ,s.[UserPreferencesHideSfxWelcomeMat]
    ,s.[UserPreferencesLightningExperiencePreferred]
    ,s.[UserPreferencesLiveAgentMiawSetupDeflection]
    ,s.[UserPreferencesNewLightningReportRunPageEnabled]
    ,s.[UserPreferencesPathAssistantCollapsed]
    ,s.[UserPreferencesPreviewCustomTheme]
    ,s.[UserPreferencesRecordHomeReservedWTShown]
    ,s.[UserPreferencesRecordHomeSectionCollapseWTShown]
    ,s.[UserPreferencesReminderSoundOff]
    ,s.[UserPreferencesReverseOpenActivitiesView]
    ,s.[UserPreferencesShowCityToExternalUsers]
    ,s.[UserPreferencesShowCityToGuestUsers]
    ,s.[UserPreferencesShowCountryToExternalUsers]
    ,s.[UserPreferencesShowCountryToGuestUsers]
    ,s.[UserPreferencesShowEmailToExternalUsers]
    ,s.[UserPreferencesShowEmailToGuestUsers]
    ,s.[UserPreferencesShowFaxToExternalUsers]
    ,s.[UserPreferencesShowFaxToGuestUsers]
    ,s.[UserPreferencesShowForecastingChangeSignals]
    ,s.[UserPreferencesShowForecastingRoundedAmounts]
    ,s.[UserPreferencesShowManagerToExternalUsers]
    ,s.[UserPreferencesShowManagerToGuestUsers]
    ,s.[UserPreferencesShowMobilePhoneToExternalUsers]
    ,s.[UserPreferencesShowMobilePhoneToGuestUsers]
    ,s.[UserPreferencesShowPostalCodeToExternalUsers]
    ,s.[UserPreferencesShowPostalCodeToGuestUsers]
    ,s.[UserPreferencesShowProfilePicToGuestUsers]
    ,s.[UserPreferencesShowStateToExternalUsers]
    ,s.[UserPreferencesShowStateToGuestUsers]
    ,s.[UserPreferencesShowStreetAddressToExternalUsers]
    ,s.[UserPreferencesShowStreetAddressToGuestUsers]
    ,s.[UserPreferencesShowTitleToExternalUsers]
    ,s.[UserPreferencesShowTitleToGuestUsers]
    ,s.[UserPreferencesShowWorkPhoneToExternalUsers]
    ,s.[UserPreferencesShowWorkPhoneToGuestUsers]
    ,s.[UserPreferencesSortFeedByComment]
    ,s.[UserPreferencesSRHOverrideActivities]
    ,s.[UserPreferencesSuppressEventSFXReminders]
    ,s.[UserPreferencesSuppressTaskSFXReminders]
    ,s.[UserPreferencesTaskRemindersCheckboxDefault]
    ,s.[UserPreferencesUserDebugModePref]
    ,[UserRoleId] = coalesce(ur.[id-tgt],'')
    ,s.[UserType]
    ,s.[Wave_Internal__c]
    --,[ProfileId] = '00eBm000007xiFV'   -- coalesce(p.[id-tgt],'')
    ,[ProfileId] = coalesce(p.[id-tgt],'')
    ,[CreatedById] = coalesce(u1.[Id], ad.[Id])
    ,s.[CreatedDate]
    ,[LastModifiedById] = coalesce(u2.[Id], ad.[Id])
    ,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[AccountId]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[ContactId]
left join [cte_User] rus
    on rus.[Metazoa_External_ID__c] = s.[Licenseesupervisor__c]
left join [cte_User] rum
    on rum.[Metazoa_External_ID__c] = s.[ManagerId]
left join [cte_Profile] p
    on p.[Id-src] = s.[ProfileId]
left join [cte_UserRole] ur
    on ur.[Id-src] = s.[UserRoleId]
cross join [cte_Admin] ad
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[LastModifiedById]
left join [cte_portalUser] pu
    on pu.[User.Id-src] = s.[Id]
where 1=1
GO
