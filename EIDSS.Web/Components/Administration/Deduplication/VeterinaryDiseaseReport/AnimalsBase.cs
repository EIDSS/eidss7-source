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
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class AnimalsBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<AnimalsBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<AnimalGetListViewModel> AnimalsGrid;
		protected RadzenDataGrid<AnimalGetListViewModel> AnimalsGrid2;

		#endregion

		#region Private Member Variables

		private CancellationTokenSource source;
		private CancellationToken token;

		#endregion

		protected override async Task OnInitializedAsync()
		{
			// Wire up PersonDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);
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

        protected async Task OnCheckAllAnimalsChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals = CopyAllInList<AnimalGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Animals);
					AddAnimalsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Animals);

					VeterinaryDiseaseReportDeduplicationService.SelectedSamples = CopyAllInList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Samples);
					AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples);

					VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = CopyAllInList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.PensideTests);
					VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = CopyAllInList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.LabTests);
					VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = CopyAllInList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Interpretations);

					AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests);
					AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests);
					AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations);
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals = RemoveListFromList<AnimalGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals, VeterinaryDiseaseReportDeduplicationService.Animals);

					VeterinaryDiseaseReportDeduplicationService.SelectedSamples = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples);

					VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = null;
					VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = null;
					VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = null;

					VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests);
					VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests);
					VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations);

				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorAnimalsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;
			}
		}

		protected async Task OnCheckAllAnimals2ChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 = CopyAllInList<AnimalGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Animals2);
					AddAnimalsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Animals2);

					VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = CopyAllInList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Samples2);
					VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = AddListToList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples2);

					VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = CopyAllInList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
					VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = CopyAllInList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.LabTests2);
					VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = CopyAllInList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Interpretations2);

					AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2);
					AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2);
					AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2);
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals = RemoveListFromList<AnimalGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals, VeterinaryDiseaseReportDeduplicationService.Animals2);

					VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples2);

					VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = null;
					VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = null;
					VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = null;

					VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests2);
					VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests2);
					VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations2);
				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorAnimalsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
				VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;
			}
		}

		protected void AddAnimalsToSurvivorList(IList<AnimalGetListViewModel> listToAdd)
		{
			foreach (var row in listToAdd)
			{
				var list = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Where(x => x.AnimalID == row.AnimalID).ToList();
				if (list == null || list.Count == 0)
					VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Add(row);
			}

			VeterinaryDiseaseReportDeduplicationService.SurvivorAnimalsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Count;
		}

		protected void AddAnimalToSelectedList(AnimalGetListViewModel data, bool record2)
		{
			if (record2 == false)
			{
				if (VeterinaryDiseaseReportDeduplicationService.SelectedAnimals == null)
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals = new List<AnimalGetListViewModel>();

				var list = VeterinaryDiseaseReportDeduplicationService.SelectedAnimals.Where(x => x.AnimalID == data.AnimalID).ToList();
				if (list == null || list.Count == 0)
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals.Add(data);
			}
			else
			{
				if (VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 == null)
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2 = new List<AnimalGetListViewModel>();

				var list = VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2.Where(x => x.AnimalID == data.AnimalID).ToList();
				if (list == null || list.Count == 0)
					VeterinaryDiseaseReportDeduplicationService.SelectedAnimals2.Add(data);
			}
		}

		protected void AddSamplesToSelectedList(IList<SampleGetListViewModel> listToAdd, bool record2)
		{
			foreach (var row in listToAdd)
			{
				if (record2 == false)
				{
					if (VeterinaryDiseaseReportDeduplicationService.SelectedSamples == null)
						VeterinaryDiseaseReportDeduplicationService.SelectedSamples = new List<SampleGetListViewModel>();

					var list = VeterinaryDiseaseReportDeduplicationService.SelectedSamples.Where(x => x.SampleID == row.SampleID).ToList();
					if (list == null || list.Count == 0)
						VeterinaryDiseaseReportDeduplicationService.SelectedSamples.Add(row);
				}
				else
				{
					if (VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 == null)
						VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = new List<SampleGetListViewModel>();

					var list = VeterinaryDiseaseReportDeduplicationService.SelectedSamples2.Where(x => x.SampleID == row.SampleID).ToList();
					if (list == null || list.Count == 0)
						VeterinaryDiseaseReportDeduplicationService.SelectedSamples2.Add(row);
				}
			}
		}

		protected async Task OnAnimalRowCheckChangeAsync(bool value, AnimalGetListViewModel data, bool record2)
		{
			try
			{
				if (AllFieldValuePairsUnmatched() == true)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedAnimals.Remove(data);
				}
				else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedAnimals.Remove(data);
				}
				else
				{
					if (value == true)
					{
						if (VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals != null)
						{
							var list = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Where(x => x.AnimalID == data.AnimalID).ToList();
							if (list == null || list.Count == 0)
								VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Add(data);

							if (record2 == false)
							{
								AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
							else
							{
								AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
						}
						else
						{
							VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals = new List<AnimalGetListViewModel>();
							VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Add(data);

							if (record2 == false)
							{
								AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
							else
							{
								AddSamplesToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Samples2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddPensideTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddLabTestsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								AddInterpretationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
						}

						long SampleID = 0;
						if (record2 == false)
						{
							//AddAnimalToSelectedList(data, false);
							var list = VeterinaryDiseaseReportDeduplicationService.Samples.Where(x => x.AnimalID == data.AnimalID).ToList();
							if (list != null || list.Count > 0)
							{
								SampleID = list.FirstOrDefault().SampleID;
								AddSamplesToSelectedList(list, false);
								AddPensideTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.SampleID == SampleID).ToList(), false);
								AddLabTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.SampleID == SampleID).ToList(), false);
								AddInterpretationsToSelectedList(VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.SampleID == SampleID).ToList(), false);
							}
						}
						else
						{
							//AddAnimalToSelectedList(data, true);
							var list = VeterinaryDiseaseReportDeduplicationService.Samples2.Where(x => x.AnimalID == data.AnimalID).ToList();
							if (list != null || list.Count > 0)
							{
								SampleID = list.FirstOrDefault().SampleID;
								AddSamplesToSelectedList(list, true);
								AddPensideTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.SampleID == SampleID).ToList(), true);
								AddLabTestsToSelectedList(VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.SampleID == SampleID).ToList(), true);
								AddInterpretationsToSelectedList(VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.SampleID == SampleID).ToList(), true);
							}
						}
					}
					else
					{
						var list = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Where(x => x.AnimalID == data.AnimalID).ToList();
						if (list != null)
						{
							VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Remove(data);

							if (record2 == false)
							{
								VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
							else
							{
								VeterinaryDiseaseReportDeduplicationService.SurvivorSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorSamples, VeterinaryDiseaseReportDeduplicationService.Samples2.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
								VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.AnimalID == data.AnimalID).ToList());
							}
						}

						if (record2 == false)
						{
							VeterinaryDiseaseReportDeduplicationService.SelectedSamples = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedSamples, VeterinaryDiseaseReportDeduplicationService.Samples.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests, VeterinaryDiseaseReportDeduplicationService.PensideTests.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedLabTests = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedLabTests, VeterinaryDiseaseReportDeduplicationService.LabTests.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations, VeterinaryDiseaseReportDeduplicationService.Interpretations.Where(x => x.AnimalID == data.AnimalID).ToList());
						}
						else
						{
							VeterinaryDiseaseReportDeduplicationService.SelectedSamples2 = RemoveListFromList<SampleGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedSamples2, VeterinaryDiseaseReportDeduplicationService.Samples2.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2 = RemoveListFromList<PensideTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedPensideTests2, VeterinaryDiseaseReportDeduplicationService.PensideTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2 = RemoveListFromList<LaboratoryTestGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedLabTests2, VeterinaryDiseaseReportDeduplicationService.LabTests2.Where(x => x.AnimalID == data.AnimalID).ToList());
							VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2 = RemoveListFromList<LaboratoryTestInterpretationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedInterpretations2, VeterinaryDiseaseReportDeduplicationService.Interpretations2.Where(x => x.AnimalID == data.AnimalID).ToList());
						}
					}

					VeterinaryDiseaseReportDeduplicationService.SurvivorAnimalsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorAnimals.Count;
					VeterinaryDiseaseReportDeduplicationService.SurvivorSamplesCount = VeterinaryDiseaseReportDeduplicationService.SurvivorSamples.Count;
					VeterinaryDiseaseReportDeduplicationService.SurvivorPensideTestsCount = VeterinaryDiseaseReportDeduplicationService.PensideTests.Count;
					VeterinaryDiseaseReportDeduplicationService.SurvivorLabTestsCount = VeterinaryDiseaseReportDeduplicationService.LabTests.Count;
					VeterinaryDiseaseReportDeduplicationService.SurvivorInterpretationsCount = VeterinaryDiseaseReportDeduplicationService.Interpretations.Count;
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}


	}
}
