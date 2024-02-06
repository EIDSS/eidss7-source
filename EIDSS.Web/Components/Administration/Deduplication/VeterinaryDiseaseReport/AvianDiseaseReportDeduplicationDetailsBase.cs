using EIDSS.ClientLibrary.ApiClients.Veterinary;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using EIDSS.Domain.Enumerations;
using System.Threading.Tasks;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using System.Threading;
using Microsoft.Extensions.Localization;
using Radzen.Blazor;
using System;
using EIDSS.Domain.RequestModels.Veterinary;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using EIDSS.Web.Components.CrossCutting;
using Newtonsoft.Json;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class AvianDiseaseReportDeduplicationDetailsBase : VeterinaryDiseaseReportDeduplicationBaseComponent
	{
		#region Dependencies

		[Inject]
		private IVeterinaryClient VeterinaryClient { get; set; }

		[Inject]
		private ILogger<AvianDiseaseReportDeduplicationDetailsBase> Logger { get; set; }

		#endregion

		#region request
		[Parameter]
		public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		//[Parameter]
		//public AvianDiseaseReportDeduplicationTabEnum Tab { get; set; }

		[Parameter] public AvianDiseaseReportDeduplicationTabEnum Tab { get; set; }
		#endregion

		#region Protected and Public Variables

		protected RadzenTemplateForm<VeterinaryDiseaseReportDeduplicationDetailsViewModel> form;

		protected bool shouldRender = true;


		#endregion

		#region Private Variables

		private CancellationTokenSource source;
		protected CancellationToken token;

		#endregion

		#region Protected and Public Methods

		protected override async Task OnInitializedAsync()
		{
			// reset the cancellation token
			source = new CancellationTokenSource();
			token = source.Token;

			_logger = Logger;

			authenticatedUser = _tokenService.GetAuthenticatedUser();

			// Wire up FarmDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

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

		#endregion

		#region Details

		public void OnChange(int index)
		{
			Tab = (AvianDiseaseReportDeduplicationTabEnum)index;
			OnAvianTabChange(index);
		}

		public void OnAvianTabChange(int index)
		{
			switch (index)
			{
				case 0:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmDetails;
					ShowPreviousButton = false;
					ShowNextButton = true;
					break;
				case 1:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Notification;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 2:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmInventory;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 3:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 4:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 5:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Vaccination;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 6:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Samples;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 7:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.PensideTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 8:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.LabTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case 9:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.CaseLog;
					ShowPreviousButton = true;
					ShowNextButton = false;
					break;
			}

			VeterinaryDiseaseReportDeduplicationService.TabChangeIndicator = true;
		}

		public void NextClicked()
		{
			switch (Tab)
			{
				case AvianDiseaseReportDeduplicationTabEnum.FarmDetails:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Notification;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.Notification:
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmInventory;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.FarmInventory:
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation:
					Tab = AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Vaccination;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.Vaccination:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Samples;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.Samples:
					Tab = AvianDiseaseReportDeduplicationTabEnum.PensideTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.PensideTests:
					Tab = AvianDiseaseReportDeduplicationTabEnum.LabTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.LabTests:
					Tab = AvianDiseaseReportDeduplicationTabEnum.CaseLog;
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
				case AvianDiseaseReportDeduplicationTabEnum.Notification:
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmDetails;
					ShowPreviousButton = false;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.FarmInventory:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Notification;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation:
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmInventory;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation:
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.Vaccination:
					Tab = AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.Samples:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Vaccination;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.PensideTests:
					Tab = AvianDiseaseReportDeduplicationTabEnum.Samples;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.LabTests:
					Tab = AvianDiseaseReportDeduplicationTabEnum.PensideTests;
					ShowPreviousButton = true;
					ShowNextButton = true;
					break;
				case AvianDiseaseReportDeduplicationTabEnum.CaseLog:
					Tab = AvianDiseaseReportDeduplicationTabEnum.LabTests;
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
                    source?.Cancel();
                    shouldRender = false;
                    var uri = string.Empty;
                    if (Model.ReportType == VeterinaryReportTypeEnum.Livestock)
                        uri = $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/LivestockDiseaseReportDeduplication?showSelectedRecordsIndicator=true";
                    else
                        uri = $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication?showSelectedRecordsIndicator=true";

                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
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
			if (Model == null)
			{
				Model = new VeterinaryDiseaseReportDeduplicationDetailsViewModel()
				{
					LeftVeterinaryDiseaseReportID = VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID,
					RightVeterinaryDiseaseReportID = VeterinaryDiseaseReportDeduplicationService.VeterinaryDiseaseReportID2,
				};
			}

			await FillDeduplicationDetailsAsync(Model, Model.LeftVeterinaryDiseaseReportID, Model.RightVeterinaryDiseaseReportID);

			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);
		}

		private async Task OnStateContainerChangeAsync(string property)
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
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmDetails;
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmDetails;
					OnTabChange(0);
					break;
				case 1:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Notification;
					Tab = AvianDiseaseReportDeduplicationTabEnum.Notification;
					OnTabChange(1);
					break;
				case 2:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmInventory;
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmInventory;
					OnTabChange(2);
					break;
				case 3:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					Tab = AvianDiseaseReportDeduplicationTabEnum.FarmEpiInformation;
					OnTabChange(3);
					break;
				case 4:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					Tab = AvianDiseaseReportDeduplicationTabEnum.SpeciesInvestigation;
					OnTabChange(4);
					break;
				case 5:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Vaccination;
					Tab = AvianDiseaseReportDeduplicationTabEnum.Vaccination;
					OnTabChange(5);
					break;
				case 6:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.Samples;
					Tab = AvianDiseaseReportDeduplicationTabEnum.Samples;
					OnTabChange(6);
					break;
				case 7:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.PensideTests;
					Tab = AvianDiseaseReportDeduplicationTabEnum.PensideTests;
					OnTabChange(7);
					break;
				case 8:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.LabTests;
					Tab = AvianDiseaseReportDeduplicationTabEnum.LabTests;
					OnTabChange(8);
					break;
				case 9:
					VeterinaryDiseaseReportDeduplicationService.AvianTab = AvianDiseaseReportDeduplicationTabEnum.CaseLog;
					Tab = AvianDiseaseReportDeduplicationTabEnum.CaseLog;
					OnTabChange(9);
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
					source?.Cancel();
					shouldRender = false;

					var uri = string.Empty;
					if (Model.ReportType == VeterinaryReportTypeEnum.Avian)
						uri = $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/AvianDiseaseReportDeduplication?showSelectedRecordsIndicator=true";
					else
						uri = $"{NavManager.BaseUri}Administration/Deduplication/VeterinaryDiseaseReportDeduplication/LivestockDiseaseReportDeduplication?showSelectedRecordsIndicator=true";

					NavManager.NavigateTo(uri, true);
				}
				else
				{
					//cancel search but user said no so leave everything alone and cancel thread
					source?.Cancel();
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

