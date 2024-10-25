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
    public class AntibioticVaccineHistoryBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        protected async Task OnCheckAllAntibioticVaccineHistoryChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.AntibioticHistoryList, HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList, "ValidAntibioticHistory");
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.VaccineHistoryList, HumanDiseaseReportDeduplicationService.VaccineHistoryList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList, "ValidVaccineHistory");
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.ClinicalNotesList, HumanDiseaseReportDeduplicationService.ClinicalNotesList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList, "ValidClinicalNotes");
                TabAntibioticVaccineHistoryValid();
            }
            else
            {
                await BindTabAntibioticVaccineHistoryAsync();
            }
            HumanDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.Vaccinations);
            //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory2)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorAntibiotics = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.Antibiotics);
            //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory2)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
        }

        protected async Task OnCheckAllAntibioticVaccineHistory2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, HumanDiseaseReportDeduplicationService.AntibioticHistoryList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList, "ValidAntibioticVaccineHistory2");
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.VaccineHistoryList2, HumanDiseaseReportDeduplicationService.VaccineHistoryList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList, "ValidVaccineHistory2");
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.ClinicalNotesList2, HumanDiseaseReportDeduplicationService.ClinicalNotesList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList, "ValidClinicalNotes");
                TabAntibioticVaccineHistoryValid();
            }
            else
            {
                await BindTabAntibioticVaccineHistoryAsync();
            }
            HumanDiseaseReportDeduplicationService.SurvivorVaccinations = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.Vaccinations2);
            //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorAntibiotics = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.Antibiotics2);
            //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory)
            //{
            //    if(HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.intRowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
        }

        protected async Task OnDataListAntibioticHistorySelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked = false;              
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy)
                    {
                        SelectAndUnSelectIDfield(idfsYNAntimicrobialTherapy, HumanDiseaseReportDeduplicationService.AntibioticHistoryList, HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList);
                    }                   
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy)
                    {
                        SelectAndUnSelectIDfield(idfsYNAntimicrobialTherapy, HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, HumanDiseaseReportDeduplicationService.AntibioticHistoryList, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList[index].Value = value;
                    }
                }

                //var idfHumanCase= HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if(idfHumanCase== recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = HumanDiseaseReportDeduplicationService.antibioticsHistory;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = HumanDiseaseReportDeduplicationService.antibioticsHistory2;
                //}
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.antibioticsHistory);
                //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
                //    }
                //}

               // HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = HumanDiseaseReportDeduplicationService.antibioticsHistory;
                HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }

        protected async Task OnDataListAntibioticHistory2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.AntibioticHistoryList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy)
                    {
                        SelectAndUnSelectIDfield(idfsYNAntimicrobialTherapy, HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, HumanDiseaseReportDeduplicationService.AntibioticHistoryList, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList);
                    }                 
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.AntibioticHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy)
                    {
                        SelectAndUnSelectIDfield(idfsYNAntimicrobialTherapy, HumanDiseaseReportDeduplicationService.AntibioticHistoryList, HumanDiseaseReportDeduplicationService.AntibioticHistoryList2, HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList);
                    }                    
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Select(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase);
                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorAntibioticHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.AntibioticHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.AntibioticHistoryList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = HumanDiseaseReportDeduplicationService.antibioticsHistory;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = HumanDiseaseReportDeduplicationService.antibioticsHistory2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();
                //HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails = CopyAllInList<DiseaseReportAntiviralTherapiesViewModel>(HumanDiseaseReportDeduplicationService.antibioticsHistory2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.antibioticsHistory)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorAntibioticsHistoryDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorAntibioticHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }
        protected async Task OnDataListVaccineHistorySelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministered)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.VaccineHistoryList, HumanDiseaseReportDeduplicationService.VaccineHistoryList2, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList);
                    }                    
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Value;

                    if (HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministered)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.VaccineHistoryList2, HumanDiseaseReportDeduplicationService.VaccineHistoryList, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList);
                    }                 
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.VaccineHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory2;
                //}
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();
               // HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory;

                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory);
                //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }
        protected async Task OnDataListVaccineHistory2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.VaccineHistoryList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministered)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.VaccineHistoryList2, HumanDiseaseReportDeduplicationService.VaccineHistoryList, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList);
                    }
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Value;

                    if (HumanDiseaseReportDeduplicationService.VaccineHistoryList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.SpecificVaccinationAdministered)
                    {
                        SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.VaccineHistoryList, HumanDiseaseReportDeduplicationService.VaccineHistoryList2, HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList);
                    }
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList[index].Label;                       
                        HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorVaccineHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.VaccineHistoryList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.VaccineHistoryList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();
               // HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = HumanDiseaseReportDeduplicationService.vaccinationHistory2;

                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.vaccinationHistory)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Contains(item))
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {
                //        item.intRowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }

        protected async Task OnDataListClinicalNotesSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Key == DiseasereportDeduplicationAntibioticClinicalNotesConstants.SpecificVaccinationAdministered)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.ClinicalNotesList, HumanDiseaseReportDeduplicationService.ClinicalNotesList2, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Key == DiseasereportDeduplicationAntibioticClinicalNotesConstants.SpecificVaccinationAdministered)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.ClinicalNotesList2, HumanDiseaseReportDeduplicationService.ClinicalNotesList, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList[index].Value = value;
                    }
                }

                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory);

                HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }
        protected async Task OnDataListClinicalNotes2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked = false;
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.ClinicalNotesList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Key == DiseasereportDeduplicationAntibioticClinicalNotesConstants.SpecificVaccinationAdministered)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.ClinicalNotesList2, HumanDiseaseReportDeduplicationService.ClinicalNotesList, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ClinicalNotesList[index].Key == DiseasereportDeduplicationAntibioticClinicalNotesConstants.SpecificVaccinationAdministered)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecificVaccinationAdministered, HumanDiseaseReportDeduplicationService.ClinicalNotesList, HumanDiseaseReportDeduplicationService.ClinicalNotesList2, HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorClinicalNotesList[index].Value = value;
                    }
                }

                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllAntibioticDetails2 = false;

                await EnableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorVaccinationHistoryDetails = CopyAllInList<DiseaseReportVaccinationViewModel>(HumanDiseaseReportDeduplicationService.vaccinationHistory2);

                HumanDiseaseReportDeduplicationService.SurvivorVaccineHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }

        protected async Task OnAntibioticRowCheckChangeAsync(bool value, DiseaseReportAntiviralTherapiesViewModel data, bool record2)
        {
            try
            {
                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true)
                        HumanDiseaseReportDeduplicationService.SelectedAntibiotics.Remove(data);
                }
                else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true && HumanDiseaseReportDeduplicationService.SelectedAntibiotics != null)
                        HumanDiseaseReportDeduplicationService.SelectedAntibiotics.Remove(data);
                }
                else
                {
                    if (value == true)
                    {
                        if (HumanDiseaseReportDeduplicationService.SurvivorAntibiotics != null)
                        {
                            var list = HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Where(x => x.idfAntimicrobialTherapy == data.idfAntimicrobialTherapy).ToList();
                            if (list == null || list.Count == 0)
                                HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Add(data);
                        }
                        else
                        {
                            HumanDiseaseReportDeduplicationService.SurvivorAntibiotics = new List<DiseaseReportAntiviralTherapiesViewModel>();
                            HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Add(data);
                        }
                    }
                    else
                    {
                        var list = HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Where(x => x.idfAntimicrobialTherapy == data.idfAntimicrobialTherapy).ToList();
                        if (list != null)
                            HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Remove(data);
                    }

                    HumanDiseaseReportDeduplicationService.SurvivorAntibioticsCount = HumanDiseaseReportDeduplicationService.SurvivorAntibiotics.Count;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected async Task OnVaccinationRowCheckChangeAsync(bool value, DiseaseReportVaccinationViewModel data, bool record2)
        {
            try
            {
                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true)
                        HumanDiseaseReportDeduplicationService.SelectedVaccinations.Remove(data);
                }
                else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true && HumanDiseaseReportDeduplicationService.SelectedVaccinations != null)
                        HumanDiseaseReportDeduplicationService.SelectedVaccinations.Remove(data);
                }
                else
                {
                    if (value == true)
                    {
                        if (HumanDiseaseReportDeduplicationService.SurvivorVaccinations != null)
                        {
                            var list = HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Where(x => x.humanDiseaseReportVaccinationUID == data.humanDiseaseReportVaccinationUID).ToList();
                            if (list == null || list.Count == 0)
                                HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Add(data);
                        }
                        else
                        {
                            HumanDiseaseReportDeduplicationService.SurvivorVaccinations = new List<DiseaseReportVaccinationViewModel>();
                            HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Add(data);
                        }
                    }
                    else
                    {
                        var list = HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Where(x => x.humanDiseaseReportVaccinationUID == data.humanDiseaseReportVaccinationUID).ToList();
                        if (list != null)
                            HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Remove(data);
                    }

                    HumanDiseaseReportDeduplicationService.SurvivorVaccinationsCount = HumanDiseaseReportDeduplicationService.SurvivorVaccinations.Count;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
    }

}
