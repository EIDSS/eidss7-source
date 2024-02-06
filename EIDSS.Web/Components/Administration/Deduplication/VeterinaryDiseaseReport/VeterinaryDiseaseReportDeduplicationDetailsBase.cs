using EIDSS.Domain.Enumerations;
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
    public class VeterinaryDiseaseReportDeduplicationDetailsBase : VeterinaryDiseaseReportDeduplicationBaseComponent
	{
		#region Dependencies

        [Inject]
		private ILogger<VeterinaryDiseaseReportDeduplicationDetailsBase> Logger { get; set; }

		#endregion

		#region request
		[Parameter]
		public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        [Parameter]
        public VeterinaryDiseaseReportDeduplicationTabEnum Tab { get; set; }
        #endregion

        #region Protected and Public Variables

        protected RadzenTemplateForm<VeterinaryDiseaseReportDeduplicationDetailsViewModel> Form;

		protected bool shouldRender = true;

		#endregion

		#region Private Variables

		private CancellationTokenSource _source;
		protected CancellationToken Token;

		#endregion

		#region Protected and Public Methods

		protected override async Task OnInitializedAsync()
		{
			// reset the cancellation token
			_source = new CancellationTokenSource();
			Token = _source.Token;

			_logger = Logger;

			authenticatedUser = _tokenService.GetAuthenticatedUser();

			// Wire up FarmDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async _ => await OnStateContainerChangeAsync();

			if (Model.ReportType == VeterinaryReportTypeEnum.Avian)
			{
				VeterinaryDiseaseReportDeduplicationService.ReportType = VeterinaryReportTypeEnum.Avian;
				FarmInventoryHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportFarmFlockSpeciesHeading);
				SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesSpeciesColumnHeading);
				TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesTotalColumnHeading);
				SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesSickColumnHeading);
				DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesDeadColumnHeading);
				StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesStartOfSignsColumnHeading);
				AverageAgeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportFarmFlockSpeciesAverageAgeWeeksColumnHeading);
				LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesLabSampleIDColumnHeading);
				SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesSampleTypeColumnHeading);
				FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesFieldSampleIDColumnHeading);
				//SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
				//	.AvianDiseaseReportSamplesSpeciesColumnHeading);
				BirdStatusColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesBirdStatusColumnHeading);
				CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesCollectionDateColumnHeading);
				SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesSentDateColumnHeading);
				SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportSamplesSentToOrganizationColumnHeading);
				TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportPensideTestsTestNameColumnHeading);
				ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.AvianDiseaseReportPensideTestsResultColumnHeading);

				LabTestsSubSectionHeadingResourceKey =
	Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportLabTestsHeading);
				ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
					.AvianDiseaseReportResultsSummaryInterpretationHeading);
				//LaboratoryTestDetailsHeadingResourceKey =
				//    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportLabTestDetailsModalHeading);
				//LaboratoryTestInterpretationDetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants
				//    .AvianDiseaseReportInterpretationDetailsModalHeading);

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
				VeterinaryDiseaseReportDeduplicationService.ReportType = VeterinaryReportTypeEnum.Livestock;
				FarmInventoryHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportFarmHerdSpeciesHeading);
				SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesSpeciesColumnHeading);
				TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesTotalColumnHeading);
				SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesSickColumnHeading);
				DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesDeadColumnHeading);
				StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesStartOfSignsColumnHeading);
				NoteColumnHeadingResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
					.LivestockDiseaseReportFarmHerdSpeciesNoteIncludeBreedFieldLabel);
				LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesLabSampleIDColumnHeading);
				SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesSampleTypeColumnHeading);
				FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesFieldSampleIDColumnHeading);
				AnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesAnimalIDColumnHeading);
				//SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
				//	.LivestockDiseaseReportSamplesSpeciesColumnHeading);
				CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesCollectionDateColumnHeading);
				SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesSentDateColumnHeading);
				SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportSamplesSentToOrganizationColumnHeading);
				TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportPensideTestsTestNameColumnHeading);
				ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
					.LivestockDiseaseReportPensideTestsResultColumnHeading);

				LabTestsSubSectionHeadingResourceKey =
					Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportLabTestsHeading);
				ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
					.LivestockDiseaseReportResultsSummaryInterpretationHeading);
				//LaboratoryTestDetailsHeadingResourceKey =
				//    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportLabTestDetailsModalHeading);
				//LaboratoryTestInterpretationDetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants
				//    .LivestockDiseaseReportInterpretationDetailsModalHeading);

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
			await InitializeModelAsync();
			OnChange(0);
			//disableMergeButton = true;
		}

		public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            VeterinaryDiseaseReportDeduplicationService.OnChange -= async _ => await OnStateContainerChangeAsync();
        }

		#endregion

		#region Details

		public void OnChange(int index)
		{
			Tab = (VeterinaryDiseaseReportDeduplicationTabEnum)index;
			OnTabChange(index);
		}

		public void NextClicked()
		{
			switch (Tab)
			{
				case VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Notification:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination:
					Tab = Model.ReportType == VeterinaryReportTypeEnum.Livestock ? VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures : VeterinaryDiseaseReportDeduplicationTabEnum.Samples;

					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Animals;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Animals:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Samples;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Samples:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.LabTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.LabTests:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.CaseLog;
					ShowPreviousButton = true;
					ShowNextButton = false;
					break;
			}

			VeterinaryDiseaseReportDeduplicationService.TabChangeIndicator = true;
		}

		public void PreviousClicked()
		{
			switch (Tab)
			{
				case VeterinaryDiseaseReportDeduplicationTabEnum.Notification:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails;
					ShowPreviousButton = false;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Animals:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.Samples:
                    Tab = Model.ReportType == VeterinaryReportTypeEnum.Livestock ? VeterinaryDiseaseReportDeduplicationTabEnum.Animals : VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;

                    ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Samples;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.LabTests:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case VeterinaryDiseaseReportDeduplicationTabEnum.CaseLog:
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.LabTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
			}

			VeterinaryDiseaseReportDeduplicationService.TabChangeIndicator = true;
		}

		protected async Task CancelMergeClicked()
		{
			try
			{
				var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null).ConfigureAwait(false);
				if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
				{
					//cancel search and user said yes
					_source?.Cancel();
					shouldRender = false;
                    var uri = Model.ReportType == VeterinaryReportTypeEnum.Livestock ? $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/LivestockDiseaseReportDeduplication?showSelectedRecordsIndicator=true" : $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication?showSelectedRecordsIndicator=true";

					NavManager.NavigateTo(uri, true);
				}
				else
				{
					//cancel search but user said no so leave everything alone and cancel thread
					_source?.Cancel();
				}
			}
			catch (Exception ex)
			{
				Logger.LogError(ex, ex.Message);
				throw;
			}
		}

		#endregion

		#region Private Methods

		private async Task InitializeModelAsync()
		{
			Model ??= new VeterinaryDiseaseReportDeduplicationDetailsViewModel()
            {
                LeftVeterinaryDiseaseReportID = VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID,
                RightVeterinaryDiseaseReportID = VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2,
            };

			await FillDeduplicationDetailsAsync(Model, Model.LeftVeterinaryDiseaseReportID, Model.RightVeterinaryDiseaseReportID);

			VeterinaryDiseaseReportDeduplicationService.OnChange += async _ => await OnStateContainerChangeAsync();
		}

		private async Task OnStateContainerChangeAsync()
		{
			await InvokeAsync(StateHasChanged);
		}

		#endregion

		#region Review

		protected async Task EditClickAsync(int index)
		{
			ShowDetails = true;
			ShowReview = false;
			switch (index)
			{
				case 0:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmDetails;
					OnTabChange(0);
					break;
				case 1:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Notification;
					OnTabChange(1);
					break;
				case 2:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmInventory;
					OnTabChange(2);
					break;
				case 3:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					OnTabChange(3);
					break;
				case 4:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					OnTabChange(4);
					break;
				case 5:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Vaccination;
					OnTabChange(5);
					break;
				case 6:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.ControlMeasures;
					OnTabChange(6);
					break;
				case 7:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Animals;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Animals;
					OnTabChange(7);
					break;
				case 8:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Samples;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.Samples;
					OnTabChange(8);
					break;
				case 9:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.PensideTests;
					OnTabChange(9);
					break;
				case 10:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.LabTests;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.LabTests;
					OnTabChange(10);
					break;
				case 11:
					VeterinaryDiseaseReportDeduplicationService.Tab = VeterinaryDiseaseReportDeduplicationTabEnum.CaseLog;
					Tab = VeterinaryDiseaseReportDeduplicationTabEnum.CaseLog;
					OnTabChange(11);
					break;
			}
			await InvokeAsync(StateHasChanged);
		}

		protected async Task CancelReviewClicked()
		{
			try
			{
				var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null).ConfigureAwait(false);
				if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
				{
					//cancel search and user said yes
					_source?.Cancel();
					shouldRender = false;

                    var uri = Model.ReportType == VeterinaryReportTypeEnum.Avian ? $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication?showSelectedRecordsIndicator=true" : $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/LivestockDiseaseReportDeduplication?showSelectedRecordsIndicator=true";

					NavManager.NavigateTo(uri, true);
				}
				else
				{
					//cancel search but user said no so leave everything alone and cancel thread
					_source?.Cancel();
				}
			}
			catch (Exception ex)
			{
				Logger.LogError(ex, ex.Message);
				throw;
			}
		}

		#endregion
	}
}
