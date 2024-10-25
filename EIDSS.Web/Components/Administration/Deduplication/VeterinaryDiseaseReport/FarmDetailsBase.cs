#region Usings

using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class FarmDetailsBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
	{
		#region Dependencies

		[Inject]
		private ILogger<FarmDetailsBase> Logger { get; set; }

		#endregion

		#region Parameters

		[Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
		{
			_logger = Logger;

			// Wire up PersonDeduplication state container service
			VeterinaryDiseaseReportDeduplicationService.OnChange += async _ => await OnStateContainerChangeAsync();

			await base.OnInitializedAsync();
            await InvokeAsync(StateHasChanged);
		}

		private async Task OnStateContainerChangeAsync()
		{
			await InvokeAsync(StateHasChanged);
		}

		public void Dispose()
        {
            VeterinaryDiseaseReportDeduplicationService.OnChange -= VeterinaryDiseaseReportDeduplicationServiceOnOnChange;
        }

        private async void VeterinaryDiseaseReportDeduplicationServiceOnOnChange(string _)
        {
            await OnStateContainerChangeAsync().ConfigureAwait(false);
        }

        protected async Task OnCheckAllInfoChangeAsync(bool value)
		{
			if (value)
			{
				await CheckAllAsync(VeterinaryDiseaseReportDeduplicationService.InfoList, VeterinaryDiseaseReportDeduplicationService.InfoList2, true, false, VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList, "ValidInfo");
				TabFarmDetailsValid();
				DisableMergeButton = false;
			}
			else
			{
				await BindTabFarmDetailsAsync();
			}
		}

		protected async Task OnCheckAllInfo2ChangeAsync(bool value)
		{
			if (value)
			{
				await CheckAllAsync(VeterinaryDiseaseReportDeduplicationService.InfoList2, VeterinaryDiseaseReportDeduplicationService.InfoList, true, false, VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList, "ValidInfo");
				TabFarmDetailsValid();
				DisableMergeButton = false;
			}
			else
			{
				await BindTabFarmDetailsAsync();
			}
		}

		protected async Task OnDataListSelectionChangeAsync(bool args, int index)
		{
            if (args)
			{
				VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched())
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked = false;
			}
			else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked = false;
			}
			else
			{
                string value;
                var id = string.Empty;
                var indexId = 0;
                if (VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked)
				{
					VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked = false;
					value = VeterinaryDiseaseReportDeduplicationService.InfoList[index].Value;

                    switch (index)
                    {
						case 1: // Report Status Type Name
                            indexId = 31;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
							break;
						case 2: // Case Classification Name
                            indexId = 32;
							id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
							break;
                        case 7: // Report Type Name
                            indexId = 33;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                        case 9: // Disease Name
                            indexId = 34;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                    }
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked = true;
					value = VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Value;

                    switch (index)
                    {
                        case 1: // Report Status Type Name
                            indexId = 31;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 2: // Case Classification Name
                            indexId = 32;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 7: // Report Type Name
                            indexId = 33;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 9: // Disease Name
                            indexId = 34;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                    }
				}

				if (VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList is {Count: > 0})
				{
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList[index].Value = value;

					if (!string.IsNullOrEmpty(id))
                        VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList[indexId].Value = id;
                }

				VeterinaryDiseaseReportDeduplicationService.chkCheckAll = false;
				VeterinaryDiseaseReportDeduplicationService.chkCheckAll2 = false;

				TabFarmDetailsValid();
				await EnableDisableMergeButtonAsync();
            }
		}

		protected async Task OnDataList2SelectionChangeAsync(bool args, int index)
		{
            if (args)
			{
				VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked = true;
			}

			if (AllFieldValuePairsUnmatched())
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
				VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked = false;
			}
			else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
			{
				await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
				VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked = false;
			}
			else
			{
                string value;
                var id = string.Empty;
                var indexId = 0;
                if (VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Checked)
				{
					VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked = false;
					value = VeterinaryDiseaseReportDeduplicationService.InfoList2[index].Value;

                    switch (index)
                    {
                        case 1: // Report Status Type Name
                            indexId = 31;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 2: // Case Classification Name
                            indexId = 32;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 7: // Report Type Name
                            indexId = 33;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                        case 9: // Disease Name
                            indexId = 34;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList2[indexId].Value;
                            break;
                    }
				}
				else
				{
					VeterinaryDiseaseReportDeduplicationService.InfoList[index].Checked = true;
					value = VeterinaryDiseaseReportDeduplicationService.InfoList[index].Value;

                    switch (index)
                    {
                        case 1: // Report Status Type Name
                            indexId = 31;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                        case 2: // Case Classification Name
                            indexId = 32;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                        case 7: // Report Type Name
                            indexId = 33;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                        case 9: // Disease Name
                            indexId = 34;
                            id = VeterinaryDiseaseReportDeduplicationService.InfoList[indexId].Value;
                            break;
                    }
				}

				if (VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList is {Count: > 0})
				{
                    VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList[index].Value = value;

                    if (!string.IsNullOrEmpty(id))
                        VeterinaryDiseaseReportDeduplicationService.SurvivorInfoList[indexId].Value = id;
                }

				VeterinaryDiseaseReportDeduplicationService.chkCheckAll = false;
				VeterinaryDiseaseReportDeduplicationService.chkCheckAll2 = false;

				TabFarmDetailsValid();
				await EnableDisableMergeButtonAsync();
			}
		}

        #endregion
    }
}
