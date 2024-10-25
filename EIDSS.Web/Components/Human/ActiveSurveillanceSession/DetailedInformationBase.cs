using System;
using System.Threading.Tasks;
using System.Threading;
using Radzen;
using Radzen.Blazor;
using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using System.Collections.Generic;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using Microsoft.Extensions.Logging;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.ClientLibrary.ApiClients.Human;
using System.Linq;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Web.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Web.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using System.Linq.Dynamic.Core;
using EIDSS.Web.Services;
using EIDSS.ClientLibrary;
using Microsoft.AspNetCore.Mvc;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class DetailedInformationBase : ParentComponent
    {
        #region Grid Column CHooser Reorder

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        #endregion Grid Column CHooser Reorder

        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        [Inject]
        private DialogService DialogService { get; set; }

        [Inject]
        public IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient { get; set; }

        protected RadzenDataGrid<ActiveSurveillanceSessionDetailedInformationResponseModel> _detailsGrid;

        #endregion Globals

        public RadzenTemplateForm<DetailedPersonsSamplesModalBase> modalForm { get; set; }
        private ILogger<DetailedInformationBase> Logger { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool isLoading;
        protected int count;

        protected override async Task OnInitializedAsync()
        {
            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);
            await base.OnInitializedAsync();
        }

        protected async Task LoadDetailsGridView(LoadDataArgs args, bool bInitialLoad = true)
        {
            try
            {
                isLoading = true;

                if (bInitialLoad)
                {
                    var request = new ActiveSurveillanceSessionDetailedInformationRequestModel();

                    request.LanguageId = GetCurrentLanguage();
                    request.idfMonitoringSession = IdfMonitoringSession;
                    request.Page = 1;
                    request.PageSize = int.MaxValue - 1;
                    request.SortColumn = "intOrder";
                    request.SortOrder = "asc";

                    model.DetailedInformation.List = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionDetailedInformation(request, token);
                    model.DetailedInformation.UnfilteredList = model.DetailedInformation.List;
                }
                _detailsGrid.Reset();
                count = (model.DetailedInformation.List == null) ? 0 : model.DetailedInformation.List.Count;
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                if (source?.IsCancellationRequested == true)
                {
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
        }

        public async Task EditDetail(object args)
        {
            try
            {
                await ClearDetailedInformation();

                ActiveSurveillanceSessionDetailedInformationResponseModel detail = (ActiveSurveillanceSessionDetailedInformationResponseModel)args;
                ActiveSurveillanceFilteredDisease sampleTypeDisease = new ActiveSurveillanceFilteredDisease();
                List<ActiveSurveillanceFilteredDisease> sampleTypeDiseases = new List<ActiveSurveillanceFilteredDisease>();

                model.DetailedInformation.ID = detail.ID;
                model.DetailedInformation.SentToOrganization = detail.idfSendToOffice;
                model.DetailedInformation.EIDSSPersonID = detail.EIDSSPersonID;
                model.DetailedInformation.PersonID = long.Parse(detail.PersonID.ToString());
                model.DetailedInformation.PersonAddress = detail.PersonAddress;
                model.DetailedInformation.Comments = detail.Comment;
                model.DetailedInformation.CollectionDate = detail.CollectionDate;

                //Build Disese List, according to the sample type selected
                model.DetailedInformation.SampleTypeDiseases = new List<ActiveSurveillanceFilteredDisease>();

                List<long> lDiseaseIDs = new List<long>();

                foreach (ActiveSurveillanceSessionDiseaseSampleType diseaseSampleType in model.DiseasesSampleTypesUnfiltered.Where(x => x.SampleTypeID == detail.idfsSampleType))
                {
                    sampleTypeDisease = new ActiveSurveillanceFilteredDisease();
                    sampleTypeDisease.DiseaseName = diseaseSampleType.DiseaseName;
                    sampleTypeDisease.DiseaseID = (long)diseaseSampleType.DiseaseID;

                    sampleTypeDiseases.Add(sampleTypeDisease);
                    lDiseaseIDs.Add((long)diseaseSampleType.DiseaseID);
                }

                model.DetailedInformation.SampleTypeDiseases = sampleTypeDiseases;
                model.DetailedInformation.DiseaseIDs = lDiseaseIDs.ToList();
                model.DetailedInformation.idfsSampleType = detail.idfsSampleType;
                model.DetailedInformation.FieldSampleID = detail.FieldSampleID;

                dynamic result = await DialogService.OpenAsync<DetailedPersonsSamplesModal>(Localizer.GetString(HeadingResourceKeyConstants.SessionInformationSampleDetailsHeading),
                    new Dictionary<string, object>() { { "model", model } }, new DialogOptions() { Width = "500px", Resizable = true, Draggable = false });

                await LoadDetailsGridView(null, false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task OpenDetailsModal(object args)
        {
            try
            {
                await ClearDetailedInformation();
                if (model.SessionInformation.MonitoringSessionToSampleTypes != null)
                {
                    if (model.SessionInformation.MonitoringSessionToSampleTypes.Count == 1)
                    {
                        model.DetailedInformation.idfsSampleType = model.SessionInformation.MonitoringSessionToSampleTypes[0].SampleTypeID;
                        GetFilteredDiseases(model.DetailedInformation.idfsSampleType);
                        if (model.DetailedInformation.SampleTypeDiseases.Count == 1)
                        {
                            List<long> diseaseIds = new List<long>();
                            diseaseIds.Add(long.Parse(model.DetailedInformation.idfsSampleType.ToString()));
                            model.DetailedInformation.DiseaseIDs = diseaseIds.AsODataEnumerable();
                        }
                    }

                    dynamic result = await DialogService.OpenAsync<DetailedPersonsSamplesModal>(Localizer.GetString(HeadingResourceKeyConstants.SessionInformationSampleDetailsHeading),
                        new Dictionary<string, object>() { { "model", model } }, new DialogOptions() { Width = "500px", Resizable = true, Draggable = false });

                    await LoadDetailsGridView(null, false);
                }
                else
                {
                    string test = "";
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnPrintSamplesButtonClick()
        {
            try
            {
                if (StateContainer.Model.SessionInformation.MonitoringSessionID != null)
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    //reportModel.AddParameter("ReportTitle",
                    //    Localizer.GetString(HeadingResourceKeyConstants.HumanActiveSurveillanceSessionPageHeading));
                    reportModel.AddParameter("PersonID",
                        authenticatedUser.PersonId); // For Organization // model.SearchCriteria.EIDSSPersonID);
                    reportModel.AddParameter("idfCase",
                        StateContainer.Model.SessionInformation.MonitoringSessionID.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.HumanActiveSurveillanceSessionPageHeading),
                        new Dictionary<string, object>
                        {
                            {"ReportName", "HumanActiveSurveillanceSessionListOfSamples"},
                            {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task DeleteRow(object value)
        {
            try
            {
                DialogReturnResult result = await ShowDeleteConfirmation();

                if (result != null)
                {
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close(result);

                        ActiveSurveillanceSessionDetailedInformationResponseModel detail = (ActiveSurveillanceSessionDetailedInformationResponseModel)value;

                        if (model.TestsInformation.List.Where(x => x.SampleID == detail.ID).ToList().Count() > 0)
                        {
                            var buttons = new List<DialogButton>();

                            var Ok = new DialogButton()
                            {
                                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                                ButtonType = DialogButtonType.OK
                            };

                            buttons.Add(Ok);

                            var dialogParams = new Dictionary<string, object>();
                            dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                            dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage));
                            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
                        }
                        else
                        {
                            if (detail.ID > 0)
                            {
                                detail.RowAction = EIDSSConstants.UserAction.Delete;
                                detail.RowStatus = (int) RowStatusTypes.Inactive;
                                model.DetailedInformation.List.Add(detail);
                                model.DetailedInformation.UnfilteredList = model.DetailedInformation.List;
                                model.DetailedInformation.List = model.DetailedInformation.List.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                            }
                            else
                            {
                                model.DetailedInformation.List.Remove(detail);
                            }

                            count = model.DetailedInformation.List.Count();
                            StateContainer.SetActiveSurveillanceSessionViewModel(model);

                            //await _detailsGrid.Reload();
                        }
                    }
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

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        #region Grid Column Chooser Reordr

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceSessionDetailedInformation");

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
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, _detailsGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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

        #endregion Grid Column Chooser Reordr
    }
}