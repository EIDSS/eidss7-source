using EIDSS.Domain.ViewModels.Human;
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
    public class TestBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<AntibioticVaccineHistoryBase> Logger { get; set; }

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

        public RadzenDataGrid<DiseaseReportTestDetailForDiseasesViewModel> testgrid;
        public RadzenDataGrid<DiseaseReportTestDetailForDiseasesViewModel> testgrid2;

        public bool isLoading;

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

        protected async Task OnCheckAllTestsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.TestsList, HumanDiseaseReportDeduplicationService.TestsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorTestsList, "ValidTest");

                TabSamplesValid();
            }
            else
            {
                await BindTabTestsAsync();
            }
            HumanDiseaseReportDeduplicationService.SurvivorTests = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.Tests);
            //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails);
            //foreach (var item in HumanDiseaseReportDeduplicationService.testsDetails2)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;

        }

        protected async Task OnCheckAllTests2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.TestsList2, HumanDiseaseReportDeduplicationService.TestsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorTestsList, "ValidTest2");

                TabSamplesValid();
            }
            else
            {
                await BindTabTestsAsync();
            }
            HumanDiseaseReportDeduplicationService.SurvivorTests = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.Tests2);
            //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails2);
            //foreach (var item in HumanDiseaseReportDeduplicationService.testsDetails)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
        }

        protected async Task OnDataListTestsSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.TestsList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.TestsList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.TestsList[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.TestsList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.TestsList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.TestsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.TestsList[index].Key == DiseasereportDeduplicationTestConstants.TestCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNTestsConducted, HumanDiseaseReportDeduplicationService.TestsList, HumanDiseaseReportDeduplicationService.TestsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.TestsList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.TestsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.TestsList[index].Key == DiseasereportDeduplicationTestConstants.TestCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNTestsConducted, HumanDiseaseReportDeduplicationService.TestsList2, HumanDiseaseReportDeduplicationService.TestsList, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorTestsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorTestsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorTestsList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorTestsList[index].Value = value;
                    }
                }

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorTestsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.TestsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.TestsList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = HumanDiseaseReportDeduplicationService.testsDetails;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = HumanDiseaseReportDeduplicationService.testsDetails2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAll = false;
                HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

                await EableDisableMergeButtonAsync();
                //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails);
                //foreach (var item in HumanDiseaseReportDeduplicationService.testsDetails2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }

        protected async Task OnDataListTests2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.TestsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.TestsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.TestsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.TestsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.TestsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.TestsList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.TestsList[index].Key == DiseasereportDeduplicationTestConstants.TestCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNTestsConducted, HumanDiseaseReportDeduplicationService.TestsList, HumanDiseaseReportDeduplicationService.TestsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.TestsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.TestsList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.TestsList[index].Key == DiseasereportDeduplicationTestConstants.TestCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNTestsConducted, HumanDiseaseReportDeduplicationService.TestsList, HumanDiseaseReportDeduplicationService.TestsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorTestsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorTestsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorTestsList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorTestsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorTestsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.TestsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.TestsList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = HumanDiseaseReportDeduplicationService.testsDetails;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = HumanDiseaseReportDeduplicationService.testsDetails2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAll = false;
                HumanDiseaseReportDeduplicationService.chkCheckAll2 = false;

                await EableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorTestsDetails = CopyAllInList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.testsDetails2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.testsDetails)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorTestsDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorTestHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }

    }

}
