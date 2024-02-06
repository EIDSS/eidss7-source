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
    public class SymptomsBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        protected async Task OnCheckAllSymptomsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SymptomsList, HumanDiseaseReportDeduplicationService.SymptomsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList, "ValidSymptoms");
                TabSymptomsValid();
                if (HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfsDiagnosis)
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest;
                else
                {
                    if (HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfsDiagnosis != HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SymptomsList2[idfCSObservation].Checked = true;
                        HumanDiseaseReportDeduplicationService.SymptomsList[idfCSObservation].Checked = false;
                    }
                }
            }
            else
            {
                await BindTabSymptomsAsync();
            }
        }

        protected async Task OnCheckAllSymptoms2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SymptomsList2, HumanDiseaseReportDeduplicationService.SymptomsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList, "ValidSymptoms");
                TabSymptomsValid();
                if (HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest.idfsDiagnosis == HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfsDiagnosis)
                    HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2;
                else
                {
                    if (HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2.idfsDiagnosis != HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest.idfsDiagnosis)
                    {
                        HumanDiseaseReportDeduplicationService.SymptomsList[idfCSObservation].Checked = true;
                        HumanDiseaseReportDeduplicationService.SymptomsList2[idfCSObservation].Checked = false;
                    }
                }
            }
            else
            {
                await BindTabSymptomsAsync();
            }
        }

        protected async Task OnDataListSymptomsSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SymptomsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.InitialCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsInitialCaseStatus, HumanDiseaseReportDeduplicationService.SymptomsList, HumanDiseaseReportDeduplicationService.SymptomsList2, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList);
                    }
                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.idfCSObservation)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest;
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SymptomsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.InitialCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsInitialCaseStatus, HumanDiseaseReportDeduplicationService.SymptomsList2, HumanDiseaseReportDeduplicationService.SymptomsList, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList);
                    }
                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.idfCSObservation)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2;
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSymptomsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSymptomsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorSymptomsList[index].Label;

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

                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms2 = false;

                await EableDisableMergeButtonAsync();
            }
        }

        protected async Task OnDataListSymptoms2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SymptomsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SymptomsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.InitialCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsInitialCaseStatus, HumanDiseaseReportDeduplicationService.SymptomsList2, HumanDiseaseReportDeduplicationService.SymptomsList, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList);
                    }
                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.idfCSObservation)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest2;
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SymptomsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SymptomsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.InitialCaseStatus)
                    {
                        SelectAndUnSelectIDfield(idfsInitialCaseStatus, HumanDiseaseReportDeduplicationService.SymptomsList, HumanDiseaseReportDeduplicationService.SymptomsList2, HumanDiseaseReportDeduplicationService.SurvivorSymptomsList);
                    }
                    if (HumanDiseaseReportDeduplicationService.SymptomsList[index].Key == DiseasereportDeduplicationSymptomsConstants.idfCSObservation)
                    {
                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsFlexFormRequest = HumanDiseaseReportDeduplicationService.SymptomsFlexFormRequest;
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSymptomsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSymptomsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorSymptomsList[index].Label;

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

                        HumanDiseaseReportDeduplicationService.SurvivorSymptomsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.NotificationList2.Where(s => s.Checked == true).Select(s => s.Index);

                HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllSymptoms2 = false;

                await EableDisableMergeButtonAsync();
            }
        }
    }
}
