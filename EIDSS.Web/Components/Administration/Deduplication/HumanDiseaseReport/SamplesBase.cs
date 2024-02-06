using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using EIDSS.Web.ViewModels.Human;
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
    public class SamplesBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        public RadzenDataGrid<DiseaseReportSamplePageSampleDetailViewModel> samplesgrid;
        public RadzenDataGrid<DiseaseReportSamplePageSampleDetailViewModel> samplesgrid2;

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

        protected async Task OnCheckAllSamplesChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SamplesList, HumanDiseaseReportDeduplicationService.SamplesList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorSamplesList, "ValidSamples");
               
                TabSamplesValid();
            }
            else
            {
                await BindTabSamplesAsync();
            }
            //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples);
            HumanDiseaseReportDeduplicationService.SurvivorSamples = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples);
            //foreach (var item in HumanDiseaseReportDeduplicationService.samples2)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
        }

        protected async Task OnCheckAllSamples2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.SamplesList2, HumanDiseaseReportDeduplicationService.SamplesList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorSamplesList, "ValidSamples2");
               
                TabSamplesValid();
            }
            else
            {
                await BindTabSamplesAsync();
            }
            //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples2);
            HumanDiseaseReportDeduplicationService.SurvivorSamples = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples2);

            //foreach (var item in HumanDiseaseReportDeduplicationService.samples)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
        }

        protected async Task OnDataListSamplesSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SamplesList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SamplesList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SamplesList[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SamplesList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SamplesList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SamplesList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.SamplesList, HumanDiseaseReportDeduplicationService.SamplesList2, HumanDiseaseReportDeduplicationService.SurvivorSamplesList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SamplesList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SamplesList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.SamplesList2, HumanDiseaseReportDeduplicationService.SamplesList, HumanDiseaseReportDeduplicationService.SurvivorSamplesList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSamplesList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorSamplesList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorSamplesList[index].Value = value;
                    }
                }

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorSamplesList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.SamplesList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.SamplesList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = HumanDiseaseReportDeduplicationService.samples;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = HumanDiseaseReportDeduplicationService.samples2;
                //}
                HumanDiseaseReportDeduplicationService.chkCheckAllSamples = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;

                await EableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples);
                //foreach (var item in HumanDiseaseReportDeduplicationService.samples2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }

        protected async Task OnDataListSamples2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.SamplesList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.SamplesList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.SamplesList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SamplesList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.SamplesList, HumanDiseaseReportDeduplicationService.SamplesList2, HumanDiseaseReportDeduplicationService.SurvivorSamplesList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.SamplesList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.SamplesList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.SamplesList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.SamplesList, HumanDiseaseReportDeduplicationService.SamplesList2, HumanDiseaseReportDeduplicationService.SurvivorSamplesList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorSamplesList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorSamplesList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorSamplesList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorSamplesList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.SamplesList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.SamplesList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = HumanDiseaseReportDeduplicationService.samples;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = HumanDiseaseReportDeduplicationService.samples2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAllSamples = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;

                await EableDisableMergeButtonAsync();
                //HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails = CopyAllInList<DiseaseReportSamplePageSampleDetailViewModel>(HumanDiseaseReportDeduplicationService.Samples2); ;
                //foreach (var item in HumanDiseaseReportDeduplicationService.samples)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorSamplesDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorSampleHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }

        protected async Task OnSampleRowCheckChangeAsync(bool value, DiseaseReportSamplePageSampleDetailViewModel data, bool record2)
        {
            try
            {
                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true && HumanDiseaseReportDeduplicationService.SelectedSamples != null)
                        HumanDiseaseReportDeduplicationService.SelectedSamples.Remove(data);
                }
                else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true && HumanDiseaseReportDeduplicationService.SelectedSamples != null)
                        HumanDiseaseReportDeduplicationService.SelectedSamples.Remove(data);
                }
                else
                {
                    if (value == true)
                    {
                        if (HumanDiseaseReportDeduplicationService.SurvivorSamples != null)
                        {
                            var list = HumanDiseaseReportDeduplicationService.SurvivorSamples.Where(x => x.idfMaterial == data.idfMaterial).ToList();
                            if (list == null || list.Count == 0)
                            {
                                HumanDiseaseReportDeduplicationService.SurvivorSamples.Add(data);

                                if (record2 == false)
                                {
                                    AddTestsToSurvivorList(HumanDiseaseReportDeduplicationService.Tests.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                                }
                                else
                                {
                                    AddTestsToSurvivorList(HumanDiseaseReportDeduplicationService.Tests2.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                                }
                            }
                        }
                        else
                        {
                            HumanDiseaseReportDeduplicationService.SurvivorSamples = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                            HumanDiseaseReportDeduplicationService.SurvivorSamples.Add(data);

                            if (record2 == false)
                            {
                                AddTestsToSurvivorList(HumanDiseaseReportDeduplicationService.Tests.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                            }
                            else
                            {
                                AddTestsToSurvivorList(HumanDiseaseReportDeduplicationService.Tests2.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                            }
                        }

                        if (record2 == false)
                        {
                            //AddSampleToSelectedList(data, false);
                            AddTestsToSelectedList(HumanDiseaseReportDeduplicationService.Tests.Where(x => x.idfMaterial == data.idfMaterial).ToList(), false);
                        }
                        else
                        {
                            //AddSampleToSelectedList(data, true);
                            AddTestsToSelectedList(HumanDiseaseReportDeduplicationService.Tests2.Where(x => x.idfMaterial == data.idfMaterial).ToList(), true);
                        }
                    }
                    else
                    {
                        var list = HumanDiseaseReportDeduplicationService.SurvivorSamples.Where(x => x.idfMaterial == data.idfMaterial).ToList();
                        if (list != null)
                        {
                            HumanDiseaseReportDeduplicationService.SurvivorSamples.Remove(data);
                            //HumanDiseaseReportDeduplicationService.SurvivorSamplesCount = HumanDiseaseReportDeduplicationService.SurvivorSamples.Count;

                            if (record2 == false)
                            {
                                HumanDiseaseReportDeduplicationService.SurvivorTests = RemoveListFromList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.SurvivorTests, HumanDiseaseReportDeduplicationService.Tests.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                            }
                            else
                            {
                                HumanDiseaseReportDeduplicationService.SurvivorTests = RemoveListFromList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.SurvivorTests, HumanDiseaseReportDeduplicationService.Tests2.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                            }
                        }

                        if (record2 == false)
                        {
                            HumanDiseaseReportDeduplicationService.SelectedTests = RemoveListFromList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.SelectedTests, HumanDiseaseReportDeduplicationService.Tests.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                        }
                        else
                        {
                            HumanDiseaseReportDeduplicationService.SelectedTests2 = RemoveListFromList<DiseaseReportTestDetailForDiseasesViewModel>(HumanDiseaseReportDeduplicationService.SelectedTests2, HumanDiseaseReportDeduplicationService.Tests2.Where(x => x.idfMaterial == data.idfMaterial).ToList());
                        }
                    }

                    HumanDiseaseReportDeduplicationService.SamplesCount = HumanDiseaseReportDeduplicationService.Samples?.Count ?? 0;
                    HumanDiseaseReportDeduplicationService.SamplesCount2 = HumanDiseaseReportDeduplicationService.Samples2?.Count ?? 0;

                    HumanDiseaseReportDeduplicationService.SurvivorSamplesCount = HumanDiseaseReportDeduplicationService.SurvivorSamples.Count;
                    HumanDiseaseReportDeduplicationService.SurvivorTestsCount = HumanDiseaseReportDeduplicationService.SurvivorTests.Count;

                    HumanDiseaseReportDeduplicationService.chkCheckAllSamples = false;
                    HumanDiseaseReportDeduplicationService.chkCheckAllSamples2 = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

    }

}
