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
    public class CaseLogBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Dependencies

        [Inject]
        private ILogger<CaseLogBase> Logger { get; set; }

        #endregion

        #region Parameters
        [Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<CaseLogGetListViewModel> CaseLogGrid;
        protected RadzenDataGrid<CaseLogGetListViewModel> CaseLogGrid2;




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

        protected async Task OnCheckAllCaseLogChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs = CopyAllInList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.CaseLogs);
					AddCaseLogsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.CaseLogs);
					//VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs = CopyAllInList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.CaseLogs);
					//TabNotificationValid();
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs = null;
					VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs = RemoveListFromList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs, VeterinaryDiseaseReportDeduplicationService.CaseLogs);

					//await BindTabCaseLogAsync();
				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Count;
			}
		}


		protected async Task OnCheckAllCaseLog2ChangeAsync(bool value)
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
					VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 = CopyAllInList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.CaseLogs2);
					AddCaseLogsToSurvivorList(VeterinaryDiseaseReportDeduplicationService.CaseLogs2);
					//VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs = CopyAllInList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.CaseLogs2);
					//TabNotificationValid();
				}
				else
				{
						VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 = null;
						VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs = RemoveListFromList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs, VeterinaryDiseaseReportDeduplicationService.CaseLogs2);

						//await BindTabCaseLogAsync();
				}

				VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Count;
			}
		}

		protected void AddCaseLogsToSurvivorList(IList<CaseLogGetListViewModel> listToAdd)
		{
			foreach (var row in listToAdd)
			{
				var list = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Where(x => x.DiseaseReportLogID == row.DiseaseReportLogID).ToList();
				if (list == null || list.Count == 0)
					VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Add(row);
			}
		}

		protected async Task OnCaseLogRowCheckChangeAsync(bool value, CaseLogGetListViewModel data, bool record2)
		{
			try
			{
				if (AllFieldValuePairsUnmatched() == true)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs.Remove(data);
				}
				else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
				{
					await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
					if (value == true)
						VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs.Remove(data);
				}
				else
				{
					if (value == true)
					{
						if (VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs != null)
						{
							var list = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Where(x => x.DiseaseReportLogID == data.DiseaseReportLogID).ToList();
							if (list == null || list.Count == 0)
								VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Add(data);
						}
						else
						{
							VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs = new List<CaseLogGetListViewModel>();
							VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Add(data);
						}

						//if (record2 == false)
						//{
						//	if (VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs != null)
						//	{
						//		var list = VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs.Where(x => x.DiseaseReportLogID == data.DiseaseReportLogID).ToList();
						//		if (list == null || list.Count == 0)
						//			VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs.Add(data);
						//	}
						//	else
						//	{
						//		VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs = AddRowToList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs, data);
						//	}
						//}
						//else
						//{
						//	if (VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 != null)
						//	{
						//		var list = VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2.Where(x => x.DiseaseReportLogID == data.DiseaseReportLogID).ToList();
						//		if (list == null || list.Count == 0)
						//			VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2.Add(data);
						//	}
						//	else
						//	{
						//		VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2 = AddRowToList<CaseLogGetListViewModel>(VeterinaryDiseaseReportDeduplicationService.SelectedCaseLogs2, data);
						//	}
						//}
					}
					else
					{
						var list = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Where(x => x.DiseaseReportLogID == data.DiseaseReportLogID).ToList();
						if (list != null)
							VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Remove(data);
					}

					VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogsCount = VeterinaryDiseaseReportDeduplicationService.SurvivorCaseLogs.Count;
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex.Message);
			}
		}
	}
}