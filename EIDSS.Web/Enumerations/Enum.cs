using System.ComponentModel;

namespace EIDSS.Web.Enumerations
{
    /// <summary>
    /// Determines how the links in screens that are shown in dialogs react:
    ///     Default - navigate to the default action (usually read-only view of report)
    ///     Import - start the import process for the selected report using the CallbackUrl provided by calling component
    ///     Select - simply pass the id of the report to the calling component
    ///     SelectEvent - raises the select event as this is being called via a view and not a dialog.
    ///     SelectNoRedirect - simply closes the dialog and returns to the calling view for further action
    /// </summary>
    public enum SearchModeEnum
    {
        Default,
        Import,
        Select,
        SelectEvent,
        SelectNoRedirect
    }

    /// <summary>
    /// Sets the type of the veterinary disease report (Avian or Livestock)
    /// </summary>
    public enum VeterinaryReportTypeEnum
    {
        Avian,
        Livestock
    }

    #region XSite Enumerations

    /// <summary>
    /// Specifies application module groupings for XSite help documentation.
    /// </summary>
    public enum DocumentGroupEnum
    {
        ActiveSurveillanceSession,
        AvianDiseaseReport,
        HumanDiseaseReport,
        Laboratory,
        LivestockDiseaseReport,
        Person,
        VeterinaryAggregateActionReport,
        VeterinaryAggregateCase
    }

    /// <summary>
    /// Specifies application module groupings for XSite help documentation.
    /// </summary>
    public enum DocumentContainerTypeEnum
    {
        [Description("Aberration Analysis")] AberrationAnalysis,
        [Description("Active Surveillance Campaign")] ActiveSurveillanceCampaign,
        [Description("Active Surveillance Session")] ActiveSurveillanceSession,
        [Description("Aggregate Action Report")] AggregateActionReport,
        [Description("Aggregate Disease Report")] AggregateDiseaseReport,
        [Description("Aggregate Reports")] AggregateReports,
        [Description("Approvals")] Approvals,
        [Description("Avian Disease Report")] AvianDiseaseReport,
        [Description("Basic Reporting")] BasicReporting,
        [Description("Batches")] Batches,
        [Description("Cases")] Cases,
        [Description("Deduplication")] Deduplication,
        [Description("Demonstration Data Sets")] DemonstrationDataSets,
        [Description("Editors")] Editors,
        [Description("Editors and Configuration")] EditorsAndConfiguration,
        [Description("Employee")] Employee,
        [Description("Farm")] Farm,
        [Description("Freezers")] Freezers,
        [Description("General Functionality")] GeneralFunctionality,
        [Description("Getting Started")] GettingStarted,
        [Description("Human Disease Report")] HumanDiseaseReport,
        [Description("ILI Aggregate")] ILIAggregate,
        [Description("Instructor Guides")] InstructorGuides,
        [Description("Livestock Disease Report")] LivestockDiseaseReport,
        [Description("Matrix Configuation")] MatrixConfiguation,
        [Description("Organization")] Organization,
        [Description("Person")] Person,
        [Description("Queries")] Queries,
        [Description("Records")] Records,
        [Description("Samples")] Samples,
        [Description("Sessions")] Sessions,
        [Description("Settlement")] Settlement,
        [Description("Statistical Data")] StatisticalData,
        [Description("Tests")] Tests,
        [Description("Transfers")] Transfers,
        [Description("Vector Surveillance Session")] VectorSurveillanceSession,
        [Description("Videos")] Videos,
        [Description("None")] None
    }

    /// <summary>
    /// Specifies application module groupings for XSite help documentation.
    /// </summary>
    public enum ParentDocumentContainerTypeEnum
    {
        [Description("Admin")] Admin,
        [Description("Aggregate Reports")] AggregateReports,
        [Description("FAQs")] FAQs,
        [Description("Human")] Human,
        [Description("Laboratory")] Laboratory,
        [Description("Outbreak")] Outbreak,
        [Description("Records")] Records,
        [Description("Reports")] Reports,
        [Description("Training")] Training,
        [Description("Vector")] Vector,
        [Description("Veterinary")] Veterinary
    }

    #endregion

    /// <summary>
    /// Sets the type of the veterinary disease report Deduplication (Avian or Livestock)
    /// </summary>
    public enum VeterinaryDiseaseReportDeduplicationTypeEnum
    {
        Avian,
        Livestock
    }
}