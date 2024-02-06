#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using System.Linq.Dynamic.Core;
using EIDSS.Web.Services;
using EIDSS.ClientLibrary;

#endregion

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class HumanDiseaseReportAntibioticVaccineHistoryBase : BaseComponent
    {
        #region Grid Column Reorder Picker

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("HumanDiseaseReportVaccineHistory");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, antibitiocDetailsgrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = gridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        [Inject]
        public ICrossCuttingClient _crossCuttingClient { get; set; }

        [Inject]
        public IHumanDiseaseReportClient _humanDiseaseReportClient { get; set; }

        [Inject]
        private ITokenService TokenService { get; set; }

        [Inject]
        private DialogService _dialogService { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private IHttpContextAccessor HttpContext { get; set; }

        public RadzenDataGrid<DiseaseReportAntiviralTherapiesViewModel> antibitiocDetailsgrid;
        public RadzenDataGrid<DiseaseReportVaccinationViewModel> vaccinationDetailsgrid;
        public bool isLoading;
        public bool showAntibioticDetails;
        public bool showAntibioticDetailsGrid;
        public bool showVaccinationDetails;
        public DiseaseReportAntiviralTherapiesViewModel tempAntibioticDetails;
        public DiseaseReportVaccinationViewModel tempVaccinationDetails;

        [Parameter]
        public bool isEdit { get; set; }

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public DiseaseReportAntibioticVaccineHistoryPageViewModel model { get; set; }

        public List<BaseReferenceViewModel> YesNoChoices;

        protected override async Task OnInitializedAsync()
        {
            //Note:  Be careful not to do too much in this event as performance will be terrible
            //wire up dialog events

            //set grid for not loaded
            try
            {
                isLoading = false;

                //set up the accordions
                showAntibioticDetails = false;
                showVaccinationDetails = false;

                await GetRadioButtonChoicesAsync();

                if (model.idfsYNAntimicrobialTherapy == long.Parse(EIDSSConstants.YesNoValueList.Yes))
                {
                    showAntibioticDetails = true;
                }
                if (model.idfsYNSpecificVaccinationAdministered == long.Parse(EIDSSConstants.YesNoValueList.Yes))
                {
                    showVaccinationDetails = true;
                }

                model.vaccinationHistoryForGrid = model.vaccinationHistory;

                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private async Task GetRadioButtonChoicesAsync()
        {
            //get the yes/no choices for radio buttons
            try
            {
                YesNoChoices = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, EIDSSConstants.HACodeList.HumanHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public void Dispose()
        {
        }

        public void DisplayAntibioticDetails(long? args, string param)
        {
            try
            {
                if (args == long.Parse(EIDSSConstants.YesNoValueList.Yes))
                {
                    showAntibioticDetails = true;
                }
                else
                {
                    showAntibioticDetails = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void AddAntibioticData()
        {
            try
            {
                DiseaseReportAntiviralTherapiesViewModel item = new DiseaseReportAntiviralTherapiesViewModel();
                item.AntibioticID = model.antibioticsHistory.Count() + 1;
                item.strAntimicrobialTherapyName = model.AntibioticName;
                item.strDosage = model.Dose;
                item.datFirstAdministeredDate = model.datAntibioticFirstAdministered;
                item.rowAction = "1";
                item.intRowStatus = 0;
                model.antibioticsHistory.Add(item);
                await antibitiocDetailsgrid.Reload();
                model.AntibioticName = null;
                model.datAntibioticFirstAdministered = null;
                model.Dose = null;
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                //await JsRuntime.InvokeAsync<string>("SetAntiViralTherapiesData", model.antibioticsHistory);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void SaveAntibioticRow(DiseaseReportAntiviralTherapiesViewModel antibitiocDetails)
        {
            try
            {
                await antibitiocDetailsgrid.UpdateRow(antibitiocDetails);
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void CancelAntibioticEdit(DiseaseReportAntiviralTherapiesViewModel antibioticDetails)
        {
            try
            {
                antibitiocDetailsgrid.CancelEditRow(antibioticDetails);

                model.antibioticsHistory.First(v => v.AntibioticID == antibioticDetails.AntibioticID).strAntimicrobialTherapyName = tempAntibioticDetails.strAntimicrobialTherapyName;
                model.antibioticsHistory.First(v => v.AntibioticID == antibioticDetails.AntibioticID).strDosage = tempAntibioticDetails.strDosage;
                model.antibioticsHistory.First(v => v.AntibioticID == antibioticDetails.AntibioticID).datFirstAdministeredDate = tempAntibioticDetails.datFirstAdministeredDate;

                await antibitiocDetailsgrid.Reload();
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void EditAntibioticRow(DiseaseReportAntiviralTherapiesViewModel item)
        {
            try
            {
                tempAntibioticDetails = new DiseaseReportAntiviralTherapiesViewModel();
                tempAntibioticDetails.AntibioticID = item.AntibioticID;
                tempAntibioticDetails.idfAntimicrobialTherapy = item.idfAntimicrobialTherapy;
                tempAntibioticDetails.strAntimicrobialTherapyName = item.strAntimicrobialTherapyName;
                tempAntibioticDetails.strDosage = item.strDosage;
                tempAntibioticDetails.datFirstAdministeredDate = item.datFirstAdministeredDate;
                item.rowAction = "2";
                item.intRowStatus = 0;
                await antibitiocDetailsgrid.EditRow(item);
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                //await JsRuntime.InvokeAsync<string>("SetAntiViralTherapiesData", model.antibioticsHistory);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void DeleteAntibioticRow(DiseaseReportAntiviralTherapiesViewModel item)
        {
            try
            {
                if (model.antibioticsHistory != null && model.antibioticsHistory.Contains(item))
                {
                    foreach (var detail in model.antibioticsHistory)
                    {
                        if (detail.idfAntimicrobialTherapy == item.idfAntimicrobialTherapy)
                        {
                            detail.rowAction = "D";
                            detail.intRowStatus = 1;
                            await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                            model.antibioticsHistory = model.antibioticsHistory.Where(d => d.intRowStatus == 0).ToList();
                            await antibitiocDetailsgrid.Reload();
                            break;
                        }
                    }

                    await InvokeAsync(StateHasChanged);

                    //if (model.antibioticsHistory.Contains(item))
                    //{
                    //item.RowAction = "D";
                    //item.intRowStatus = 1;
                    //await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                    //model.antibioticsHistory = model.antibioticsHistory.Where(d => d.intRowStatus ==0).ToList();

                    //// model.antibioticsHistory.Remove(item);
                    //await antibitiocDetailsgrid.Reload();

                    //await JsRuntime.InvokeAsync<string>("SetAntiViralTherapiesData", model.antibioticsHistory);
                }
                else
                {
                    antibitiocDetailsgrid.CancelEditRow(item);
                    // await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                    //await JsRuntime.InvokeAsync<string>("SetAntiViralTherapiesData", model.antibioticsHistory);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public void DisplayVaccinationDetails(long? args, string param)
        {
            try
            {
                if (args == long.Parse(EIDSSConstants.YesNoValueList.Yes))
                {
                    showVaccinationDetails = true;
                }
                else
                {
                    showVaccinationDetails = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void AddVaccinationData()
        {
            try
            {
                DiseaseReportVaccinationViewModel item = new DiseaseReportVaccinationViewModel();
                item.VaccinationID = model.vaccinationHistory.Count() + 1;
                item.vaccinationName = model.vaccinationName;
                item.vaccinationDate = model.vaccinationDate;
                item.rowAction = "1";
                item.intRowStatus = 0;

                model.vaccinationHistory.Add(item);
                //model.vaccinationHistoryForGrid.Add(item);

                await vaccinationDetailsgrid.Reload();
                model.vaccinationName = null;
                model.vaccinationDate = null;
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void SaveVaccinationRow(DiseaseReportVaccinationViewModel vaccinationDetails)
        {
            try
            {
                await vaccinationDetailsgrid.UpdateRow(vaccinationDetails);
                //if ((model.HumanID != null && model.HumanID != 0) && (model.idfHumanCase == null || model.idfHumanCase == 0))
                //    HttpSessionHelper.SetObjectAsJson(HttpContext.HttpContext.Session, "AntibioticVaccineModel" + model.HumanID, model);
                //else if (model.idfHumanCase != 0 && model.idfHumanCase != null)
                //    HttpSessionHelper.SetObjectAsJson(HttpContext.HttpContext.Session, "AntibioticVaccineModel" + model.idfHumanCase, model);
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void CancelVaccinationEdit(DiseaseReportVaccinationViewModel vaccinationDetails)
        {
            try
            {
                //vaccinationDetailsgrid.CancelEditRow(vaccinationDetails);
                //model.vaccinationHistory.RemoveAt(vaccinationDetails.VaccinationID - 1);
                //vaccinationDetails = tempVaccinationDetails;
                //model.vaccinationHistory.Insert(vaccinationDetails.VaccinationID - 1, tempVaccinationDetails);
                //await vaccinationDetailsgrid.Reload();
                //await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);

                vaccinationDetailsgrid.CancelEditRow(vaccinationDetails);

                model.vaccinationHistory.Where(v => v.humanDiseaseReportVaccinationUID == vaccinationDetails.humanDiseaseReportVaccinationUID).First().vaccinationName = tempVaccinationDetails.vaccinationName;
                model.vaccinationHistory.Where(v => v.humanDiseaseReportVaccinationUID == vaccinationDetails.humanDiseaseReportVaccinationUID).First().vaccinationDate = tempVaccinationDetails.vaccinationDate;

                //model.vaccinationHistory.RemoveAt(vaccinationDetails.VaccinationID - 1);
                //vaccinationDetails = tempVaccinationDetails;
                //model.vaccinationHistory.Insert(vaccinationDetails.VaccinationID - 1, tempVaccinationDetails);

                await vaccinationDetailsgrid.Reload();
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void EditVaccinationRow(DiseaseReportVaccinationViewModel item)
        {
            try
            {
                tempVaccinationDetails = new DiseaseReportVaccinationViewModel();
                tempVaccinationDetails.VaccinationID = item.VaccinationID;
                tempVaccinationDetails.humanDiseaseReportVaccinationUID = item.humanDiseaseReportVaccinationUID;
                tempVaccinationDetails.vaccinationName = item.vaccinationName;
                tempVaccinationDetails.vaccinationDate = item.vaccinationDate;
                tempVaccinationDetails.rowAction = "2";
                tempVaccinationDetails.intRowStatus = 0;
                await vaccinationDetailsgrid.EditRow(item);
                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async void DeleteVaccinationRow(DiseaseReportVaccinationViewModel item)
        {
            try
            {
                if (model.vaccinationHistory.Contains(item))
                {
                    foreach (var detail in model.vaccinationHistory)
                    {
                        if (detail.humanDiseaseReportVaccinationUID == item.humanDiseaseReportVaccinationUID)
                        {
                            // if its 0, then its a new record not yet saved to DB, therefore just remove from list
                            if (detail.humanDiseaseReportVaccinationUID == 0)
                            {
                                model.vaccinationHistory.Remove(detail);
                                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                                await vaccinationDetailsgrid.Reload();
                            }
                            else
                            {
                                detail.rowAction = "D";
                                detail.intRowStatus = 1;
                                await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                                model.vaccinationHistoryForGrid = model.vaccinationHistory.Where(d => d.intRowStatus == 0).ToList();
                                await vaccinationDetailsgrid.Reload();
                            }
                            break;
                        }
                    }

                    await InvokeAsync(StateHasChanged);
                }
                //if (model.vaccinationHistory.Contains(item))
                //{
                //    model.vaccinationHistory.Remove(item);
                //    await vaccinationDetailsgrid.Reload();
                //}
                else
                {
                    vaccinationDetailsgrid.CancelEditRow(item);
                }
                //await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task UpdateAdditionalInformationAndComments(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    model.AdditionalInforMation = Value.ToString();
                    await JsRuntime.InvokeAsync<string>("SetVaccionationAntiViralTherapiesData", model);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }
    }
}