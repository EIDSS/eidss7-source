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
    public class NotificationBase: VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
    {
		#region Globals

		#region Dependencies

		[Inject]
        private ILogger<NotificationBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public VeterinaryDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        #endregion

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

        protected async Task OnDataListNotificationSelectionChangeAsync(bool args, int index)
        {
            if (args)
            {
                VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched())
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
            }
            else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
            }
            else
            {
                string value;
                if (VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked)
                {
                    VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
                    value = VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Value;
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked = true;
                    value = VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Value;
                }

                if (VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList is {Count: > 0})
                {
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value = value;
                }

                await EnableDisableMergeButtonAsync();
            }
        }

        protected async Task OnDataListNotification2SelectionChangeAsync(bool args, int index)
        {
            if (args)
            {
                VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched())
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
            }
            else if (VeterinaryDiseaseReportDeduplicationService.RecordSelection == 0 && VeterinaryDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked = false;
            }
            else
            {
                string value;
                if (VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Checked)
                {
                    VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked = false;
                    value = VeterinaryDiseaseReportDeduplicationService.NotificationList2[index].Value;
                }
                else
                {
                    VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Checked = true;
                    value = VeterinaryDiseaseReportDeduplicationService.NotificationList[index].Value;
                }

                if (VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList is {Count: > 0})
                {
                    VeterinaryDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value = value;
                }

                await EnableDisableMergeButtonAsync();
            }
        }

        #endregion
    }
}
