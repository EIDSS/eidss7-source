using System.ComponentModel;

namespace EIDSS.CodeGenerator
{
    /// <summary>
    /// System Event Enumerations
    /// </summary>
    public enum SystemEventEnum
    {
        /// <summary>
        /// Indicates that this action doesn't fire a system event
        /// </summary>
        [Description("Specifies that this action does not fire a system event")] DoesNotParticipate = 0,

        /// <summary>
        /// Event fired when Aggregate settings were changed
        /// </summary>
        [Description("Aggregate settings were changed")] Aggregate_Settings_Changed = 10025118,

        /// <summary>
        /// Event fired when the Client UI Language Changes
        /// </summary>
        [Description("Client UI Language Changed")] Client_UI_Language_Changed = 10025001,

        /// <summary>
        /// Event fired when a Closed human active surveillance session was reopened at a neighboring site
        /// </summary>
        [Description("Closed human active surveillance session was reopened at a neighboring site")] Closed_HumanActiveSurveillanceSession_Reopened_OtherSite = 10025508,

        /// <summary>
        /// Event fired when a Closed human active surveillance session was reopened at your site
        /// </summary>
        [Description("Closed human active surveillance session was reopened at your site")] Closed_HumanActiveSurveillanceSession_Reopened = 10025507,

        /// <summary>
        /// Event fired when a Closed human disease report was re-opened at another site
        /// </summary>
        [Description("Closed human disease report was re-opened at another site")] Closed_HumanDiseaseReport_Reopened_OtherSite = 10025048,

        /// <summary>
        /// Event fired when a Closed human disease report was re-opened at your site
        /// </summary>
        [Description("Closed human disease report was re-opened at your site")] Closed_HumanDiseaseReport_Reopened = 10025047,

        /// <summary>
        /// Event fired when a Closed human outbreak case was re-opened at a neighboring site
        /// </summary>
        [Description("Closed human outbreak case was re-opened at a neighboring site")] Closed_HumanOutbreakCase_Reopened_NeighboringSite = 10025546,

        /// <summary>
        /// Event fired when a Closed human outbreak case was re-opened at your site
        /// </summary>
        [Description("Closed human outbreak case was re-opened at your site")] Closed_HumanOutbreakCase_Reopened = 10025545,

        /// <summary>
        /// Event fired when a Closed veterinary Active surveillance session was re-opened at another site
        /// </summary>
        [Description("Closed veterinary Active surveillance session was re-opened at another site")] Closed_VetActiveSurveillanceSession_Reopened_OtherSite = 10025092,

        /// <summary>
        /// Event fired when a Closed veterinary Active surveillance session was re-opened at your site
        /// </summary>
        [Description("Closed veterinary Active surveillance session was re-opened at your site")] Closed_VetActiveSurveillanceSession_Reopened = 10025091,

        /// <summary>
        /// Event fired when a Closed veterinary disease report was re-opened at another site
        /// </summary>
        [Description("Closed veterinary disease report was re-opened at another site")] Closed_VetDiseaseReport_Reopened_OtherSite = 10025074,

        /// <summary>
        /// Event fired when a Closed veterinary disease report was re-opened at your site
        /// </summary>
        [Description("Closed veterinary disease report was re-opened at your site")] Closed_VetDiseaseReport_Reopened = 10025073,

        /// <summary>
        /// Event fired when a Closed veterinary outbreak case was re-opened at a neighboring site
        /// </summary>
        [Description("Closed veterinary outbreak case was re-opened at a neighboring site")] Closed_VetOutbreakCase_Reopened_NeighboringSite = 10025532,

        /// <summary>
        /// Event fired when a Closed veterinary outbreak case was re-opened at your site
        /// </summary>
        [Description("Closed veterinary outbreak case was re-opened at your site")] Closed_VetOutbreakCase_Reopened = 10025531,

        /// <summary>
        /// Event fired when Determinant for a flexible form template was changed
        /// </summary>
        [Description("Determinant for a flexible form template was changed")] FlexibleForm_Determinant_Changed = 10025121,

        /// <summary>
        /// Event fired when Human active surveillance campaign was changed at a neighboring site
        /// </summary>
        [Description("Human active surveillance campaign was changed at a neighboring site")] HumanActiveSurveillanceCampaign_Changed_NeighboringSite = 10025504,

        /// <summary>
        /// Event fired when Human active surveillance campaign was changed at your site
        /// </summary>
        [Description("Human active surveillance campaign was changed at your site")] HumanActiveSurviellanceCampaign_Changed = 10025503,

        /// <summary>
        /// Event fired when Human aggregate disease report was changed at another site
        /// </summary>
        [Description("Human aggregate disease report was changed at another site")] HumanAggregateDiseaseReport_Changed_OtherSite = 10025100,

        /// <summary>
        /// Event fired when Human aggregate disease report was changed at your site
        /// </summary>
        [Description("Human aggregate disease report was changed at your site")] HumanAggregateDiseaseReport_Changed = 10025099,

        /// <summary>
        /// Event fired when Human disease report classification was changed at another site
        /// </summary>
        [Description("Human disease report classification was changed at another site")] HumanDiseaseReportClassification_Changed_OtherSite = 10025042,

        /// <summary>
        /// Event fired when Human disease report classification was changed at your site
        /// </summary>
        [Description("Human disease report classification was changed at your site")] HumanDiseaseReportClassification_Changed = 10025041,

        /// <summary>
        /// Event fired when Human outbreak case classification was changed at a neighboring site
        /// </summary>
        [Description("Human outbreak case classification was changed at a neighboring site")] HumanOutbreakCaseClassification_Changed_NeighboringSite = 10025538,

        /// <summary>
        /// Event fired when Human outbreak case case classification was changed at your site
        /// </summary>
        [Description("Human outbreak case case classification was changed at your site")] HumanOutbreakCaseClassification_Changed = 10025537,

        /// <summary>
        /// Event fired when a Laboratory test result for a human active surveillance session was amended at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a human active surveillance session was amended at a neighboring site")] HumanActiveSurveillanceSession_LabTestResults_Amended_NeighboringSite = 10025511,

        /// <summary>
        /// Event fired when a Laboratory test result for a human active surveillance session was amended at your site
        /// </summary>
        [Description("Laboratory test result for a human active surveillance session was amended at your site")] HumanActiveSurveillanceSession_LabTestResults_Amended = 10025510,

        /// <summary>
        /// Event fired when a Laboratory test result for a human active surveillance session was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a human active surveillance session was interpreted at a neighboring site")] HumanActiveSurveillanceSession_LabTestResults_Interpreted_NeighboringSite = 10025516,

        /// <summary>
        /// Event fired when a Laboratory test result for a human active surveillance session was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a human active surveillance session was interpreted at your site")] HumanActiveSurveillanceSession_LabTestResults_Interpreted = 10025515,

        /// <summary>
        /// Event fired when a Laboratory test result for a human disease report was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a human disease report was interpreted at a neighboring site")] HumanDiseaseReport_LabTestResults_Interpreted_NeighboringSite = 10025518,

        /// <summary>
        /// Event fired when a Laboratory test result for a human disease report was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a human disease report was interpreted at your site")] HumanDiseaseReport_LabTestResults_Interpreted = 10025517,

        /// <summary>
        /// Event fired when a Laboratory test result for a human outbreak case was amended at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a human outbreak case was amended at a neighboring site")] HumanOutbreakCase_LabTestResults_Amended_NeighboringSite = 10025542,

        /// <summary>
        /// Event fired when a Laboratory test result for a human outbreak case was amended at your site
        /// </summary>
        [Description("Laboratory test result for a human outbreak case was amended at your site")] HumanOutbreakCase_LabTestResult_Amended = 10025541,

        /// <summary>
        /// Event fired when a Laboratory test result for a human outbreak case was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a human outbreak case was interpreted at a neighboring site")] HumanOutbreakCase_LabTestResult_Interpreted_NeighboringSite = 10025544,

        /// <summary>
        /// Event fired when a Laboratory test result for a human outbreak case was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a human outbreak case was interpreted at your site")] HumanOutbreakCase_LabTestResult_Interpreted = 10025543,

        /// <summary>
        /// Event fired when a Laboratory test result for a vector surveillance session was amended at another site
        /// </summary>
        [Description("Laboratory test result for a vector surveillance session was amended at another site")] VectorSurveillanceSession_LabTestResult_Amended_OtherSite = 10025084,

        /// <summary>
        /// Event fired when a Laboratory test result for a vector surveillance session was amended at your site
        /// </summary>
        [Description("Laboratory test result for a vector surveillance session was amended at your site")] VectorSurveillanceSession_LabTestResult_Amended = 10025083,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary active surveillance session was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a veterinary active surveillance session was interpreted at a neighboring site")] VetActiveSurveillanceSession_LabTestResult_Interpreted_NeighboringSite = 10025514,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary active surveillance session was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a veterinary active surveillance session was interpreted at your site")] VetActiveSurveillanceSession_LabTestResult_Interpreted = 10025513,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary disease report was amended at another site
        /// </summary>
        [Description("Laboratory test result for a veterinary disease report was amended at another site")] VetDiseaseReport_LabTestResult_Amended_OtherSite = 10025072,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary disease report was amended at your site
        /// </summary>
        [Description("Laboratory test result for a veterinary disease report was amended at your site")] VetDiseaseReport_LabTestResult_Amended = 10025071,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary disease report was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a veterinary disease report was interpreted at a neighboring site")] VetDiseaseReport_LabTestResult_Interpreted_NeighboringSite = 10025520,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary disease report was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a veterinary disease report was interpreted at your site")] VetDiseaseReport_LabTestResult_Interpreted = 10025519,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary outbreak case was amended at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a veterinary outbreak case was amended at a neighboring site")] VetOutbreakCase_LabTestResult_Amended_NeighboringSite = 10025528,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary outbreak case was amended at your site
        /// </summary>
        [Description("Laboratory test result for a veterinary outbreak case was amended at your site")] VetOutbreakCase_LabTestResult_Amended = 10025527,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary outbreak case was interpreted at a neighboring site
        /// </summary>
        [Description("Laboratory test result for a veterinary outbreak case was interpreted at a neighboring site")] VetOutbreakCase_LabTestResult_Interpreted_NeighboringSite = 10025530,

        /// <summary>
        /// Event fired when a Laboratory test result for a veterinary outbreak case was interpreted at your site
        /// </summary>
        [Description("Laboratory test result for a veterinary outbreak case was interpreted at your site")] VetOutbreakCase_LabTestResult_Interpreted = 10025529,

        /// <summary>
        /// Event fired when Matrix was changed
        /// </summary>
        [Description("Matrix was changed")] Matrix_Changed = 10025123,

        /// <summary>
        /// Event fired when a New  diagnosis was detected for a vector surveillance session at another site
        /// </summary>
        [Description("New diagnosis was detected for a vector surveillance session at another site")] VectorSurveillanceSession_NewDiagnosis_Detected_OtherSite = 10025078,

        /// <summary>
        /// Event fired when a New  diagnosis was detected for a vector surveillance session at your site
        /// </summary>
        [Description("New diagnosis was detected for a vector surveillance session at your site")] VectorSurveillanceSession_NewDiagnosis_Detected = 10025077,

        /// <summary>
        /// Event fired when a New  field test result for a vector surveillance session was registered at another site
        /// </summary>
        [Description("New field test result for a vector surveillance session was registered at another site")] VectorSurveillanceSession_NewFieldTestResult_Registered_OtherSite = 10025080,

        /// <summary>
        /// Event fired when a New field test result for a vector surveillance session was registered at your site
        /// </summary>
        [Description("New field test result for a vector surveillance session was registered at your site")] VectorSurveillanceSession_NewFieldTestResult_Registered = 10025079,

        /// <summary>
        /// Event fired when a New field test result for a veterinary disease report was registered at another site
        /// </summary>
        [Description("New field test result for a veterinary disease report was registered at another site")] VetDiseaseReport_NewFieldTestResult_Registered_OtherSite = 10025068,

        /// <summary>
        /// Event fired when a New field test result for a veterinary disease report was registered at your site
        /// </summary>
        [Description("New field test result for a veterinary disease report was registered at your site")] VetDiseaseReport_NewFieldTestResult_Registered = 10025067,

        /// <summary>
        /// Event fired when a New field test result for a veterinary outbreak case was registered at a neighboring site
        /// </summary>
        [Description("New field test result for a veterinary outbreak case was registered at a neighboring site")] VetOutbreakCase_NewFieldTestResult_Registered_NeighboringSite = 10025534,

        /// <summary>
        /// Event fired when a New field test result for a veterinary outbreak case was registered at your site
        /// </summary>
        [Description("New field test result for a veterinary outbreak case was registered at your site ")] VetOutbreakCase_NewFieldTestResult_Registered = 10025533,

        /// <summary>
        /// Event fired when a New human active surveillance campaign was created at your site.
        /// </summary>
        [Description("New human active surveillance campaign was created at your site. ")] HumanActiveSurveillanceCampaign_Created = 10025501,

        /// <summary>
        /// Event fired when a New human active surveillance campaign was received from another site
        /// </summary>
        [Description("New human active surveillance campaign was received from another site")] HumanActiveSurveillanceCampaign_Created_OtherSite = 10025502,

        /// <summary>
        /// Event fired when a New human active surveillance session was created at your site
        /// </summary>
        [Description("New human active surveillance session was created at your site")] HumanActiveSurveillanceSession_Created = 10025505,

        /// <summary>
        /// Event fired when a New human active surveillance session was received from another site
        /// </summary>
        [Description("New human active surveillance session was received from another site")] HumanActiveSurveillanceSession_Created_OtherSite = 10025506,

        /// <summary>
        /// Event fired when a New human aggregate disease report was created at another site
        /// </summary>
        [Description("New human aggregate disease report was created at another site")] HumanAggregateDiseaseReport_Created_OtherSite = 10025098,

        /// <summary>
        /// Event fired when a New human aggregate disease report was created at your site
        /// </summary>
        [Description("New human aggregate disease report was created at your site")] HumanAggregateDiseaseReport_Created = 10025097,

        /// <summary>
        /// Event fired when a New human disease report was added to outbreak at another site
        /// </summary>
        [Description("New human disease report was added to outbreak at another site")] HumanDiseaseReport_AddedToOutbreak_OtherSite = 10025052,

        /// <summary>
        /// Event fired when a New human disease report was added to outbreak at your site
        /// </summary>
        [Description("New human disease report was added to outbreak at your site")] HumanDiseaseReport_AddedToOutbreak = 10025051,

        /// <summary>
        /// Event fired when a New human disease report was created at another site
        /// </summary>
        [Description("New human disease report was created at another site")] HumanDiseaseReport_Created_OtherSite = 10025038,

        /// <summary>
        /// Event fired when a New human disease report was created at your site
        /// </summary>
        [Description("New human disease report was created at your site")] HumanDiseaseReport_Created = 10025037,

        /// <summary>
        /// Event fired when a New human outbreak case was created at your site
        /// </summary>
        [Description("New human outbreak case was created at your site")] HumanOutbreakCase_Created = 10025535,

        /// <summary>
        /// Event fired when a New human outbreak case was received from another site
        /// </summary>
        [Description("New human outbreak case was received from another site")] HumanOutbreakCase_Created_OtherSite = 10025536,

        /// <summary>
        /// Event fired when a New ILI Aggregate Form was created at another site
        /// </summary>
        [Description("New ILI Aggregate Form was created at another site")] ILIAggregateForm_Created_OtherSite = 10025130,

        /// <summary>
        /// Event fired when a New ILI Aggregate Form was created at your site
        /// </summary>
        [Description("New ILI Aggregate Form was created at your site")] ILIAggregateForm_Created = 10025129,

        /// <summary>
        /// Event fired when a New laboratory test result for a human active surveillance session was registered at a neighboring site
        /// </summary>
        [Description("New laboratory test result for a human active surveillance session was registered at a neighboring site")] HumanActiveSurveillance_LabTestResult_Registered_NeighboringSite = 10025512,

        /// <summary>
        /// Event fired when a New laboratory test result for a human active surveillance session was registered at your site
        /// </summary>
        [Description("New laboratory test result for a human active surveillance session was registered at your site")] HumanActiveSurveillance_LabTestResult_Registered = 10025509,

        /// <summary>
        /// Event fired when a New laboratory test result for a human outbreak case was registered at a neighboring site
        /// </summary>
        [Description("New laboratory test result for a human outbreak case was registered at a neighboring site")] HumanOutbreakCase_LabTestResult_Registered_NeighboringSite = 10025540,

        /// <summary>
        /// Event fired when a New laboratory test result for a human outbreak case was registered at your site
        /// </summary>
        [Description("New laboratory test result for a human outbreak case was registered at your site")] HumanOutbreakCase_LabTestResult_Registered = 10025539,

        /// <summary>
        /// Event fired when a New laboratory test result for a vector surveillance session was registered at another site
        /// </summary>
        [Description("New laboratory test result for a vector surveillance session was registered at another site")] VectorSurveillanceSession_LabTestResult_Registered_OtherSite = 10025082,

        /// <summary>
        /// Event fired when a New laboratory test result for a vector surveillance session was registered at your site
        /// </summary>
        [Description("New laboratory test result for a vector surveillance session was registered at your site")] VectorSurveillanceSession_LabTestResult_Registered = 10025081,

        /// <summary>
        /// Event fired when a New laboratory test result for a veterinary case was registered at a neighboring site
        /// </summary>
        [Description("New laboratory test result for a veterinary case was registered at a neighboring site")] VeterinaryCase_LabTestResult_Registered_NeighboringSite = 10025526,

        /// <summary>
        /// Event fired when a New laboratory test result for a veterinary case was registered at your site
        /// </summary>
        [Description("New laboratory test result for a veterinary case was registered at your site")] VeterinaryCase_LabTestResult_Registered = 10025525,

        /// <summary>
        /// Event fired when a New outbreak was created at another site
        /// </summary>
        [Description("New outbreak was created at another site")] Outbreak_Created_OtherSite = 10025050,

        /// <summary>
        /// Event fired when a New outbreak was created at your site
        /// </summary>
        [Description("New outbreak was created at your site")] Outbreak_Created = 10025049,

        /// <summary>
        /// Event fired when a New sample was transferred from your laboratory
        /// </summary>
        [Description("New sample was transferred from your laboratory")] Sample_Transferred_FromYourLab = 10025131,

        /// <summary>
        /// Event fired when a New sample was transferred to your laboratory
        /// </summary>
        [Description("New sample was transferred to your laboratory")] Sample_Transferred_ToYourLab = 10025125,

        /// <summary>
        /// Event fired when a New test result for a human disease report was registered at another site
        /// </summary>
        [Description("New test result for a human disease report was registered at another site")] HumanDiseaseReport_TestResult_Registered_OtherSite = 10025044,

        /// <summary>
        /// Event fired when a New test result for a human disease report was registered at your site
        /// </summary>
        [Description("New test result for a human disease report was registered at your site")] HumanDiseaseReport_TestResult_Registered = 10025043,

        /// <summary>
        /// Event fired when a New test result for a veterinary Active surveillance session was registered at another site
        /// </summary>
        [Description("New test result for a veterinary Active surveillance session was registered at another site")] VetActiveSurveillanceSession_TestResult_Registered_OtherSite = 10025094,

        /// <summary>
        /// Event fired when a New test result for a veterinary Active surveillance session was registered at your site
        /// </summary>
        [Description("New test result for a veterinary Active surveillance session was registered at your site")] VetActiveSurveillanceSession_TestResult_Registered = 10025093,

        /// <summary>
        /// Event fired when a New vector surveillance session was added to outbreak at another site
        /// </summary>
        [Description("New vector surveillance session was added to outbreak at another site")] VectorSurveillanceSession_AddedToOutBreak_OtherSite = 10025056,

        /// <summary>
        /// Event fired when a New vector surveillance session was added to outbreak at your site
        /// </summary>
        [Description("New vector surveillance session was added to outbreak at your site")] VectorSurveillanceSession_AddedToOutBreak = 10025055,

        /// <summary>
        /// Event fired when a New vector surveillance session was created at another site
        /// </summary>
        [Description("New vector surveillance session was created at another site")] VectorSurveillanceSession_Created_OtherSite = 10025076,

        /// <summary>
        /// Event fired when a New vector surveillance session was created at your site
        /// </summary>
        [Description("New vector surveillance session was created at your site")] VectorSurveillanceSession_Created = 10025075,

        /// <summary>
        /// Event fired when a New veterinary Active surveillance campaign was created at another site
        /// </summary>
        [Description("New veterinary Active surveillance campaign was created at another site")] VetActiveSurveillanceCampaign_Created_OtherSite = 10025086,

        /// <summary>
        /// Event fired when a New veterinary Active surveillance campaign was created at your site
        /// </summary>
        [Description("New veterinary Active surveillance campaign was created at your site")] VetActiveSurveillanceCampaign_Created = 10025085,

        /// <summary>
        /// Event fired when a New veterinary Active surveillance session was created at another site
        /// </summary>
        [Description("New veterinary Active surveillance session was created at another site")] VetActiveSurveillanceSession_Created_OtherSite = 10025088,

        /// <summary>
        /// Event fired when a New veterinary Active surveillance session was created at your site
        /// </summary>
        [Description("New veterinary Active surveillance session was created at your site")] VetActiveSurveillanceSession_Created = 10025087,

        /// <summary>
        /// Event fired when a New veterinary aggregate action was created at another site
        /// </summary>
        [Description("New veterinary aggregate action was created at another site")] VetAggregateAction_Created_OtherSite = 10025106,

        /// <summary>
        /// Event fired when a New veterinary aggregate action was created at your site
        /// </summary>
        [Description("New veterinary aggregate action was created at your site")] VetAggregateAction_Created = 10025105,

        /// <summary>
        /// Event fired when a New  veterinary aggregate disease report was changed at another site
        /// </summary>
        [Description("New veterinary aggregate disease report was changed at another site")] VetAggregateDiseaseReport_Changed = 10025103,

        /// <summary>
        /// Event fired when a New  veterinary aggregate disease report was changed at another site
        /// </summary>
        [Description("New veterinary aggregate disease report was changed at another site")] VetAggregateDiseaseReport_Changed_OtherSite = 10025104,

        /// <summary>
        /// Event fired when a New  veterinary aggregate disease report was created at another site
        /// </summary>
        [Description("New veterinary aggregate disease report was created at another site")] VetAggregateDiseaseReport_Created_OtherSite = 10025101,

        /// <summary>
        /// Event fired when a New  veterinary aggregate disease report was created at your site
        /// </summary>
        [Description("New veterinary aggregate disease report was created at your site")] VetAggregateDiseaseReport_Created = 10025102,

        /// <summary>
        /// Event fired when a New  veterinary disease report was added to outbreak at another site
        /// </summary>
        [Description("New veterinary disease report was added to outbreak at another site")] VetDiseaseReport_AddedToOutbreak_OtherSite = 10025054,

        /// <summary>
        /// Event fired when a New  veterinary disease report was added to outbreak at your site
        /// </summary>
        [Description("New veterinary disease report was added to outbreak at your site")] VetDiseaseReport_AddedToOutbreak = 10025053,

        /// <summary>
        /// Event fired when a New  veterinary disease report was created at another site
        /// </summary>
        [Description("New veterinary disease report was created at another site")] VetDiseaseReport_Created_OtherSite = 10025062,

        /// <summary>
        /// Event fired when a New  veterinary disease report was created at your site
        /// </summary>
        [Description("New veterinary disease report was created at your site")] VetDiseaseReport_Created = 10025061,

        /// <summary>
        /// Event fired when a New  veterinary outbreak case was created at your site
        /// </summary>
        [Description("New veterinary outbreak case was created at your site")] VetOutbreakCase_Created_OtherSite = 10025521,

        /// <summary>
        /// Event fired when a New  veterinary outbreak case was received from another site
        /// </summary>
        [Description("New veterinary outbreak case was received from another site")] VetOutbreakCase_ReceivedFromOtherSite = 10025522,

        /// <summary>
        /// Event fired when Notification service is not running
        /// </summary>
        [Description("Notification service is not running")] Notification_Service_Is_Not_Running = 10025114,

        /// <summary>
        /// Event fired when Outbreak status was changed at another site
        /// </summary>
        [Description("Outbreak status was changed at another site")] Outbreak_Status_Changed_OtherSite = 10025058,

        /// <summary>
        /// Event fired when Outbreak status was changed at your site
        /// </summary>
        [Description("Outbreak status was changed at your site")] Outbreak_Status_Changed = 10025057,

        /// <summary>
        /// Event fired when Primary case was changed in outbreak at another site
        /// </summary>
        [Description("Primary case was changed in outbreak at another site")] Outbreak_PrimaryCase_Changed_OtherSite = 10025060,

        /// <summary>
        /// Event fired when Primary case was changed in outbreak at your site
        /// </summary>
        [Description("Primary case was changed in outbreak at your site")] Outbreak_PrimaryCase_Changed = 10025059,

        /// <summary>
        /// Event fired when base reference value changes
        /// </summary>
        [Description("Raise Reference Cache Change")] Raise_Reference_Cache_Change = 10025124,

        /// <summary>
        /// Event fired when Reference table was changed
        /// </summary>
        [Description("Reference table was changed")] Reference_Data_Changed = 10025122,

        /// <summary>
        /// Event fired when Replicated data are delivered to CDR
        /// </summary>
        [Description("Replicated data are delivered to CDR")] Replicated_data_are_delivered_to_CDR = 10025143,

        /// <summary>
        /// Event fired when Security policy was changed
        /// </summary>
        [Description("Security policy was changed")] Security_policy_was_changed = 10025119,

        /// <summary>
        /// Event fired when Settlement Changed
        /// </summary>
        [Description("Settlement Changed")] Settlement_Changed = 10025030,

        /// <summary>
        /// Event fired when Test result for a human disease report was amended at another site
        /// </summary>
        [Description("Test result for a human disease report was amended at another site")] HumanDiseaseReport_TestResult_Amended_OtherSite = 10025046,

        /// <summary>
        /// Event fired when Test result for a human disease report was amended at your site
        /// </summary>
        [Description("Test result for a human disease report was amended at your site")] HumanDiseaseReport_TestResult_Amended = 10025045,

        /// <summary>
        /// Event fired when Test result for sample transferred in to your laboratory is entered
        /// </summary>
        [Description("Test result for sample transferred in to your laboratory is entered")] Sample_TestResults_Transferred_IntoLab_Entered = 10025142,

        /// <summary>
        /// Event fired when Test result for sample transferred out from your laboratory is entered
        /// </summary>
        [Description("Test result for sample transferred out from your laboratory  is entered")] Sample_TestResults_Transferred_OutOfLab_Entered = 10025126,

        /// <summary>
        /// Event fired when Test result for a veterinary Active surveillance session was amended at another site
        /// </summary>
        [Description("Test result for a veterinary Active surveillance session was amended at another site")] ActiveSurveillanceSession_TestResults_Amended_OtherSite = 10025096,

        /// <summary>
        /// Event fired when Test result for a veterinary Active surveillance session was amended at your site
        /// </summary>
        [Description("Test result for a veterinary Active surveillance session was amended at your site")] ActiveSurveillanceSession_TestResults_Amended = 10025095,

        /// <summary>
        /// Event fired when a UNI template for a flexible form type was changed
        /// </summary>
        [Description("UNI template for a flexible form type was changed")] FlexibleForm_UNITemplate_Changed = 10025120,

        /// <summary>
        /// Event fired when veterinary Active surveillance campaign status was changed at another site
        /// </summary>
        [Description("veterinary Active surveillance campaign status was changed at another site")] VetActiveSurveillanceCampaign_Changed_OtherSite = 10025090,

        /// <summary>
        /// Event fired when veterinary Active surveillance campaign status was changed at your site
        /// </summary>
        [Description("veterinary Active surveillance campaign status was changed at your site")] VetActiveSurveillanceCampaign_Changed = 10025089,

        /// <summary>
        /// Event fired when Veterinary aggregate action was changed at another site
        /// </summary>
        [Description("Veterinary aggregate action was changed at another site")] VetAggregateAction_Changed_OtherSite = 10025108,

        /// <summary>
        /// Event fired when Veterinary aggregate action was changed at your site
        /// </summary>
        [Description("Veterinary aggregate action was changed at your site")] VetAggregateAction_Changed = 10025107,

        /// <summary>
        /// Event fired when veterinary disease report classification was changed at another site
        /// </summary>
        [Description("veterinary disease report classification was changed at another site")] VetDiseaseReportClassification_Changed_OtherSite = 10025066,

        /// <summary>
        /// Event fired when veterinary disease report classification was changed at your site
        /// </summary>
        [Description("veterinary disease report classification was changed at your site")] VetDiseaseReportClassification_Changed = 10025065,

        /// <summary>
        /// Event fired when a Veterinary outbreak case classification was changed at a neighboring site
        /// </summary>
        [Description("Veterinary outbreak case classification was changed at a neighboring site")] VetOutbreakCaseClassification_Changed_NeighboringSite = 10025524,

        /// <summary>
        /// Event fired when a Veterinary outbreak case classification was changed at your site
        /// </summary>
        [Description("Veterinary outbreak case classification was changed at your site")] VetOutbreakCaseClassification_Changed = 10025523,
    }
}