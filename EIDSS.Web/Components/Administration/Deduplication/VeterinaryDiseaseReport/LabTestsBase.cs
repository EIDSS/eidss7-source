using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class LabTestsBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<LabTestsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<LaboratoryTestGetListViewModel> LabTestsGrid;
		protected RadzenDataGrid<LaboratoryTestGetListViewModel> LabTestsGrid2;
		protected RadzenDataGrid<LaboratoryTestInterpretationGetListViewModel> InterpretationsGrid;
		protected RadzenDataGrid<LaboratoryTestInterpretationGetListViewModel> InterpretationsGrid2;


		#endregion

		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;

		#endregion

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            if (Model.ReportType == VeterinaryReportTypeEnum.Avian)
            {
                LabTestsSubSectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportLabTestsHeading);
                ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .AvianDiseaseReportResultsSummaryInterpretationHeading);

                LaboratoryTestsSpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportLabTestsSpeciesColumnHeading);
                LaboratoryTestsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsFieldSampleIDColumnHeading);
                LaboratoryTestsTestDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsTestDiseaseColumnHeading);
                LaboratoryTestsTestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportLabTestsTestNameColumnHeading);
                LaboratoryTestsResultObservationColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsResultObservationColumnHeading);

                LabSampleIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsSampleTypeFieldLabel;
                TestStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsTestStatusFieldLabel;
                TestCategoryFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsTestCategoryFieldLabel;
                ResultDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsResultDateFieldLabel;

                LaboratoryTestInterpretationsSpeciesColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationSpeciesColumnHeading);
                LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading);
                LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestNameColumnHeading);
                LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading);
                LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestResultColumnHeading);
                LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading);
                LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading);
                LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading);
                LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading);
                LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading);
                LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading);
            }
            else
            {
                LabTestsSubSectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportLabTestsHeading);
                ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .LivestockDiseaseReportResultsSummaryInterpretationHeading);

                LaboratoryTestsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsFieldSampleIDColumnHeading);
                LaboratoryTestsAnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportLabTestsAnimalIDColumnHeading);
                LaboratoryTestsTestDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsTestDiseaseColumnHeading);
                LaboratoryTestsTestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportLabTestsTestNameColumnHeading);
                LaboratoryTestsResultObservationColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsResultObservationColumnHeading);

                LabSampleIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsSampleTypeFieldLabel;
                TestStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsTestStatusFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestsTestCategoryFieldLabel;
                ResultDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsResultDateFieldLabel;

                LaboratoryTestInterpretationsAnimalIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationAnimalIDColumnHeading);
                LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading);
                LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestNameColumnHeading);
                LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading);
                LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestResultColumnHeading);
                LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading);
                LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading);
                LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading);
                LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading);
                LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading);
                LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading);
            }

            await base.OnInitializedAsync();
			StateHasChanged();
		}

		private async Task OnStateContainerChangeAsync(string property)
		{
			await InvokeAsync(StateHasChanged);
		}

		public void Dispose()
		{
			try
			{
				source?.Cancel();
				source?.Dispose();

				VeterinaryDiseaseReportDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);

			}
			catch (Exception)
			{
				throw;
			}
		}
	}
}
