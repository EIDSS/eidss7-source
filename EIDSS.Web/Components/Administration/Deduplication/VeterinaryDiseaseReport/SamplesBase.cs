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
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class SamplesBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<SamplesBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<SampleGetListViewModel> SamplesGrid;
		protected RadzenDataGrid<SampleGetListViewModel> SamplesGrid2;


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
                LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesLabSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSampleTypeColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesFieldSampleIDColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSpeciesColumnHeading);
                BirdStatusColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesBirdStatusColumnHeading);
                CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesCollectionDateColumnHeading);
                SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSentDateColumnHeading);
                SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSentToOrganizationColumnHeading);
            }
            else
            {
                LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesLabSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSampleTypeColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesFieldSampleIDColumnHeading);
                AnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesAnimalIDColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSpeciesColumnHeading);
                CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesCollectionDateColumnHeading);
                SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSentDateColumnHeading);
                SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSentToOrganizationColumnHeading);
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

        protected async Task OnCheckAllSamplesChangeAsync(bool value)
        {
            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                UnCheckAll();
            }
            else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                UnCheckAll();
            }
            else
            {
                if (value == true)
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedSamples = CopyAllInList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Samples);
                    AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples);
                    //VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = AddListToList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples);

                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = CopyAllInList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.PensideTests);
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = CopyAllInList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.LabTests);
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = CopyAllInList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Interpretations);

                    AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests);
                    AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests);
                    AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations);
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedSamples = null;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples);

                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = null;
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = null;
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = null;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests);
                    VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests);
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations);

                    //await BindTabVaccinationAsync();
                }

                VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;
            }
        }

        protected async Task OnCheckAllSamples2ChangeAsync(bool value)
        {
            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                UnCheckAll();
            }
            else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                UnCheckAll();
            }
            else
            {
                if (value == true)
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = CopyAllInList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Samples2);
                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = AddListToList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples2);

                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = CopyAllInList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = CopyAllInList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.LabTests2);
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = CopyAllInList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Interpretations2);

                    AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                    AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2);
                    AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2);

                    //VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = AddListToList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                    //VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = AddListToList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests2);
                    //VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = AddListToList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations2);

                    //TabNotificationValid();
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = null;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples2);

                    VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = null;
                    VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = null;
                    VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = null;

                    VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests2);
                    VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests2);
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations2);

                    //await BindTabVaccinationAsync();
                }

                VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;
            }
        }

        protected async Task OnSampleRowCheckChangeAsync(bool value, SampleGetListViewModel data, bool record2)
        {
            try
            {
                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true)
                        VeterinaryDiseaseReportDeduplicationService.SelectedSamples.Remove(data);
                }
                else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true)
                        VeterinaryDiseaseReportDeduplicationService.SelectedSamples.Remove(data);
                }
                else
                {
                    if (value == true)
                    {
                        if (VeterinaryDiseaseReportDeduplicationService.SurvivorSamples != null)
                        {
                            var list = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Where(x => x.SampleID == data.SampleID).ToList();
                            if (list == null || list.Count == 0) 
                            { 
                                VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Add(data);

                                if (record2 == false)
                                {
                                    AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == data.SampleID).ToList());
                                    AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == data.SampleID).ToList());
                                    AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == data.SampleID).ToList());
                                }
                                else
                                {
                                    AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                    AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                    AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == data.SampleID).ToList());
                                }
                            }
                        }
                        else
                        {
                            VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = new List<SampleGetListViewModel>();
                            VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Add(data);

                            if (record2 == false)
                            {
                                AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == data.SampleID).ToList());
                                AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == data.SampleID).ToList());
                                AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == data.SampleID).ToList());
                            }
                            else
                            {
                                AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == data.SampleID).ToList());
                            }
                        }

                        if (record2 == false) 
                        {
                            //AddSampleToSelectedList(data, false);
                            AddPensideTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == data.SampleID).ToList(), false);
                            AddLabTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == data.SampleID).ToList(), false);
                            AddInterpretationsToSelectedList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == data.SampleID).ToList(), false);
                        }
                        else 
                        {
                            //AddSampleToSelectedList(data, true);
                            AddPensideTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == data.SampleID).ToList(), true);
                            AddLabTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == data.SampleID).ToList(), true);
                            AddInterpretationsToSelectedList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == data.SampleID).ToList(), true);
                        }
                    }
                    else
                    {
                        var list = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Where(x => x.SampleID == data.SampleID).ToList();
                        if (list != null) { 
                            VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Remove(data);
                            //VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;

                            if (record2 == false)
                            {
                                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == data.SampleID).ToList());
                                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == data.SampleID).ToList());
                                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == data.SampleID).ToList());
                            }
                            else
                            {
                                VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == data.SampleID).ToList());
                                VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == data.SampleID).ToList());
                            }
                        }

                        if (record2 == false)
                        {
                            VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == data.SampleID).ToList());
                            VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == data.SampleID).ToList());
                            VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == data.SampleID).ToList());
                        }
                        else
                        {
                            VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2, VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == data.SampleID).ToList());
                            VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2, VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == data.SampleID).ToList());
                            VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2, VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == data.SampleID).ToList());
                        }
                    }

                    VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;

                    VeterinaryDiseaseReportDeduplicationService.chkCheckAllSamples = false;
                    VeterinaryDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

    }
}
