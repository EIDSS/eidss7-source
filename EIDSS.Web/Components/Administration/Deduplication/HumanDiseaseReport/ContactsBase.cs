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
    public class ContactsBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
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

        protected async Task OnCheckAllContactsChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = true;
                chkCheckAll2 = false;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.ContactsList, HumanDiseaseReportDeduplicationService.ContactsList2, chkCheckAll, chkCheckAll2, HumanDiseaseReportDeduplicationService.SurvivorContactsList, "ValidTest");
               
                TabContactsValid();
            }
            else
            {
                await BindTabContactsAsync();
            }
            HumanDiseaseReportDeduplicationService.SurvivorContacts = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.Contacts);
            //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails2)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
            //    {
            //        item.RowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.RowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
            //    }
            //}
            HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
        }

        protected async Task OnCheckAllContacts2ChangeAsync(bool value)
        {
            if (value == true)
            {
                chkCheckAll = false;
                chkCheckAll2 = true;
                await CheckAllAsync(HumanDiseaseReportDeduplicationService.ContactsList2, HumanDiseaseReportDeduplicationService.ContactsList, chkCheckAll2, chkCheckAll, HumanDiseaseReportDeduplicationService.SurvivorContactsList, "ValidTest2");
               
                TabContactsValid();
            }
            else
            {
                await BindTabContactsAsync();
            }

            HumanDiseaseReportDeduplicationService.SurvivorContacts = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.Contacts2);
            //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails)
            //{
            //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
            //    {
            //        item.RowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //    }
            //    else
            //    {
            //        item.RowStatus = 1;
            //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
            //    }
            //}

            HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
        }

        protected async Task OnDataListContactsSelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.ContactsList[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ContactsList[index].Checked = false;
            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ContactsList[index].Checked = false;              
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.ContactsList[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.ContactsList[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ContactsList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.ContactsList, HumanDiseaseReportDeduplicationService.ContactsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    //}                   
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.ContactsList2[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ContactsList[index].Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.AntimicrobialTherapy)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.ContactsList2, HumanDiseaseReportDeduplicationService.ContactsList, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    //}
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorContactsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorContactsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorContactsList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorContactsList[index].Value = value;
                    }
                }
                HumanDiseaseReportDeduplicationService.chkCheckAllContactList = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllContactList2 = false;

                await EnableDisableMergeButtonAsync();

                //HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.contactsDetails);
                //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails2)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {

                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
                //    }
                //}
                HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
            }
        }

        protected async Task OnDataListContacts2SelectionChangeAsync(bool args, int index)
        {
            string value = string.Empty;
            string label = string.Empty;

            if (args == true)
            {
                HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked = true;
            }

            if (AllFieldValuePairsUnmatched() == true)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

            }
            else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
            {
                await ShowWarningMessage(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked = false;
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);
            }
            else
            {
                if (HumanDiseaseReportDeduplicationService.ContactsList2[index].Checked)
                {
                    HumanDiseaseReportDeduplicationService.ContactsList[index].Checked = false;
                    value = HumanDiseaseReportDeduplicationService.ContactsList2[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ContactsList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.ContactsList, HumanDiseaseReportDeduplicationService.ContactsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    //}
                }
                else
                {
                    HumanDiseaseReportDeduplicationService.ContactsList[index].Checked = true;
                    value = HumanDiseaseReportDeduplicationService.ContactsList[index].Value;

                    //if (HumanDiseaseReportDeduplicationService.ContactsList[index].Key == DiseasereportDeduplicationSamplesConstants.SampleCollected)
                    //{
                    //    SelectAndUnSelectIDfield(idfsYNSpecimenCollected, HumanDiseaseReportDeduplicationService.ContactsList, HumanDiseaseReportDeduplicationService.ContactsList2, HumanDiseaseReportDeduplicationService.SurvivorTestsList);
                    //}                    
                }

                if (HumanDiseaseReportDeduplicationService.SurvivorContactsList != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SurvivorContactsList.Count > 0)
                    {
                        label = HumanDiseaseReportDeduplicationService.SurvivorContactsList[index].Label;
                        HumanDiseaseReportDeduplicationService.SurvivorContactsList[index].Value = value;
                    }
                }

                //HumanDiseaseReportDeduplicationService.InfoValues = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList.Where(s => s.Checked == true).Select(s => s.Index);
                //HumanDiseaseReportDeduplicationService.InfoValues2 = (IEnumerable<int>)HumanDiseaseReportDeduplicationService.AntibioticVaccineHistoryList2.Where(s => s.Checked == true).Select(s => s.Index);

                //var idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var recordIdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //var record2IdfHumanCase = HumanDiseaseReportDeduplicationService.ContactsList2.Where(a => a.Key == DiseasereportDeduplicationAntibioticVaccineHistoryConstants.idfHumanCase).FirstOrDefault().Value;
                //if (idfHumanCase == recordIdfHumanCase)
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails;
                //}
                //else
                //{
                //    HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = HumanDiseaseReportDeduplicationService.contactsDetails2;
                //}

                HumanDiseaseReportDeduplicationService.chkCheckAllContactList = false;
                HumanDiseaseReportDeduplicationService.chkCheckAllContactList2 = false;
                //HumanDiseaseReportDeduplicationService.SurvivorContactsDetails = CopyAllInList<DiseaseReportContactDetailsViewModel>(HumanDiseaseReportDeduplicationService.contactsDetails2);
                //foreach (var item in HumanDiseaseReportDeduplicationService.contactsDetails)
                //{
                //    if (HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Contains(item))
                //    {
                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //    }
                //    else
                //    {

                //        item.RowStatus = 1;
                //        item.idfHumanCase = HumanDiseaseReportDeduplicationService.SurvivorHumanDiseaseReportID;
                //        HumanDiseaseReportDeduplicationService.SurvivorContactsDetails.Add(item);
                //    }
                //}
                await EnableDisableMergeButtonAsync();
                HumanDiseaseReportDeduplicationService.SurvivorContactHumanDiseaseReportID = HumanDiseaseReportDeduplicationService.SupersededHumanDiseaseReportID;
            }
        }

        protected async Task OnContactRowCheckChangeAsync(bool value, DiseaseReportContactDetailsViewModel data, bool record2)
        {
            try
            {
                if (AllFieldValuePairsUnmatched() == true)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true)
                        HumanDiseaseReportDeduplicationService.SelectedContacts.Remove(data);
                }
                else if (HumanDiseaseReportDeduplicationService.RecordSelection == 0 && HumanDiseaseReportDeduplicationService.Record2Selection == 0)
                {
                    await ShowInformationalDialog(MessageResourceKeyConstants.DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage, null);
                    if (value == true && HumanDiseaseReportDeduplicationService.SelectedContacts != null)
                        HumanDiseaseReportDeduplicationService.SelectedContacts.Remove(data);
                }
                else
                {
                    if (value == true)
                    {
                        if (HumanDiseaseReportDeduplicationService.SurvivorContacts != null)
                        {
                            var list = HumanDiseaseReportDeduplicationService.SurvivorContacts.Where(x => x.idfContactedCasePerson == data.idfContactedCasePerson).ToList();
                            if (list == null || list.Count == 0)
                                HumanDiseaseReportDeduplicationService.SurvivorContacts.Add(data);
                        }
                        else
                        {
                            HumanDiseaseReportDeduplicationService.SurvivorContacts = new List<DiseaseReportContactDetailsViewModel>();
                            HumanDiseaseReportDeduplicationService.SurvivorContacts.Add(data);
                        }
                    }
                    else
                    {
                        var list = HumanDiseaseReportDeduplicationService.SurvivorContacts.Where(x => x.idfContactedCasePerson == data.idfContactedCasePerson).ToList();
                        if (list != null)
                            HumanDiseaseReportDeduplicationService.SurvivorContacts.Remove(data);
                    }

                    HumanDiseaseReportDeduplicationService.SurvivorContactsCount = HumanDiseaseReportDeduplicationService.SurvivorContacts.Count;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

    }

}
