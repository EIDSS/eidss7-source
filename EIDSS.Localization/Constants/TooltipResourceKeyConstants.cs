using EIDSS.Localization.Enumerations;
using Microsoft.Extensions.FileSystemGlobbing;

namespace EIDSS.Localization.Constants
{
    public class TooltipResourceKeyConstants
    {
        public static readonly string GridAdd = (int)InterfaceEditorResourceSetEnum.CommonButtons + "543" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridCancel = (int)InterfaceEditorResourceSetEnum.CommonButtons + "540" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridDelete = (int)InterfaceEditorResourceSetEnum.CommonButtons + "538" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridDetails = (int)InterfaceEditorResourceSetEnum.CommonButtons + "541" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridEdit = (int)InterfaceEditorResourceSetEnum.CommonButtons + "539" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridSave = (int)InterfaceEditorResourceSetEnum.CommonButtons + "542" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string GridPermissions = (int)InterfaceEditorResourceSetEnum.CommonButtons + "544" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string Close = (int)InterfaceEditorResourceSetEnum.CommonButtons + "548" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string SavegridconfigurationTooltip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "3669" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string CommonButtonsClickToAddARecordToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "36" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToCancelToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "474" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToDeleteToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "37" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToEditTheRecordToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4758" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToUpdateToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4757" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToSearchToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "42" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToSubmitToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "43" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToClearToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "475" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToSelectToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4766" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToSelectAllRecordsToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4767" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToUnselectAllToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4768" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToAcceptToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4769" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToClearTheFormToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4770" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToConfirmNoToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4771" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToConfirmYesToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4772" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToCopyToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4773" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string CommonButtonsClickToPasteToolTip = (int)InterfaceEditorResourceSetEnum.CommonButtons + "4774" + (long)InterfaceEditorTypeEnum.ToolTip;		

        public static readonly string SiteAlertMessengerModalClickToMarkTheAlertAsReadToolTip = (int)InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "4787" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string SiteAlertMessengerModalClickToDeleteAllAlertsToolTip = (int)InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "4788" + (long)InterfaceEditorTypeEnum.ToolTip;		

        //SYSUC04 - Change Password
        public static readonly string ChangePasswordButtonToolTip = (int)InterfaceEditorResourceSetEnum.ChangePassword + "462" + (long)InterfaceEditorTypeEnum.ToolTip;

        //Flex Form Designer
        public static readonly string FlexibleFormDesigner_AddSection_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "727" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_DeleteSection_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "728" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_AddParameter_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "729" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_DeleteParameter_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "730" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_CopyTreeviewNode_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "731" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_PasteTreeviewNode_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "732" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_ShowTemplates_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "733" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_ShowTemplateParameters_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "734" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_ShowTemplateRules_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "735" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_AddTemplate_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "736" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_DeleteTemplate_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "737" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_AddTemplateParameter_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "738" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_CopyTemplate_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "739" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string FlexibleFormDesigner_AddaDeterminant_Tooltip = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "740" + (long)InterfaceEditorTypeEnum.ToolTip;

        //Laboratory Module
        public static readonly string SamplesAccessionToolTip = (int) InterfaceEditorResourceSetEnum.Samples + "823" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string SamplesAssignTestToolTip = (int) InterfaceEditorResourceSetEnum.Samples + "824" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string SamplesCreateAliquotDerivativeToolTip = (int) InterfaceEditorResourceSetEnum.Samples + "825" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string TestingBatchToolTip = (int) InterfaceEditorResourceSetEnum.Testing + "826" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string AssignTestModalClickToAssignTheListedTestsToTheCorrespondingSamplesToolTip = (int)InterfaceEditorResourceSetEnum.AssignTestModal + "824" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string LaboratoryClickToDisplayTheAliquotPopupToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4759" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string LaboratoryClickToDisplayTheTransferPopupToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4760" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string LaboratoryClickToDisplayTheAccessionInPopupToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4761" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string LaboratoryClickToDisplayTheAssignTestPopupToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4762" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string LaboratoryClickToDisplayTheBatchPopupToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4763" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string BatchesClickToCloseTheBatchToolTip = (int)InterfaceEditorResourceSetEnum.Batches + "4764" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string LaboratoryClickToShowRecordInMyFavoritesTabToolTip = (int)InterfaceEditorResourceSetEnum.Laboratory + "4765" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string ApprovalsClickToApproveTheSelectedRecordsToolTip = (int)InterfaceEditorResourceSetEnum.Approvals + "4756" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string ApprovalsClickToRejectTheSelectedRecordsToolTip = (int)InterfaceEditorResourceSetEnum.Approvals + "4775" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string BatchesClickToRemoveTheSelectedSamplesFromTheBatchToolTip = (int)InterfaceEditorResourceSetEnum.Batches + "4776" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string BatchesClickToAddATestResultToTheSelectedRecordsToolTip = (int)InterfaceEditorResourceSetEnum.Batches + "4777" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string TransferredClickToCancelTheSelectedTransfersToolTip = (int)InterfaceEditorResourceSetEnum.Transferred + "4778" + (long)InterfaceEditorTypeEnum.ToolTip;		
        public static readonly string TransferredClickToDisplayTheSelectedTransfersReportForPrintingToolTip = (int)InterfaceEditorResourceSetEnum.Transferred + "4779" + (long)InterfaceEditorTypeEnum.ToolTip;		

        //LUC03 - Transfer a Sample
        public static readonly string TransferOutModalClickToSaveTransferRecordsToTheDatabaseToolTip = (int) InterfaceEditorResourceSetEnum.TransferOutModal + "849" + (long) InterfaceEditorTypeEnum.ToolTip;

        //LUC07 - Amend Test Result
        public static readonly string AmendTestResultModalAmendToolTip = (int) InterfaceEditorResourceSetEnum.AmendTestResultModal + "867" + (long) InterfaceEditorTypeEnum.ToolTip;

        //LUC08 - Create a Batch
        public static readonly string BatchModalBatchToolTip = (int) InterfaceEditorResourceSetEnum.BatchModal + "899" + (long) InterfaceEditorTypeEnum.ToolTip;

        //OMUC11
        public static readonly string OutbreakContactsContactMonitoringQuestionsTooltip = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "2688" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string OutbreakContactsAddContactMonitoringFollowupTooltip = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "2689" + (long)InterfaceEditorTypeEnum.ToolTip;


        //Veterinary Module

        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
        public static readonly string VeterinarySessionDetailedInformationAddHerdToolTip = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2484" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string VeterinarySessionDetailedInformationAddFlockToolTip = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2482" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string VeterinarySessionAggregateInformationAddHerdToolTip = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2484" + (long)InterfaceEditorTypeEnum.ToolTip;
        public static readonly string VeterinarySessionAggregateInformationAddFlockToolTip = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2482" + (long)InterfaceEditorTypeEnum.ToolTip;

        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesAddHerdToolTip = (int) InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2484" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string LivestockDiseaseReportSamplesImportToolTip = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2499" + (long)InterfaceEditorTypeEnum.ToolTip;

        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
        public static readonly string AvianDiseaseReportFarmFlockSpeciesAddFlockToolTip = (int) InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2482" + (long) InterfaceEditorTypeEnum.ToolTip;
        public static readonly string AvianDiseaseReportSamplesImportToolTip = (int) InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2499" + (long) InterfaceEditorTypeEnum.ToolTip;
    }
}