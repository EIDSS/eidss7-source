using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class SessionInformationBase : ParentComponent, IDisposable
    {
        #region Grid Reorder
        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }
     
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public CrossCutting.GridExtensionBase gridExtension { get; set; }
        #endregion

        [Parameter]
        public ActiveSurveillanceSessionViewModel Model { get; set; }
        protected RadzenDataGrid<ActiveSurveillanceSessionDiseaseSampleType> DiseasesSampleTypes;
        protected int Count;

        protected RadzenTemplateForm<ActiveSurveillanceSessionViewModel> Form { get; set; }

        protected LocationView SessionLocationComponent;

        [Inject] private ILogger<SessionInformationBase> Logger { get; set; }

        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool IsLoading;
        protected bool bDisableAddSessionSample { get; set; } = true;

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        protected int diseaseCount { get; set; }

        protected override async Task OnInitializedAsync()
        {
            GridContainerServices.OnChange += async property => await StateContainerChangeAsync(property);

            //reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            await InitializeModel();

            //set grid for not loaded
            IsLoading = false;

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    var lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("HumanActiveSurveillanceSession.SetDotNetReference", token,
                        lDotNetReference)
                    .ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task ComponentRefresh(LocationViewModel locationViewModel)
        {
           await SessionLocationComponent.RefreshComponent(locationViewModel);
        }

        protected void UpdateLocationHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.Model.SessionInformation.LocationViewModel = locationViewModel;
        }

        private async Task InitializeModel()
        {
            try
            {
                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

                //initialize the location control
                Model.SessionInformation.LocationViewModel = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
                    ShowAdminLevel0 = true,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = true,
                    ShowAdminLevel4 = false,
                    ShowAdminLevel5 = false,
                    ShowAdminLevel6 = false,
                    ShowSettlement = true,
                    ShowSettlementType = true,
                    ShowStreet = false,
                    ShowBuilding = false,
                    ShowApartment = false,
                    ShowElevation = false,
                    ShowHouse = false,
                    ShowLatitude = false,
                    ShowLongitude = false,
                    ShowMap = false,
                    ShowBuildingHouseApartmentGroup = false,
                    ShowPostalCode = false,
                    ShowCoordinates = false,
                    IsDbRequiredAdminLevel0 = true,
                    IsDbRequiredAdminLevel1 = true,
                    IsDbRequiredAdminLevel2 = true,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(CountryID),
                    AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null,
                    AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null
                };
                StateContainer.SetActiveSurveillanceSessionViewModel(Model);
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnChange(object value, string name)
        {
            try
            {
                if (value != null)
                {
                    var idfsBaseReference = long.Parse(value.ToString());

                    switch (name)
                    {
                        case "Status":
                            Model.Summary.Status = Statuses.First(x => x.IdfsBaseReference == idfsBaseReference).Name;
                            if (idfsBaseReference == EIDSSConstants.ActiveSurveillanceSessionStatusIds.Closed)
                            {
                                Model.SessionInformation.EndDate = DateTime.Now;
                            }
                            break;
                        case "Disease":
                            bDisableAddSessionSample = true;
                            var iSplitIndex = 0;

                            var monitoringSampleTypes = Model.SessionInformation.UnfilteredMonitoringSessionToSampleTypes ??
                                                        new List<ActiveSurveillanceSessionSamplesResponseModel>();

                            SampleTypesFiltered = new List<ActiveSurveillanceFilteredSampleType>();

                            if (value != null)
                            {
                                if (long.Parse(value.ToString()) != 0)
                                {
                                    var disease = Diseases.FirstOrDefault(x => x.KeyId == long.Parse(value.ToString()));
                                    if (disease != null)
                                        foreach (var strSampleType in disease.StrSampleType.Split(","))
                                        {
                                            var sampleType = new ActiveSurveillanceFilteredSampleType();
                                            var monitoringSampleType = new ActiveSurveillanceSessionSamplesResponseModel
                                            {
                                                MonitoringSessionID = null,
                                                SampleTypeID = long.Parse(strSampleType)
                                            };

                                            monitoringSampleType.MonitoringSessionToSampleType =
                                                monitoringSampleType.NewMonitoringSessionToSampleTypeID--;
                                            monitoringSampleTypes.Add(monitoringSampleType);

                                            sampleType.SampleTypeID = long.Parse(strSampleType);
                                            sampleType.SampleTypeName =
                                                disease.StrSampleTypeNames.Split(",")[iSplitIndex++];

                                            SampleTypesFiltered.Add(sampleType);
                                        }
                                }
                                Model.SessionInformation.UnfilteredMonitoringSessionToSampleTypes = monitoringSampleTypes;
                            }
                            break;
                    }
                }
                StateContainer.SetActiveSurveillanceSessionViewModel(Model);
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
        }

        protected void SetSelectedSampleType(object value)
        {
            try
            {
                if (value != null)
                {
                    long.Parse(value.ToString() ?? string.Empty);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                bDisableAddSessionSample = (value is null);
            }
        }

        #region Disease/Sample Gridview Methods

        protected async Task AddSample()
        {
            Model.RecordReadOnly = true;
            await DiseasesSampleTypes.InsertRow(new ActiveSurveillanceSessionDiseaseSampleType());
            await InvokeAsync(StateHasChanged);
        }

        protected void OnCreateRow(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            item.ID ??= Model.ActiveSurveillanceSessionDiseaseSampleTypeNewID--;

            Model.DiseasesSampleTypesUnfiltered.Add(item);
            var samples = Model.SessionInformation.MonitoringSessionToSampleTypes;

            Model.Summary.Disease = string.Empty;

            foreach (var diseaseSampleType in Model.DiseasesSampleTypesUnfiltered)
            {
                if (Model.Summary.Disease.IndexOf(diseaseSampleType.DiseaseName) < 0)
                {
                    Model.Summary.Disease += diseaseSampleType.DiseaseName + ", ";
                }

                samples ??= new List<ActiveSurveillanceSessionSamplesResponseModel>();

                if (samples.Exists(x => x.SampleTypeID == diseaseSampleType.SampleTypeID)) continue;
                var sample = new ActiveSurveillanceSessionSamplesResponseModel
                {
                    SampleTypeName = diseaseSampleType.SampleTypeName,
                    SampleTypeID = diseaseSampleType.SampleTypeID
                };

                samples.Add(sample);
            }

            Model.Summary.Disease = (Model.Summary.Disease + ".").Replace(", .", "");
            Model.SessionInformation.MonitoringSessionToSampleTypes = samples;
            Model.DiseasesSampleTypes = Model.DiseasesSampleTypesUnfiltered.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
            Model.DiseasesSampleTypesCount = Model.DiseasesSampleTypes.Count;

            StateContainer.SetActiveSurveillanceSessionViewModel(Model);
            InvokeAsync(StateHasChanged);
        }

        protected async Task EditSample(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            await InvokeAsync(() =>
            {
                DiseasesSampleTypes.EditRow(item);
                _ = OnChange(item.DiseaseID, "Disease");
                StateHasChanged();
            });
        }

        protected async Task DeleteSample(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            var result = await ShowDeleteConfirmation();

            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                var diseaseSampleType = item;

                if (Model.DetailedInformation.List.Where(x => x.idfsSampleType == diseaseSampleType.SampleTypeID).ToList().Any())
                {
                    var buttons = new List<DialogButton>();

                    var ok = new DialogButton
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };

                    buttons.Add(ok);

                    var dialogParams = new Dictionary<string, object>
                    {
                        {nameof(EIDSSDialog.DialogButtons), buttons},
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage)
                        }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
                }
                else
                {
                    if (diseaseSampleType.ID > 0)
                    {
                        diseaseSampleType.RowAction = EIDSSConstants.UserAction.Delete;
                    }
                    else
                    {
                        Model.DiseasesSampleTypesUnfiltered.Remove(diseaseSampleType);
                    }

                    Model.DiseasesSampleTypes = Model.DiseasesSampleTypesUnfiltered.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                    Model.DiseasesSampleTypesCount = Model.DiseasesSampleTypesUnfiltered.Count;

                    if (item == null)
                    {
                        Model.SessionInformation.MonitoringSessionToSampleTypes.Clear();
                    }
                    else
                    {
                        await DeleteRow(item);
                    }
                    
                    await DiseasesSampleTypes.Reload();
                }
                Model.RecordReadOnly = false;
            }

            DiagService.Close(result);
        }

        protected async Task DeleteRow(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            try
            {
                if (Model.SessionInformation.MonitoringSessionToSampleTypes != null)
                {
                    ActiveSurveillanceSessionSamplesResponseModel sampleType;
                    if (item.ID < 0)
                    {
                        sampleType = Model.SessionInformation.MonitoringSessionToSampleTypes.FirstOrDefault(x => x.NewMonitoringSessionToSampleTypeID == item.ID);

                        Model.SessionInformation.MonitoringSessionToSampleTypes.Remove(sampleType);
                    }
                    else
                    {
                        var iIndex = Model.SessionInformation.MonitoringSessionToSampleTypes.FindIndex(x => x.MonitoringSessionToSampleType == item.ID);

                        if (iIndex >= 0)
                        {
                            sampleType = Model.SessionInformation.MonitoringSessionToSampleTypes[iIndex];

                            sampleType.RowAction = EIDSSConstants.UserAction.Delete;
                            Model.SessionInformation.MonitoringSessionToSampleTypes.Add(sampleType);
                            Model.SessionInformation.UnfilteredMonitoringSessionToSampleTypes = Model.SessionInformation.MonitoringSessionToSampleTypes;
                            Model.SessionInformation.MonitoringSessionToSampleTypes = Model.SessionInformation.MonitoringSessionToSampleTypes.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();

                            sampleType = Model.SessionInformation.MonitoringSessionToSampleTypes.FirstOrDefault(x => x.MonitoringSessionToSampleType == item.ID);
                        }
                    }
                    Count = Model.SessionInformation.MonitoringSessionToSampleTypes.Count;
                    StateContainer.SetActiveSurveillanceSessionViewModel(Model);
                }
                else
                {
                    Count = 0;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        protected async Task SaveSample(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            try
            {
                if (item.DiseaseID != null && item.SampleTypeID != null)
                {
                    if (Model.DiseasesSampleTypesUnfiltered.FirstOrDefault(x => x.DiseaseID == item.DiseaseID && x.SampleTypeID == item.SampleTypeID && x.ID != item.ID) == null)
                    {
                        item.DiseaseName = Diseases.FirstOrDefault(x => x.KeyId == item.DiseaseID)?.StrName;
                        item.SampleTypeName = SampleTypesFiltered.FirstOrDefault(x => x.SampleTypeID == item.SampleTypeID)?.SampleTypeName;
                        await DiseasesSampleTypes.UpdateRow(item);
                    }
                    else
                    {
                        var buttons = new List<DialogButton>();

                        var ok = new DialogButton
                        {
                            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                            ButtonType = DialogButtonType.Yes
                        };

                        buttons.Add(ok);
                        var strDiseaseName = Model.DiseasesSampleTypesUnfiltered.FirstOrDefault(x => x.DiseaseID == item.DiseaseID)?.DiseaseName;
                        var strSampleTypeName = Model.DiseasesSampleTypesUnfiltered.FirstOrDefault(x => x.SampleTypeID == item.SampleTypeID)?.SampleTypeName;

                        Model.DiseasesSampleTypes = Model.DiseasesSampleTypesUnfiltered.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();

                        var dialogParams = new Dictionary<string, object>
                        {
                            {nameof(EIDSSDialog.DialogButtons), buttons},
                            {
                                nameof(EIDSSDialog.Message),
                                Localizer.GetString(
                                    MessageResourceKeyConstants.DuplicateOrganizationAbbreviatedNameFullNameMessage,
                                    strDiseaseName, strSampleTypeName)
                            }
                        };

                        await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                        DiseasesSampleTypes.CancelEditRow(item);
                    }
                }
                else
                {
                    await DiseasesSampleTypes.UpdateRow(item);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
            }
            finally
            {
                Model.RecordReadOnly = false;
            }
        }

        protected async Task CancelSampleEdit(ActiveSurveillanceSessionDiseaseSampleType item)
        {
            DiseasesSampleTypes.CancelEditRow(item);
            Model.RecordReadOnly = false;
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            var isValid = false;

            try
            {
                isValid = Form.EditContext.Validate();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
            }

            return isValid;
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }

        #region Grid Reorder

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceSessionSessionInformation");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig =  gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, DiseasesSampleTypes.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
    }
}
