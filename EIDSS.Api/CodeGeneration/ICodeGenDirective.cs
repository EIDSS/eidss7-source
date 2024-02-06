using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using System;

namespace EIDSS.Api.CodeGeneration.Control
{
    /// <summary>
    /// An enumeration that explains both the type of application operation being performed and
    /// the subsequent type of API method that will ultimate be generated.
    /// </summary>
    public enum APIMethodVerbEnumeration
    {
        /// <summary>
        /// Produces an API method with a verb type of DELETE.
        /// Choose this type when you wish to perform a delete operation.
        /// This type typically returns the type <see cref="APIPostResponseModel"/>, therefore your APIReturnType property should be set to return this type.
        /// </summary>
        DELETE,

        /// <summary>
        /// Produces an API method with a verb type of GET.  
        /// Choose this type when the method's parameters are not passed via the body.
        /// </summary>
        GET,
        
        /// <summary>
        /// Produces an API method with a verb type of POST.
        /// Choose this type when the method's parameters are passed via the body.
        /// </summary>
        GET_USING_POST_VERB,


        /// <summary>
        /// Produces an API method with a verb typ of POST.
        /// Choose this type when you wish to peform an update.  The paramaters are passed via the body for this method type.
        /// This type typically returns the type <see cref="APISaveResponseModel"/>, therefore your APIReturnType property should by set to return this type.
        /// </summary>
        SAVE

    }

    /// <summary>
    /// The APICodeGenerator generates API controller methods for all classes that implement this interface 
    /// and places it into the controller specified by the APIClassName member.
    /// </summary>
    public interface ICodeGenDirective
    {
        /// <summary>
        /// The controller this API method will be generated in.
        /// </summary>
        string APIClassName { get; }

        /// <summary>
        /// The Swagger group name that this api method will be placed in.
        /// </summary>
        string APIGroupName { get; } 

        /// <summary>
        /// Indicates the return type of the repository function that will be called in the EIDSSContext class.
        /// </summary>
        Type APIReturnType { get; }

        /// <summary>
        /// A 64 bit signed integer representing the base reference identifier of the system event the API method fires when completed.
        /// This value is defaulted and must specify the actual event participation in all implemented classes.
        /// </summary>
        //public SystemEventEnum FiresEvent => SystemEventEnum.DoesNotParticipate;

        /// <summary>
        /// A string representing the generated API parameters.  Typically these paramaters mimic the parameters
        /// called on the EIDSSContext class.
        /// </summary>
        public string MethodParameters { get; }

        /// <summary>
        /// The type of api method to generate.
        /// </summary>
        APIMethodVerbEnumeration MethodVerb { get; }

        /// <summary>
        /// The return type of the called repository function.
        /// </summary>
        Type RepositoryReturnType { get; }

        /// <summary>
        /// A string describing the operation of the API method.  This string will decorate the API method and provide
        /// the Swagger API description text.
        /// </summary>
        string SummaryInfo { get;  }
    }

    public static class APIGroupNameConstants
    {
        public static string AdministrationBaseReferenceEditors => "Administration - Base Reference Editors";
        public static string AdministrationOtherEditors => "Administration - Other Editors";
        public static string AdminUserAdministration => "Administration - Users";
        public static string ConfigurationMatrices => "Configuration Matrices";
        public static string CrossCutting => "Cross Cutting";
        public static string Reports => "Reports";
        public static string Notification => "Notification";


    }

    public static class TargetedClassNames
    {
        public static string AdminController => "AdminController.cs";
        public static string AgeGroupReferenceEditorController => "AgeGroupReferenceEditorController.cs";
        public static string AggregateReportController => "AggregateReportController.cs";
        public static string AggregateSettingsController => "AggregateSettingsController.cs";
        public static string BaseReferenceEditorController => "BaseReferenceEditorController.cs";
        public static string CaseClassificationsReferenceEditorController => "CaseClassificationsReferenceEditorController.cs";
        public static string ConfigurationController => "ConfigurationController.cs";
        public static string CrossCuttingController => "CrossCuttingController.cs";
        public static string CustomReportMatrixController => "CustomReportMatrixController.cs";
        public static string DataArchivingController => "DataArchivingController.cs";
        public static string DiseaseAgeGroupMatrixController => "DiseaseAgeGroupMatrixController.cs";
        public static string DiseaseGroupDiseaseMatrixController => "DiseaseGroupDiseaseMatrixController.cs";
        public static string DiseaseHumanGenderMatrixController => "DiseaseHumanGenderMatrixController.cs";
        public static string DiseaseLabTestMatrixController => "DiseaseLabTestMatrixController.cs";
        public static string DiseasePensideTestMatrixController => "DiseasePensideTestMatrixController.cs";
        public static string DiseaseReferenceEditorController => "DiseaseReferenceEditorController.cs";
        public static string EmployeesController => "EmployeesController.cs";

        // Veterinary
        public static string FarmController => "FarmController.cs";
        
        public static string FlexFormController => "FlexFormController.cs";
        public static string FreezerController => "FreezerController.cs";
        public static string HumanActiveSurveillanceCampaignController => "HumanActiveSurveillanceCampaignController.cs";
        public static string HumanActiveSurveillanceSessionController => "HumanActiveSurveillanceSessionController.cs";
        public static string HumanAggregateDiseaseMatrixController => "HumanAggregateDiseaseMatrixController.cs";
        public static string HumanDiseaseReportController => "HumanDiseaseReportController..cs";
        public static string ILIAggregateFormController => "ILIAggregateFormController.cs";
        public static string InterfaceEditorController => "InterfaceEditorController.cs";
        public static string LaboratoryController => "LaboratoryController.cs";
        public static string MeasuresReferenceEditorController => "MeasuresReferenceEditorController.cs";
        public static string MenuController => "MenuController.cs";
        public static string OutbreakController => "OutbreakController.cs";
        public static string ParameterTypeEditorController => "ParameterTypeEditorController.cs";
        public static string PersonalIdentificationTypeMatrixController => "PersonalIdentificationTypeMatrixController.cs";
        public static string PersonController => "PersonController.cs";
        public static string PreferenceController => "PreferenceController.cs";
        public static string ReportCrossCuttingController => "ReportCrossCuttingController.cs";
        public static string ReportDiseaseGroupDiseaseMatrixController => "ReportDiseaseGroupDiseaseMatrixController.cs";
        public static string ReportDiseaseGroupsReferenceEditorController => "ReportDiseaseGroupsReferenceEditorController.cs";
        public static string SampleTypesReferenceEditorController => "SampleTypesReferenceEditorController.cs";
        public static string SecurityPolicyController => "SecurityPolicyController.cs";
        public static string SettlementController => "SettlementController.cs";
        public static string SiteAlertsSubscriptionController => "SiteAlertsSubscriptionController.cs";
        public static string SiteController => "SiteController.cs";
        public static string SpeciesTypesReferenceEditorController => "SpeciesTypesReferenceEditorController.cs";
        public static string StatisticalAgeGroupMatrixController => "StatisticalAgeGroupMatrixController.cs";
        public static string StatisticalTypesReferenceEditorController => "StatisticalTypesReferenceEditorController.cs";
        public static string StatisticalDataController => "StatisticalDataController.cs";

        public static string TestNameTestResultsMatrixController => "TestNameTestResultsMatrixController.cs";
        public static string UniqueNumberingSchemaController => "UniqueNumberingSchemaController.cs";
        public static string UserGroupController => "UserGroupController.cs";
        public static string VectorSpeciesTypesReferenceEditorController => "VectorSpeciesTypesReferenceEditorController.cs";

        public static string VectorSurveillanceSessionController => "VectorSurveillanceSessionController.cs";
        public static string VectorTypeCollectionMethodMatrixController => "VectorTypeCollectionMethodMatrixController.cs";
        public static string VectorTypeFieldTestMatrixController => "VectorTypeFieldTestMatrixController.cs";
        public static string VectorTypeReferenceEditorController => "VectorTypeReferenceEditorController.cs";
        public static string VectorTypeSampleTypeMatrixController => "VectorTypeSampleTypeMatrixController.cs";
        public static string VeterinaryActiveSurveillanceSessionController => "VeterinaryActiveSurveillanceSessionController.cs";
        public static string VeterinaryAggregateDiseaseMatrixController => "VeterinaryAggregateDiseaseMatrixController.cs";
        public static string VeterinaryDiseaseReportController => "VeterinaryDiseaseReportController.cs";
        public static string VeterinaryProphylacticMeasureMatrixController => "VeterinaryProphylacticMeasureMatrixController.cs";
        public static string VeterinarySanitaryActionMatrixController => "VeterinarySanitaryActionMatrixController.cs";
        public static string VeterinaryActiveSurveillanceCampaignController => "VeterinaryActiveSurveillanceCampaignController.cs";

        //WeeklyReporting Form
        public static string WeeklyReportingFormController => "WeeklyReportingFormController.cs";
        //Notification
        public static string NotificationController => "NotificationController.cs";
        public static string DashboardController => "DashboardController.cs";
        //WHO Export
        public static string WHOExportController => "WHOExportController.cs";
    }

}