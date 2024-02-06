-- Note: SSMS must be in SQLCMD mode in order to run this scritpt (Query >> SQLCMD Mode)
--:ON ERROR EXIT

:SETVAR TargetDb "EIDSS7_AJ_AVR"
:SETVAR Path "C:\Scripts\"

PRINT 'Successfully connected to the server.....'

SET NOCOUNT ON;
GO

USE $(TargetDb)

PRINT ''
PRINT '         TargetDb: $(TargetDb)'
PRINT '     Scripts Path: "$(Path)"'
PRINT ''
GO

GO
PRINT 'SCRIPT EXECUTION STARTED !!!!'
GO


PRINT 'Executing script 00_01_fnGetLastCharIndexOfSubstringInNonTrimString.....'
GO

:SETVAR ScriptToExecute "00_01_fnGetLastCharIndexOfSubstringInNonTrimString.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_01_fnGetLastCharIndexOfSubstringInNonTrimString.....'
GO

PRINT 'Executing script 00_02_spAsQuerySearchField_Post.....'
GO

:SETVAR ScriptToExecute "00_02_spAsQuerySearchField_Post.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_02_spAsQuerySearchField_Post.....'
GO


PRINT 'Executing script 00_03_fnGetAttributesFromFormattedString.....'
GO

:SETVAR ScriptToExecute "00_03_fnGetAttributesFromFormattedString.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_03_fnGetAttributesFromFormattedString.....'
GO


PRINT 'Executing script 00_04_spAsQueryFunction_Post.....'
GO

:SETVAR ScriptToExecute "00_04_spAsQueryFunction_Post.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_4_spAsQueryFunction_Post.....'
GO

/*
PRINT 'Executing script 00_05_USP_GBL_NEXTKEYID_PRE_GET.....'
GO

:SETVAR ScriptToExecute "00_05_USP_GBL_NEXTKEYID_PRE_GET.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_05_USP_GBL_NEXTKEYID_PRE_GET.....'
GO
*/


PRINT 'Executing script 00_06_fnEvaluatePermissions.....'
GO

:SETVAR ScriptToExecute "00_06_fnEvaluatePermissions.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_06_fnEvaluatePermissions..........'
GO

PRINT 'Executing script 00_07_spSecurityPolicy_List.sql.....'
GO

:SETVAR ScriptToExecute "00_07_spSecurityPolicy_List.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_07_spSecurityPolicy_List.sql..........'
GO

PRINT 'Executing script 00_08_tasQuery.sql.....'
GO

:SETVAR ScriptToExecute "00_08_tasQuery.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_08_tasQuery.sql..........'
GO

PRINT 'Executing script 00_09_spAsQuery_Post.sql.....'
GO

:SETVAR ScriptToExecute "00_09_spAsQuery_Post.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_09_spAsQuery_Post.sql..........'
GO

PRINT 'Executing script 00_10_spAsQuery_SelectDetail.sql.....'
GO

:SETVAR ScriptToExecute "00_10_spAsQuery_SelectDetail.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_10_spAsQuery_SelectDetail.sql..........'
GO

PRINT 'Executing script 00_11_spAsQuerySelectLookup.sql.....'
GO

:SETVAR ScriptToExecute "00_11_spAsQuerySelectLookup.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_11_spAsQuerySelectLookup.sql..........'
GO

PRINT 'Executing script 00_12_bugfixes.sql.....'
GO

:SETVAR ScriptToExecute "00_12_bugfixes.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_12_bugfixes.sql..........'
GO


PRINT 'Executing script 00_13_fnGetLanguageID_E7.sql.....'
GO

:SETVAR ScriptToExecute "00_13_fnGetLanguageID_E7.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_13_fnGetLanguageID_E7.sql..........'


PRINT 'Executing script 00_14_USP_HUM_DISEASE_REPORT_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_14_USP_HUM_DISEASE_REPORT_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_14_USP_HUM_DISEASE_REPORT_GETList_AVR.sql..........'


PRINT 'Executing script 00_15_USP_AGG_REPORT_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_15_USP_AGG_REPORT_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_15_USP_AGG_REPORT_GETList_AVR.sql..........'


PRINT 'Executing script 00_16_USP_AS_CAMPAIGN_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_16_USP_AS_CAMPAIGN_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_16_USP_AS_CAMPAIGN_GETList_AVR.sql..........'


PRINT 'Executing script 00_17_USP_HAS_MONITORING_SESSION_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_17_USP_HAS_MONITORING_SESSION_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_17_USP_HAS_MONITORING_SESSION_GETList_AVR.sql..........'


PRINT 'Executing script 00_18_USP_OMM_Session_GetList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_18_USP_OMM_Session_GetList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_18_USP_OMM_Session_GetList_AVR.sql..........'


PRINT 'Executing script 00_19_USP_VCTS_SURVEILLANCE_SESSION_GetList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_19_USP_VCTS_SURVEILLANCE_SESSION_GetList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_19_USP_VCTS_SURVEILLANCE_SESSION_GetList_AVR.sql..........'


PRINT 'Executing script 00_20_USP_VAS_MONITORING_SESSION_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_20_USP_VAS_MONITORING_SESSION_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_20_USP_VAS_MONITORING_SESSION_GETList_AVR.sql..........'


PRINT 'Executing script 00_21_USP_VET_DISEASE_REPORT_GETList_AVR.sql.....'
GO

:SETVAR ScriptToExecute "00_21_USP_VET_DISEASE_REPORT_GETList_AVR.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_21_USP_VET_DISEASE_REPORT_GETList_AVR.sql..........'


PRINT 'Executing script 00_22_spGetSiteInfo.sql.....'
GO

:SETVAR ScriptToExecute "00_22_spGetSiteInfo.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_22_spGetSiteInfo.sql..........'


PRINT 'Executing script 00_23_spGetNextNumberPrefixes.sql.....'
GO

:SETVAR ScriptToExecute "00_23_spGetNextNumberPrefixes.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_23_spGetNextNumberPrefixes.sql..........'


PRINT 'Executing script 00_24_AssignLegacyQueriesToAdmin.sql.....'
GO

:SETVAR ScriptToExecute "00_24_AssignLegacyQueriesToAdmin.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_24_AssignLegacyQueriesToAdmin.sql..........'


PRINT 'Executing script 00_25_fnAsGetSearchCondition.sql.....'
GO

:SETVAR ScriptToExecute "00_25_fnAsGetSearchCondition.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_25_fnAsGetSearchCondition.sql..........'


PRINT 'Executing script 00_26_fnGetLanguageCode.sql.....'
GO

:SETVAR ScriptToExecute "00_26_fnGetLanguageCode.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_26_fnGetLanguageCode.sql..........'


PRINT 'Executing script 00_27_fnGetLastCharIndexOfSubstringInNonTrimString.sql.....'
GO

:SETVAR ScriptToExecute "00_27_fnGetLastCharIndexOfSubstringInNonTrimString.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_27_fnGetLastCharIndexOfSubstringInNonTrimString.sql..........'


PRINT 'Executing script 00_28_AVR_VW_Location.sql.....'
GO

:SETVAR ScriptToExecute "00_28_AVR_VW_Location.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 00_28_AVR_VW_Location.sql..........'


PRINT 'Executing script 01_Rename of root objects.....'
GO

:SETVAR ScriptToExecute "01_Rename_of_root_objects.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 01_Rename of root objects.....'
GO

PRINT 'Executing script 02_Rename of fields.....'
GO

:SETVAR ScriptToExecute "02_Rename_of_fields.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 02_Rename of fields.....'
GO

PRINT 'Executing script 03_Sequential Steps for AVR Query - HAS Campaign....'
GO

:SETVAR ScriptToExecute "03_Sequential_Steps_for_AVR_Query_HAS_Campaign.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 03_Sequential Steps for AVR Query - HAS Campaign....'
GO

PRINT 'Executing script 04_Sequential_Steps_for_AVR Query_HAS_Session....'
GO

:SETVAR ScriptToExecute "04_Sequential_Steps_for_AVR_Query_HAS_Session.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 04_Sequential Steps for AVR Query - HAS Session....'
GO

PRINT 'Executing script 05_Sequential Steps for AVR Query - Outbreak Session....'
GO
:SETVAR ScriptToExecute "05_Sequential_Steps_for_AVR_Query_Outbreak_Session.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 05_Sequential Steps for AVR Query - Outbreak Session....'
GO

PRINT 'Executing script 06_Sequential Steps for AVR Query - Outbreak Human Case....'
GO

:SETVAR ScriptToExecute "06_Sequential_Steps_for_AVR_Query_Outbreak_Human_Case.sql"
:R $(Path)$(ScriptToExecute)
 
PRINT 'Executed script 06_Sequential Steps for AVR Query - Outbreak Human Case....'
GO

PRINT 'Executing script 07_sequential Steps for AVR Query - Outbreak Veterinary Case....'
GO

:SETVAR ScriptToExecute "07_sequential_Steps_for_AVR_Query_Outbreak_Veterinary_Case.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 07_sequential Steps for AVR Query - Outbreak Veterinary Case....'
GO


PRINT 'Executing script 08_sequential Steps for AVR Query - Veterinary Aggregate Disease....'
GO

:SETVAR ScriptToExecute "08_sequential_Steps_for_AVR_Query_Veterinary_Aggregate_Disease.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 08_sequential Steps for AVR Query - Veterinary Aggregate Disease....'
GO

PRINT 'Executing script 09_sequential Steps for AVR Query - Veterinary Aggregate Investigation Actions...'
GO

:SETVAR ScriptToExecute "09_sequential_Steps_for_AVR_Query_Veterinary_Aggregate_Investigation_Actions.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 09_sequential Steps for AVR Query - Veterinary Aggregate Investigation Actions...'
GO

PRINT 'Executing script 10_sequential Steps for AVR Query - Veterinary Aggregate Prophylactic Actions....'
GO

:SETVAR ScriptToExecute "10_sequential_Steps_for_AVR_Query_Veterinary_Aggregate_Prophylactic_Actions.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 10_sequential Steps for AVR Query - Veterinary Aggregate Prophylactic Actions....'
GO

PRINT 'Executing script 11_sequential Steps for AVR Query- Veterinary Aggregate Sanitary Actions....'
GO

:SETVAR ScriptToExecute "11_sequential_Steps_for_AVR_Query_Veterinary_Aggregate_Sanitary_Actions.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 11_sequential Steps for AVR Query- Veterinary Aggregate Sanitary Actions....'
GO

PRINT 'Executing script 12_sequential Steps for AVR Query- Human Disease Report....'
GO

:SETVAR ScriptToExecute "12_sequential_Steps_for_AVR_Query_Human_Disease_Report.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 12_sequential Steps for AVR Query- Human Disease Report....'
GO

PRINT 'Executing script 13_sequential Steps for AVR Query- Vet Active Surveillance Session....'
GO

:SETVAR ScriptToExecute "13_sequential_Steps_for_AVR_Query_Vet_Active_Surveillance_Session.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 13_sequential Steps for AVR Query- Vet Active Surveillance Session....'
GO

PRINT 'Executing script 14_2023_LM_AVR_SCRIPTS.sql....'
GO

:SETVAR ScriptToExecute "14_2023_LM_AVR_SCRIPTS.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 14_2023_LM_AVR_SCRIPTS.sql....'
GO

PRINT 'Executing script 16_Update_To_Geolocation.sql....'
GO

:SETVAR ScriptToExecute "16_Update_To_Geolocation.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 16_Update_To_Geolocation.sql....'
GO

PRINT 'Executing script 17_Update_To_Permissions.sql....'
GO

:SETVAR ScriptToExecute "17_Update_To_Permissions.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script 17_Update_To_Permissions.sql....'
GO


PRINT 'Executing script SetUP EIDSS DB with Demo User....'
GO

:SETVAR ScriptToExecute "SetUP_EIDSS_DB_with_Demo_user.sql"
:R $(Path)$(ScriptToExecute)

PRINT 'Executed script SetUP EIDSS DB with Demo User....'
GO

PRINT 'SCRIPT EXECUTION COMPLETED !!!!'
GO
:EXIT