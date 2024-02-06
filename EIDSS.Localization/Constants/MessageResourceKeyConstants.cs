using EIDSS.Localization.Enumerations;
using Microsoft.Extensions.FileSystemGlobbing;

namespace EIDSS.Localization.Constants
{
    public class MessageResourceKeyConstants
    {
        #region Common Resources

        public static readonly string AccessoryCodeMandatoryMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "5" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AccessRuleCreatedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "552" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AccessRuleDeletedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "554" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AccessRuleUpdatedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "553" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ActivateEmployeeAccessForOrganizationConfirmationMessage = (int)InterfaceEditorResourceSetEnum.Employees + "576" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ActivateEmployeeRoleAndPermissionsConfirmationMessage = (int)InterfaceEditorResourceSetEnum.Employees + "581" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ChangeEmployeeCategoryConfirmationMessage = (int)InterfaceEditorResourceSetEnum.Employees + "580" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ChangesMadeToTheRecordWillBeLostIfYouLeaveThePageDoYouWantToContinueMessage = (int)InterfaceEditorResourceSetEnum.Messages + "945" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string Date1MustBeSameOrEarlierThanDate2Message = (int)InterfaceEditorResourceSetEnum.WarningMessages + "49" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string Date2MustBeSameOrLaterThanDate1Message = (int)InterfaceEditorResourceSetEnum.WarningMessages + "50" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FutureDatesAreNotAllowedMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "85" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DeactivateEmployeeAccessForOrganizationConfirmationMessage = (int)InterfaceEditorResourceSetEnum.Employees + "577" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DefaultValueMandatoryMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "59" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DoYouWantToCancelMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "34" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DoYouWantToSaveYourChangesMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "240" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DoYouWantToCancelChangesMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "33" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DoYouWantToDeleteThisRecordMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "61" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DoYouWantToPrintBarcodesMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "1011" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string UnableToDeleteBecauseOfChildRecordsMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "948" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateInvestigationTypeSpeciesDiseaseValueMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryDiagnosticInvestigation + "556" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateOrganizationAbbreviatedNameFullNameMessage = (int)InterfaceEditorResourceSetEnum.Organizations + "590" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateRecordsAreNotAllowedMessage = (int)InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "512" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateRecordsHaveBeenFoundMessage = (int)InterfaceEditorResourceSetEnum.Employees + "586" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ItIsNotPossibleToHaveTwoRecordsWithSameValueDoYouWantToCorrectValueMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "73" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateReferenceValueMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "74" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateUniqueOrganizationIDMessage = (int)InterfaceEditorResourceSetEnum.Organizations + "589" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DuplicateValueMessage = (int)InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "589" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ItIsNotPossibleToCreateTwoRecordsWithTheSameValueTheRecordWithAlreadyExistsDoYouWantToCorrectTheValueMessage = (int)InterfaceEditorResourceSetEnum.Messages + "966" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string NoRecordsFoundMessage = (int)InterfaceEditorResourceSetEnum.Messages + "144" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string EnterAtLeastOneParameterMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "77" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string EnterBetweenXandXCharactersMessage = (int)InterfaceEditorResourceSetEnum.Messages + "726" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FieldIsRequiredMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "231" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FieldIsInvalidValidRangeIsMessage = (int)InterfaceEditorResourceSetEnum.Messages + "555" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string InUseReferenceValueMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "99" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string InUseReferenceValueAreYouSureMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "596" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string InvalidFieldMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "100" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string IsRequiredMessage = (int)InterfaceEditorResourceSetEnum.Messages + "588" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LoginMustBeMessage = (int)InterfaceEditorResourceSetEnum.Employees + "583" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LowerBoundaryMustBeLessThanUpperBoundaryMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "551" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string NationalValueMandatoryMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "141" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string NumberIsOutOfRangeMessage = (int)InterfaceEditorResourceSetEnum.Messages + "958" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string PleaseWaitWhileWeProcessYourRequestMessage = (int)InterfaceEditorResourceSetEnum.Employees + "595" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ProblemHasOccurredMessage = (int)InterfaceEditorResourceSetEnum.ErrorMessages + "ProblemHasOccurred" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string RangeFromXandXCharactersMessage = (int)InterfaceEditorResourceSetEnum.Messages + "968" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string RecordDeletedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "219" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string RecordSavedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "591" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string RecordSubmittedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "223" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string RecordSubmittedSuccessfullyDoYouWantToAddAnotherRecordMessage = (int)InterfaceEditorResourceSetEnum.Messages + "29" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReferenceRecordCreatedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "218" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string SearchReturnedTooManyResultsMessage = (int)InterfaceEditorResourceSetEnum.Messages + "2801" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string UnableToDeleteContainsChildObjectsMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "270" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string YourChangesSavedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "703" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "2812" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string MessagesRecordIDisMessage = (int)InterfaceEditorResourceSetEnum.Messages + "2868" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string GlobalMustBeEqualToMessage = (int)InterfaceEditorResourceSetEnum.Global + "2793" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string GlobalMustBeGreaterThanMessage = (int)InterfaceEditorResourceSetEnum.Global + "2794" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string GlobalMustBeGreaterThanOrEqualToMessage = (int)InterfaceEditorResourceSetEnum.Global + "2795" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string GlobalMustBeLessThanMessage = (int)InterfaceEditorResourceSetEnum.Global + "2796" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string GlobalMustBeLessThanOrEqualToMessage = (int)InterfaceEditorResourceSetEnum.Global + "2797" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ErrorMessagesTheFieldIsInErrorYouMustCorrectDataInThisFieldBeforeSavingTheFormMessage = (int)InterfaceEditorResourceSetEnum.ErrorMessages + "3150" + (long)InterfaceEditorTypeEnum.Message;

        //SYSUC01 - Login
        public static readonly string LoginCombinationOfUserPasswordYouEnteredIsNotCorrectMessage = (int)InterfaceEditorResourceSetEnum.Login + "2756" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LoginTheUserIsLockedOutMessage = (int)InterfaceEditorResourceSetEnum.Login + "274" + (long)InterfaceEditorTypeEnum.Message;

        //SYSUC04 - Change Password
        public static readonly string PasswordMustBeMessage = (int)InterfaceEditorResourceSetEnum.Employees + "584" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string PasswordsDoNotMatchMessage = (int)InterfaceEditorResourceSetEnum.Employees + "585" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ChangePasswordPasswordIsSuccessfullySavedMessage = (int)InterfaceEditorResourceSetEnum.ChangePassword + "2556" + (long)InterfaceEditorTypeEnum.Message;

        //Human and Veterinary Active Surveillance Campaign Common
        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
        public static readonly string HumanActiveSurveillanceCampaignUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "271" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string HumanActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2520" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanActiveSurveillanceCampaignCampaignStartDateMustBeEarlierThanOrSameAsCampaignEndDateMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2521" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanActiveSurveillanceCampaignActiveSurveillanceCampaignStatusCanNotBeClosedOpenSessionsAssociatedMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2522" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanActiveSurveillanceCampaignActivesurveillanceCampaignStatusCanNotBeNewSessionsAssociatedMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2523" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanActiveSurveillanceCampaignDiseaseSampleRequiredMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "4233" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string VeterinaryActiveSurveillanceCampaignUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "271" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2520" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceCampaignCampaignStartDateMustBeEarlierThanOrSameAsCampaignEndDateMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2521" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceCampaignActiveSurveillanceCampaignStatusCanNotBeClosedOpenSessionsAssociatedMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2522" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceCampaignActivesurveillanceCampaignStatusCanNotBeNewSessionsAssociatedMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2523" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceCampaignDiseaseSpeciesSampleRequiredMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "4234" + (long)InterfaceEditorTypeEnum.Message;

        //VASUC09 - Deleting Active Surveillance Session
        public static readonly string VeterinaryActiveSurveillanceSessionUnabletodeletethisrecordasitisdependentonanotherobjectMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "3752" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string VeterinarySessionDiseaseSpeciesListMustBeTheSameAsCampaignMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "4136" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryActiveSurveillanceSessionUnabletodeletethisrecordasitcontainsdependentchildobjectsMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "948" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Common Resources

        #region Administration Module Resources

        //SAUC08 - Delete Organization
        public static readonly string CannotDeleteOrganizationConnectedToSiteMessage = (int)InterfaceEditorResourceSetEnum.Organizations + "593" + (long)InterfaceEditorTypeEnum.Message;

        //SAUC13 -1 - Load Statistical Data
        public static readonly string StatisticalDataInvalidnumberoffieldsinlineLinemustcontains8fieldsseparatedbycommaMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3449" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string StatisticalDataInvalidnumberoffieldsinlineLinemustcontains12fieldsseparatedbycommaMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3449" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3450" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidstatisticvalueStringXcantbeconvertedtointegerMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3451" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvaliddateformatStringXcantbeconvertedtodateAlldatesmustbepresentedinformat_ddmmyyyy_Message = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3452" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDateXisnotvalidstartmonthdateMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3453" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDateXisnotvalidstartquarterdateMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3454" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDateXisnotvalidstartweekdateMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3455" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDateXisnotvalidstartyeardateMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3456" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3457" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidregionnameValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3458" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidrayonnameValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3459" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidsettlementnameValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3460" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataInvalidparameternameValueXisemptyornotfoundinreferencestableMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3461" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataFieldismissedMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3462" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataThedataappearstobecorruptedatpositionXMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3463" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataLine0Column1Message = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3473" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDatawasnotimportedInputdatacontainstoomanyerrorsMaximumErrorNumberisexceededMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3528" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataDataimportwascompletedwithmistakesThefollowinglinescontainederrorsandwerenotimportedMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3529" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataThefollowinglinescontainerrorsandwillnotbeimportedImportdataMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3530" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataThefileformatisincorrectPleaseselectproperfileformatMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3531" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataImportdataMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3541" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string StatisticalDataThefollowinglinescontainerrorsandwillnotbeimportedMessage = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3542" + (long)InterfaceEditorTypeEnum.Message;

        //SAUC15 - Search Statistical Data Record
        public static readonly string SearchStatisticalDataRecordDateenteredmustbeearlierthanStatisticalDataforPeriodToMessage = (int)InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3393" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string SearchStatisticalDataRecordStartDateforPeriodTomustoccurafterStatisticalDataforPeriodFromMessage = (int)InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3394" + (long)InterfaceEditorTypeEnum.Message;

        //SAUC26 and 27 - Enter and Edit a User Group
        public static readonly string UserGroupDetailsYoucanselectuptosixiconsMessage = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "3921" + (long)InterfaceEditorTypeEnum.Message;

        //SAUC30 - Restore a Data Audit Log Transaction
        public static readonly string DataAuditLogDetailsObjectsAreSuccessfullyRestoredMessage = (int)InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3005" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string DataAuditLogDetailsThisObjectCantBeRestoredMessage = (int)InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3006" + (long)InterfaceEditorTypeEnum.Message;

        //SAUC53 - Edit EIDSS Sites
        public static readonly string AttentionModifyingTheseSettingsMayDamageIntegrityOfDataMessage = (int)InterfaceEditorResourceSetEnum.WarningMessages + "1000" + (long)InterfaceEditorTypeEnum.Message;

        #region Deduplication Sub-Module

        public static readonly string AvianDiseaseReportDeduplicationFieldValuePairsFoundWithNoSelectionAllFieldValuePairsMustContainASelectedValueToSurviveMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "899" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportDeduplicationDoYouWantToDeduplicateRecordMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "941" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportDeduplicationMergeCompleteSavedSuccessfullyToTheDatabaseMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "1074" + (long)InterfaceEditorTypeEnum.Message;

        //DDUC03
        public static readonly string DeduplicationPersonDoyouwanttodeduplicaterecordMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3196" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string DeduplicationPersonFieldvaluepairsfoundwithnoselectionAllfieldvaluepairsmustcontainaselectedvaluetosurviveMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3197" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3198" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3199" + (long)InterfaceEditorTypeEnum.Message;

        //DDUC05
        public static readonly string DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanoneherdMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3591" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanonespeciesMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3592" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithdifferentspeciesMessage = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3593" + (long)InterfaceEditorTypeEnum.Message;

        //DDUC06
        public static readonly string AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordswithmorethanoneflockMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3584" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordsfromdifferentfarmsMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3922" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Deduplication Sub-Module

        #endregion Administration Module Resources

        #region Configuration Module Resources

        //SCUC11 - Configure Test – Test Results Matrix
        public static readonly string TestTestResultMatrixTestResultsIsMandatoryMessage = (int)InterfaceEditorResourceSetEnum.TestTestResultMatrix + "960" + (long)InterfaceEditorTypeEnum.Message;

        //SCUC14 - Configure Vector Type - Field Test Matrix
        public static readonly string VectorTypeFieldTestMatrixFieldTestIsMandatoryMessage = (int)InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "959" + (long)InterfaceEditorTypeEnum.Message;

        #region Flexible Form Designer

        public static readonly string FlexibleFormDesignerFlexFormAssignedToOutbreakSessionMessage = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "2726" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FlexibleFormDesignerTherecordissavedsuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "591" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FlexibleFormDesignerDoyouwanttodeletethisparameterMessage = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "3915" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FlexibleFormDesignerProblemWithDesignMessage = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "4490" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Flexible Form Designer

        #endregion Configuration Module Resources

        #region Reports Module Resources

        public static readonly string FirstAndSecondYearsMessage = (int)InterfaceEditorResourceSetEnum.Reports + "401" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsSecondAndFirstYearsMessage = (int)InterfaceEditorResourceSetEnum.Reports + "SecondAndFirstYears" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string DatesCompareMessage = (int)InterfaceEditorResourceSetEnum.Reports + "394" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FromToDatesCompareMessage = (int)InterfaceEditorResourceSetEnum.Reports + "406" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsOnlyFiveSelectedYearsWillBeRepresentedInTheReportMessage = (int)InterfaceEditorResourceSetEnum.Reports + "2805" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsTooManyDiseasesMessage = (int)InterfaceEditorResourceSetEnum.Reports + "448" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsTooManyDiseasesAllow12Message = (int)InterfaceEditorResourceSetEnum.Reports + "449" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsTooManyItemsMessage = (int)InterfaceEditorResourceSetEnum.Reports + "450" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsTooManySpeciesTypesMessage = (int)InterfaceEditorResourceSetEnum.Reports + "451" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsYearSelectedInToFilterShallBeGreaterThanYearSelectedInFromFilterYearsMessage = (int)InterfaceEditorResourceSetEnum.Reports + "458" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsYear1ShallBeGreaterThanYear2Message = (int)InterfaceEditorResourceSetEnum.Reports + "2799" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ReportsYouCanSpecifyNotMoreThanThreeSpeciesInSpeciesTypeFilterMessage = (int)InterfaceEditorResourceSetEnum.Reports + "2806" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Reports Module Resources

        #region Human Module Resources

        //Common
        public static readonly string MessagesTherecordissavedsuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.Messages + "2771" + (long)InterfaceEditorTypeEnum.Message;

        //HASUC01
        public static readonly string HumanActiveSurveillanceCampaignReturntoActiveSurveillanceCampaignMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "833" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string HumanActiveSurveillanceCampaignReturntoDashboardMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "232" + (long)InterfaceEditorTypeEnum.Message;

        //HASUC03
        public static readonly string HumanActiveSurveillanceCampaignReturntoActiveSurveillanceSessionMessage = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "865" + (long)InterfaceEditorTypeEnum.Message;

        //HAUC05 - Enter Human Aggregate Disease Reports Summary
        public static readonly string HumanAggregateDiseaseReportSummaryAdministrativeLevelMismatchMessage = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "2552" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string HumanAggregateDiseaseReportSummaryTimeIntervalUnitMismatchMessage = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "2553" + (long)InterfaceEditorTypeEnum.Message;

        //HAUC06 - Enter ILI Aggregate Form and HAUC07 - Edit ILI Aggregate Form
        public static readonly string ILIAggregateDetailsRecordWithThisHospitalSentinelStationAlreadyExistsMessage = (int)InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2714" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string ILIAggregateDetailsOnlyOneFormCanBeCreatedForTheSameTimeIntervalAndSiteMessage = (int)InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2715" + (long)InterfaceEditorTypeEnum.Message;

        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form
        public static readonly string WeeklyReportingFormDetailsDuplicateRecordMessage = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "785" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string WeeklyReportingFormDetailsRecordSavedSuccessfullyTheRecordIDIsMessage = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "3407" + (long)InterfaceEditorTypeEnum.Message;

        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report
        public static readonly string HumanDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3116" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string HumanDiseaseReportSymptomsDateShallBeOnOrEarlierThanDateOfSymptomOnsetNoFutureDatesAreAllowedMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "2783" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportCaseInvestigationDateShallBeOnOrAfterDateOfNotificationNoFutureDatesAreAllowedMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "2784" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportSamplesSampleIsAccessionedDoYouWantToDeleteTheSampleRecordMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2811" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportFinalOutcomeFinalCaseClassificationDoesNotMatchTheBasisOfDiagnosisMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "3174" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportTheSelectedDiseaseValueDoesNotMatchToPersonGenderMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3404" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportTheSelectedDiseaseValueDoesNotMatchToPersonAgeMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3405" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportSoughtCareDateShallBeOnOrAfterDateOfSymptomOnsetAndNoLaterThanDateOfDiagnosisMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "4369" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string HumanDiseaseReportDateshallbeonorearlierthanDateofDiagnosisMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "4748" + (long)InterfaceEditorTypeEnum.Message;

        //HUC11 - Create a Connected Human Disease Report
        public static readonly string HumanDiseaseReportDoYouWantToCreateANewNotifiableDiseaseReportWithAChangedDiseaseValueForThisPersonMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3375" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string HumanDiseaseReportDiseasevalueinoriginalandconnectedDiseaseReportscannotbesameMessage = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3408" + (long)InterfaceEditorTypeEnum.Message;

        //PIN Messages
        public static readonly string PersonInformationAccordingToTheSearchCriteriaNoRecordsFoundPleaseUpdateSearchCriteriaAndTryToFindPersonAgainMessage = (int)InterfaceEditorResourceSetEnum.PersonInformation + "4754" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string PersonInformationCivilRegistryServiceIsNotRespondingPleaseTryToFindThePersonLaterInCurrentLanguageMessage = (int)InterfaceEditorResourceSetEnum.PersonInformation + "4755" + (long)InterfaceEditorTypeEnum.Message;

        //HUC02 
        public static readonly string PersonInformationDOBErrorMessage = (int) InterfaceEditorResourceSetEnum.PersonInformation + "4808" + (long) InterfaceEditorTypeEnum.Message;
        public static readonly string PersonInformationDOBWarningMessage100Years = (int) InterfaceEditorResourceSetEnum.PersonInformation + "4809" + (long) InterfaceEditorTypeEnum.Message;

        public static readonly string WeeklyReportingFormTotalMustBeGreaterThanAmongThemNotifiedMessage = (int)InterfaceEditorResourceSetEnum.WeeklyReportingForm + "4811" + (long)InterfaceEditorTypeEnum.Message;		

        #endregion Human Module Resources

        #region Laboratory Module Resources

        //LUC01 - Accession a Sample
        public static readonly string LaboratorySamplesCommentMustBeAtLeastSixCharactersInLengthMessage = (int)InterfaceEditorResourceSetEnum.Samples + "2779" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LaboratorySamplesCommentIsRequiredWhenSampleStatusIsAcceptedInPoorConditionOrRejectedMessage = (int)InterfaceEditorResourceSetEnum.Samples + "2780" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string GroupAccessionInModalLocalOrFieldSampleIDDoesNotExistMessage = (int)InterfaceEditorResourceSetEnum.GroupAccessionInModal + "2765" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string GroupAccessionInModalLocalOrFieldSampleIDIsAlreadyAccessionedMessage = (int)InterfaceEditorResourceSetEnum.GroupAccessionInModal + "2766" + (long)InterfaceEditorTypeEnum.Message;

        //LUC03 - Transfer a Sample
        public static readonly string LaboratoryTransferredAreYouSureYouWantToCancelThisTransferMessage = (int)InterfaceEditorResourceSetEnum.Transferred + "2789" + (long)InterfaceEditorTypeEnum.Message;

        //LUC09 - Edit a Test
        public static readonly string LaboratorySampleTestDetailsModalTestStartedDateMustBeOnOrAfterSampleAccessionDateMessage = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "4466" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LaboratorySampleTestDetailsModalResultDateMustBeOnOrAfterTestStartedDateMessage = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "4413" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string TestingTestResultIsRequiredMessage = (int)InterfaceEditorResourceSetEnum.Testing + "4496" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string TestingResultDateIsRequiredMessage = (int)InterfaceEditorResourceSetEnum.Testing + "4497" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string TestingResultDateMustBeEarlierOrEqualToTheCurrentDateMessage = (int)InterfaceEditorResourceSetEnum.Testing + "4498" + (long)InterfaceEditorTypeEnum.Message;

        //LUC15 - Lab Record Deletion
        public static readonly string LaboratorySamplesFollowingSampleWillBeDeletedPleaseEnterReasonForDeletingSampleMessage = (int)InterfaceEditorResourceSetEnum.Samples + "995" + (long)InterfaceEditorTypeEnum.Message;

        //LUC09 - Edit a Batch
        public static readonly string BatchesAllTestResultsMustBeEnteredToCloseABatchMessage = (int)InterfaceEditorResourceSetEnum.Batches + "4389" + (long)InterfaceEditorTypeEnum.Message;

        //LUC16 - Approvals Workflow
        public static readonly string ApprovalsTestResultNotValidatedNotificationMessage = (int)InterfaceEditorResourceSetEnum.Approvals + "2915" + (long)InterfaceEditorTypeEnum.Message;

        //LUC20 - Configure Sample Storage and LUC23 - Edit Sample Storage Schema
        public static readonly string FreezerDetailsOnceAFreezerIsDeletedNeitherTheFreezerNorItsSubdivisionsCanBeFurtherUsedOrAutomaticallRestoredDoYouWantToDeleteThisFreezerMessage = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "2499" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string FreezerDetailsADuplicateRecordIsFoundTheBarCodeValueEnteredAlreadyExistsMessage = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "2718" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FreezerDetailsUnableToDeleteThisFreezerAsItContainsSamplesMessage = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "2719" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Laboratory Module Resources

        #region Outbreak Module Resources

        //OMUC01
        public static readonly string CreateOutbreakThisrecordIDisMessage = (int)InterfaceEditorResourceSetEnum.CreateOutbreak + "2790" + (long)InterfaceEditorTypeEnum.Message;

        //OMUC02
        public static readonly string CreateOutbreakTheFrequencycannotbelargerthanthedurationMessage = (int)InterfaceEditorResourceSetEnum.CreateOutbreak + "2774" + (long)InterfaceEditorTypeEnum.Message;

        //OMUC03 - Import Disease Report
        public static readonly string ImportHumanCaseSelectedDiseaseReportIsAlreadyAssociatedWithAnOutbreakSessionMessage = (int)InterfaceEditorResourceSetEnum.ImportHumanCase + "3020" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string ImportVeterinaryCaseSelectedDiseaseReportIsAlreadyAssociatedWithAnOutbreakSessionMessage = (int)InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3020" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ImportHumanCaseDateOfSymptomsOnsetStartOfSignsCannotBePriorToTheOutbreakStartDateMessage = (int)InterfaceEditorResourceSetEnum.ImportHumanCase + "3021" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ImportVeterinaryCaseDateOfSymptomsOnsetStartOfSignsCannotBePriorToTheOutbreakStartDateMessage = (int)InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3021" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ImportHumanCaseSelectedDiseaseReportsDiseaseDoesNotMatchTheOutbreakDiseaseMessage = (int)InterfaceEditorResourceSetEnum.ImportHumanCase + "3022" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string ImportVeterinaryCaseSelectedDiseaseReportsDiseaseDoesNotMatchTheOutbreakDiseaseMessage = (int)InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3022" + (long)InterfaceEditorTypeEnum.Message;

        //OMUC04
        public static readonly string CreateHumanCaseHumanCasehasbeensavedsuccessfullyNewCaseIDMessage = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3656" + (long)InterfaceEditorTypeEnum.Message;

        //OMUC06
        public static readonly string CreateVeterinaryCaseVeterinaryCaseHasBeenSavedSuccessfullyNewCaseIDMessage = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3407" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string CreateVeterinaryCaseTheFarmAddressDoesNotMatchTheSessionLocationDoYouWantToContinueMessage = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3604" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Outbreak Module Resources

        #region Vector Module Resources

        public static readonly string VectorCollectionDateShallBeOnOrAfterSessionStartDateMessage = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "3120" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorSurveillanceSessionUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "271" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorCollectionDateShallBeOnOrBeforeIdentifyingDateMessage = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4500" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorSurveillanceSessionNewSessionSavedSuccessfullyMessage = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "3407" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorIdentifyingDateShallBeOnOrAfterSessionStartDateMessage = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4501" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorIdentifyingDateShallBeOnOrAfterCollectionDateMessage = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4502" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VectorIdentifyingDateShallBeOnOrBeforeSessionCloseDateMessage = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4592" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Vector Module Resources

        #region Veterinary Module Resources

        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
        public static readonly string VeterinaryAggregateActionReportSummaryAdministrativeLevelMismatchMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2552" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string VeterinaryAggregateDiseaseReportDuplicateReportExistsMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "4465" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryAggregateDiseaseReportSummaryAdministrativeLevelMismatchMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2552" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryAggregateActionReportSummaryTimeIntervalUnitMismatchMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2553" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryAggregateDiseaseReportSummaryTimeIntervalUnitMismatchMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2553" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryAggregateActionsReportInformationNotificationReceivedByDateMustBeOnOrAfterNotificationSentByDateMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportNotificationReceivedBy + "4499" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string VeterinaryAggregateDiseaseReportInformationNotificationReceivedByDateMustBeOnOrAfterNotificationSentByDateMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportNotificationReceivedBy + "4499" + (long)InterfaceEditorTypeEnum.Message;

        //VAUC02 and VAUC03 - Enter and Edit Veterinary Surveillance Session
        public static readonly string VeterinarySessionAggregatePositiveSampleQtyMoreThanAnimalsSampledMessage = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "3374" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string VeterinarySessionYouSuccessfullyCreatedANewVeterinarySurveillancSessionInTheEIDSSSystemTheEIDSSIDIsMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "3407" + (long)InterfaceEditorTypeEnum.Message;

        //VAUC05 and VAUC07 - Enter and Edit Avian Disease Report
        public static readonly string AvianDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReport + "271" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string AvianDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReport + "3407" + (long)InterfaceEditorTypeEnum.Message;

        //VAUC09/10/11/12 - Enter, Edit, Delete Veterinary Aggregate Actions Report
        public static readonly string VeterinaryAggregateActionsReportSuccessfullySavedTheEIDSSIDIsMessage = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "3407" + (long)InterfaceEditorTypeEnum.Message;

        //Farm/Flock/Species Section
        public static readonly string AvianDiseaseReportFarmFlockSpeciesSpeciesIsRequiredMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2974" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2975" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2976" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2977" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesTheFieldSpeciesIsRequiredYouMustEnterDataForEachFlockBeforeSavingTheRecordMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2978" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2979" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2980" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedFlockMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2981" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2982" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesTheSumOfDeadMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2983" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesAndSickMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2984" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesCantBeMoreThanTotalMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2985" + (long)InterfaceEditorTypeEnum.Message;

        //Notification Section
        public static readonly string AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2988" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string AvianDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2989" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2990" + (long)InterfaceEditorTypeEnum.Message;

        //Samples Section
        public static readonly string AvianDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2991" + (long)InterfaceEditorTypeEnum.Message;

        //VAUC04 and VAUC06 - Enter and Edit Livestock Disease Report
        public static readonly string LivestockDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "271" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LivestockDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "3407" + (long)InterfaceEditorTypeEnum.Message;

        //Farm/Herd/Species Section
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesSpeciesIsRequiredMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2974" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2975" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2976" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2977" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesTheFieldSpeciesIsRequiredYouMustEnterDataForEachFlockBeforeSavingTheRecordMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2978" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2979" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2980" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2982" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesTheSumOfDeadMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2983" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesAndSickMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2984" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesCantBeMoreThanTotalMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2985" + (long)InterfaceEditorTypeEnum.Message;

        //Notification Section
        public static readonly string LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2988" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string LivestockDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2989" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2990" + (long)InterfaceEditorTypeEnum.Message;

        //Samples Section
        public static readonly string LivestockDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2991" + (long)InterfaceEditorTypeEnum.Message;

        //VUC17 - Enter New Farm Record
        public static readonly string FarmTheRecordWithTheSameFarmAddressAndSameFarmOwnerIsFoundInTheDatabaseDoYouWantToCreateThisFarmRecordMessage = (int)InterfaceEditorResourceSetEnum.Farm + "3739" + (long)InterfaceEditorTypeEnum.Message;

        public static readonly string FarmStreetRequiredWhenFarmOwnerAndFarmNameLeftBlank = (int)InterfaceEditorResourceSetEnum.Farm + "4800" + (long)InterfaceEditorTypeEnum.Message;
        public static readonly string FarmRegionRayonAndSettlementRequiredWhenFarmOwnerLeftBlank = (int)InterfaceEditorResourceSetEnum.Farm + "4799" + (long)InterfaceEditorTypeEnum.Message;

        //VUC 19 - Delete Farm
        public static readonly string FarmUnableToDeleteDependentOnAnotherObjectMessage = (int)InterfaceEditorResourceSetEnum.Farm + "271" + (long)InterfaceEditorTypeEnum.Message;

        #endregion Veterinary Module Resources
    }
}