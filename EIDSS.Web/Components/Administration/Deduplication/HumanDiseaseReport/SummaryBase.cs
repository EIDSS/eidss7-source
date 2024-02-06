using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class SummaryBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SummaryBase> Logger { get; set; }

        #endregion

        #region Parameters
        public HumanDiseaseReportDeduplicationDetailsViewModel Model { get; set; }

        #endregion

        #region Protected and Public Members
        protected RadzenRadioButtonList<int?> rboRecord;
        protected int? value { get; set; }
        protected RadzenRadioButtonList<int?> rboRecord2;
        protected int? value2 { get; set; }
        protected bool chkCheckAll { get; set; }
        protected bool chkCheckAll2 { get; set; }


        protected RadzenCheckBoxList<int> rcblInfo;
        protected RadzenCheckBoxList<int> rcblInfo2;

        #endregion

        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;


        #endregion

        #endregion

        protected override async Task OnInitializedAsync()
        {
            // Wire up PersonDeduplication state container service
            HumanDiseaseReportDeduplicationService.OnChange += async (property) => await OnStateContainerChangeAsync(property);

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

                HumanDiseaseReportDeduplicationService.OnChange -= async (property) => await OnStateContainerChangeAsync(property);

            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task OnCheckAllSummaryChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList, "ValidSummary");
                TabSummaryValid();
            }
            else
            {
                await BindTabSummaryAsync();
            }
        }

        protected async Task OnCheckAllSummary2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorSummaryList, "ValidInfo");
                TabSummaryValid();
            }
            else
            {
                await BindTabSummaryAsync();
            }
        }

        protected async Task OnDataListSummarySelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SummaryList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SummaryList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SummaryList[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SummaryList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SummaryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.PatientStatus)
                    //{
                    //    SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.SentByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SummaryList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.PatientStatus)
                    //{
                    //    SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.SentByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSummaryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSummaryList.Count > 0)
                    {
                        //label = HumanDiseaseReportDeduplicationService.SurvivorSummaryList[index].Label;

                        HumanDiseaseReportDeduplicationService.SurvivorSummaryList[index].Value = value;
                    }
                }

                HumanDiseaseReportDeduplicationService.chkCheckAll = false;
                HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

                await EableDisableMergeButtonAsync();
            }
        }

        protected async Task OnDataListSummary2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked = false;

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SummaryList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SummaryList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SummaryList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.PatientStatus)
                    //{
                    //    SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.SentByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SummaryList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SummaryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.Disease)
                    {
                        SelectAndUnSelectIDfield(idfsFinalDiagnosis, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    }
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.PatientStatus)
                    //{
                    //    SelectAndUnSelectIDfield(idfsHospitalizationStatus, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByOffice, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(ReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.ReceivedByPerson)
                    //{
                    //    SelectAndUnSelectIDfield(idfReceivedByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                    //else if (HumanDiseaseReportDeduplicationService.SummaryList[index].Key == DiseasereportDeduplicationSummaryConstants.SentByOffice)
                    //{
                    //    SelectAndUnSelectIDfield(idfSentByOffice, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(SentByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //    SelectAndUnSelectIDfield(idfSentByPerson, HumanDiseaseReportDeduplicationService.SummaryList, HumanDiseaseReportDeduplicationService.SummaryList2, HumanDiseaseReportDeduplicationService.SurvivorSummaryList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSummaryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSummaryList.Count > 0)
                    {
                        //label = HumanDiseaseReportDeduplicationService.SurvivorSummaryList[index].Label;

                        HumanDiseaseReportDeduplicationService.SurvivorSummaryList[index].Value = value;
                    }
                }

                HumanDiseaseReportDeduplicationService.chkCheckAll = false;
                HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

                await EableDisableMergeButtonAsync();
            }
        }
    }
}
