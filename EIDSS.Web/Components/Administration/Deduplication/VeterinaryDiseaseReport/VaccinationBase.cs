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
    public class VaccinationBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<VaccinationBase> Logger { get; set; }

		#endregion

		#region Parameters
		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

		#endregion

		#region Protected and Public Members

		protected RadzenDataGrid<VaccinationGetListViewModel> VaccinationGrid;
		protected RadzenDataGrid<VaccinationGetListViewModel> VaccinationGrid2;

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

        protected async Task OnCheckAllVaccinationChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations = CopyAllInList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Vaccinations);
					AddVaccinationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Vaccinations);
					//VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Vaccinations);
					//TabNotificationValid();
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations = RemoveListFromList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations, VeterinaryDiseaseReportDeduplicationService.Vaccinations);

					//await BindTabVaccinationAsync();
				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
			}
		}

        protected async Task OnCheckAllVaccination2ChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 = CopyAllInList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Vaccinations2);
					AddVaccinationsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.Vaccinations2);
					//VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.Vaccinations2);
					//TabNotificationValid();
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations = RemoveListFromList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations, VeterinaryDiseaseReportDeduplicationService.Vaccinations2);

					//await BindTabVaccinationAsync();
				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
			}
		}

		protected void AddVaccinationsToSurvivorList(IList<VaccinationGetListViewModel> listToAdd)
		{
			foreach (var row in listToAdd)
			{
				var list = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Where(x => x.VaccinationID == row.VaccinationID).ToList();
				if (list == null || list.Count == 0)
					VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Add(row);
			}

			VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
		}

		protected async Task OnVaccinationRowCheckChangeAsync(bool value, VaccinationGetListViewModel data, bool record2)
		{
			try
			{
				if (AllFieldValuePairsUnmatched() == true)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations.Remove(data);
				}
				else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations.Remove(data);
				}
				else
				{
					if (value == true)
					{
						if (VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations != null)
						{
							var list = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Where(x => x.VaccinationID == data.VaccinationID).ToList();
							if (list == null || list.Count == 0)
								VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Add(data);
						}
						else
						{
							VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations = new List<VaccinationGetListViewModel>();
							VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Add(data);
						}

						//VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;

						//if (record2 == false)
						//{
						//	if (VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations != null)
						//	{
						//		var list = VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations.Where(x => x.VaccinationID == data.VaccinationID).ToList();
						//		if (list == null || list.Count == 0)
						//			VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations.Add(data);
						//	}
						//	else
						//	{
						//		VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations = AddRowToList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations, data);
						//	}
						//}
						//else
						//{
						//	if (VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 != null)
						//	{
						//		var list = VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2.Where(x => x.VaccinationID == data.VaccinationID).ToList();
						//		if (list == null || list.Count == 0)
						//			VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2.Add(data);
						//	}
						//	else
						//	{
						//		VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2 = AddRowToList<VaccinationGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedVaccinations2, data);
						//	}
						//}
					}
					else
					{
						var list = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Where(x => x.VaccinationID == data.VaccinationID).ToList();
						if (list != null)
							VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Remove(data);

						//VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
					}

					VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinationsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}
	}
}

