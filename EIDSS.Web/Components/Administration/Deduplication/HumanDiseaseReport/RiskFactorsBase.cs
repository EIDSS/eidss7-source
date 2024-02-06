using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class RiskFactorsBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SymptomsBase> Logger { get; set; }

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

        protected async Task OnCheckAllRiskFactorsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.RiskFactorsList, HumanDiseaseReportDeduplicationService.RiskFactorsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList, "ValidSymptoms");
                TabRiskFactorsValid();
                if (HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest;
                else
                {
                    if (HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis != HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest.idfsDiagnosis)
                    { 
                        HumanDiseaseReportDeduplicationService.RiskFactorsList2[0].Checked = true;
                        HumanDiseaseReportDeduplicationService.RiskFactorsList[0].Checked = false;
                    }
                }
            }
            else
            {
                await BindTabRiskFactorsAsync();
            }
        }

        protected async Task OnCheckAllRiskFactors2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.RiskFactorsList2, HumanDiseaseReportDeduplicationService.RiskFactorsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList, "ValidSymptoms");
                TabRiskFactorsValid();
                if (HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2;
                else
                {
                    if (HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis != HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.RiskFactorsList[0].Checked = true;
                        HumanDiseaseReportDeduplicationService.RiskFactorsList2[0].Checked = false;
                    }
                }
            }
            else
            {
                await BindTabRiskFactorsAsync();
            }
        }

        protected async Task OnDataListRiskFactorsSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Key == DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation && HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest;
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Key == DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation && HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2;
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList[index].Label;

                        //if (value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, "");
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == string.Empty)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, value);
                        //}

                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors2 = false;

                await EableDisableMergeButtonAsync();
            }
        }

        protected async Task OnDataListRiskFactors2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.RiskFactorsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Key == DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation && HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2;
                    }

                }
                else
                {
                    HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.RiskFactorsList[index].Key == DiseasereportDeduplicationRiskFactorsConstants.idfEpiObservation && HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest2.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsFlexFormRequest = HumanDiseaseReportDeduplicationService.RiskFactorsFlexFormRequest;
                    }

                }

                if (HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList[index].Label;

                        //if (value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, "");
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == null)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else if (HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value == string.Empty)
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(": ", ": " + value);
                        //}
                        //else
                        //{
                        //	HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Label = label.Replace(HumanDiseaseReportDeduplicationService.SurvivorNotificationList[index].Value, value);
                        //}

                        HumanDiseaseReportDeduplicationService.SurvivorRiskFactorsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllRiskFactors2 = false;

                await EableDisableMergeButtonAsync();
            }
        }
    }
}
