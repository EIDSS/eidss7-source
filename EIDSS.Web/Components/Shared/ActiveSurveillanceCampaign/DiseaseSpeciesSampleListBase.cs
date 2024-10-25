using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Shared.ActiveSurveillanceCampaign
{
    public class DiseaseSpeciesSampleListBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected IBaseReferenceClient BaseReferenceClient { get; set; }

        [Inject]
        private ILogger<DiseaseSpeciesSampleListBase> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] 
        public int AccessoryCode { get; set; }

        [Parameter]
        public long? CampaignId { get; set; }

        [Parameter]
        public long CampaignCategoryId { get; set; }

        [Parameter]
        public UserPermissions permissions { get; set; }

        [Parameter]
        public List<VeterinaryActiveSurveillanceSessionViewModel> VasCampaignSessionList { get; set; }

        [Parameter]
        public List<ActiveSurveillanceSessionResponseModel> HasCampaignSessionList { get; set; }

        [Parameter]
        public EventCallback<List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>> CampaignDiseaseSpeciesSampleChanged { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        #endregion

        #endregion

        #region Member Variables

        protected int DiseaseSpeciesCount;
        protected int DiseaseSpeciesDatabaseQueryCount;
        protected int DiseaseSpeciesLastDatabasePage;
        protected int DiseaseSpeciesNewRecordCount;
        protected bool IsLoading;
        protected bool EditIsDisabled;
        protected bool AddButtonIsDisabled;
        protected bool DeleteButtonIsDisabled;

        protected RadzenDataGrid<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> DiseaseSpeciesSampleGrid;
        protected List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> DiseaseSpeciesSamples;
        public List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> PendingSaveDiseaseSpeciesSamples; 

        private CancellationTokenSource source;
        private CancellationToken token;

        protected List<BaseReferenceAdvancedListResponseModel> SpeciesTypes { get; set; }
        protected IEnumerable<FilteredDiseaseGetListViewModel> DiseaseList { get; set; } //Need to check
        public List<DiseaseSampleTypeByDiseaseResponseModel> SamplesTypes { get; set; }

        protected string DiseaseString;
        protected List<long?> CampaignDiseaseIDs;

        #endregion

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "DiseaseName";

        #endregion

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // reset the cancellation token
            source = new();
            token = source.Token;

            CampaignDiseaseIDs = new();

            await base.OnInitializedAsync();
        }

        protected override Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if ((CampaignId.HasValue && CampaignId > 0) )
                {
                   // EditIsDisabled = true;
                }
            }

            return base.OnAfterRenderAsync(firstRender);
        }


        protected async Task<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> IsEditDisabledAsync(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
            {
                item.IsEditDisabled = false;
                if (VasCampaignSessionList != null)
                {
                    foreach (var campaignSession in HasCampaignSessionList)
                    {
                        var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel();
                        request.LanguageID = GetCurrentLanguage();
                        request.MonitoringSessionID = campaignSession.SessionKey;
                        var result = await VeterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, token);
                        if (result != null)
                        {
                            if (result.FirstOrDefault(r => r.DiseaseID == item.idfsDiagnosis || r.SampleTypeID == item.idfsSampleType) != null)
                            {
                                item.IsEditDisabled = true;
                                break;

                            }
                        }
                    }
                }
            }

            if (CampaignCategoryId ==  Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            {
                item.IsEditDisabled = false;
                if (VasCampaignSessionList != null)
                {
                    foreach (var campaignSession in VasCampaignSessionList)
                    {
                        var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel();
                        request.LanguageID = GetCurrentLanguage();
                        request.MonitoringSessionID = campaignSession.SessionKey;
                        var result = await VeterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, token);
                        if (result != null)
                        {
                            if (result.FirstOrDefault(r => r.DiseaseID == item.idfsDiagnosis || r.SpeciesTypeID == item.idfsSpeciesType || r.SampleTypeID == item.idfsSampleType) != null)
                            {
                                item.IsEditDisabled = true;
                                break;

                            }
                        }
                    }
                }
            }
         

            return item;
        }


        protected async Task OnAddDiseaseSpeciesSampleClick()
        {
            AddButtonIsDisabled = true;

            var item = new ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel();
            DiseaseSpeciesNewRecordCount++;
            DiseaseSpeciesCount = DiseaseSpeciesDatabaseQueryCount + DiseaseSpeciesNewRecordCount;
            await IsEditDisabledAsync(item);
            await DiseaseSpeciesSampleGrid.InsertRow(item);
        }

        protected void OnCreateRow(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {

            var disease = DiseaseList.ToList().Find(x => x.DiseaseID == item.idfsDiagnosis);
            if (disease != null) item.Disease = disease.DiseaseName;

            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            {
                var speciesName = SpeciesTypes.Find(x => x.idfsBaseReference == item.idfsSpeciesType);
                if (speciesName != null) item.SpeciesTypeName = speciesName.strName;
            }

            var sampleTypeName = SamplesTypes.Find(x => x.idfsSampleType == item.idfsSampleType);
            if (sampleTypeName != null) item.SampleTypeName = sampleTypeName.strSampleType;


            if (DiseaseSpeciesSamples.Any())
            {
                int.TryParse(DiseaseSpeciesSamples.Max(t => t.RowNumber).ToString(), out int maxRowNumber);
                maxRowNumber++;
                item.RowNumber = maxRowNumber;
            }
            else
            {
                item.RowNumber = 1;
            }

            item.RowAction = (int)RowActionTypeEnum.Insert;
            item.RowStatus = (int)RowStatusTypeEnum.Active;
            item.idfCampaignToDiagnosis = DiseaseSpeciesSamples.Count + 1 * -1;

            DiseaseSpeciesSamples.Add(item);

            DiseaseString = String.Empty;
            foreach (var dss in DiseaseSpeciesSamples)
            {
                var separator = !string.IsNullOrEmpty(DiseaseString) ? ", " : string.Empty;
                DiseaseString += $"{separator}{dss.Disease}";
            }

            TogglePendingSaveDiseaseSpecies(item, null);

            AddButtonIsDisabled = false;

        }

        protected void OnUpdateRow(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            var disease = DiseaseList.ToList().Find(x => x.DiseaseID == item.idfsDiagnosis);
            if (disease != null) item.Disease = disease.DiseaseName;

            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            {
                var speciesName = SpeciesTypes.Find(x => x.idfsBaseReference == item.idfsSpeciesType);
                if (speciesName != null) item.SpeciesTypeName = speciesName.strName;
            }

            var sampleTypeName = SamplesTypes.Find(x => x.idfsSampleType == item.idfsSampleType);
            if (sampleTypeName != null) item.SampleTypeName = sampleTypeName.strSampleType;

            item.RowAction = (int)RowActionTypeEnum.Update;
            item.RowStatus = (int)RowStatusTypeEnum.Active;

            if (DiseaseSpeciesSamples.Any(x => x.idfCampaignToDiagnosis == item.idfCampaignToDiagnosis))
            {
                int index = DiseaseSpeciesSamples.IndexOf(item);
                DiseaseSpeciesSamples[index] = item;

                DiseaseString = String.Empty;
                foreach (var dss in DiseaseSpeciesSamples)
                {
                    var separator = !string.IsNullOrEmpty(DiseaseString) ? ", " : string.Empty;
                    DiseaseString += $"{separator}{dss.Disease}";
                }

                TogglePendingSaveDiseaseSpecies(item, item);
            }

            AddButtonIsDisabled = false;
        }

        protected async Task OnEditDiseaseSpeciesClick(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            AddButtonIsDisabled = true;
            await IsEditDisabledAsync(item);
            if (item.idfsDiagnosis != null)
            {
                await GetSampleTypesByDiseaseAsync(null, Convert.ToInt64(item.idfsDiagnosis.Value));

                if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
                {
                    await GetSpeciesByDiseaseAsync(null, Convert.ToInt64(item.idfsDiagnosis.Value));
                }

            }
            item.IsInEditMode = true;

            await DiseaseSpeciesSampleGrid.EditRow(item);
            await CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);
        }

        protected async Task OnDeleteDiseaseSpeciesClick(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            var found = false;
            var dialogParams = new Dictionary<string, object>();
            List<DialogButton> buttons = new();

            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
            {
                if (HasCampaignSessionList != null)
                {
                    foreach (var campaignSession in HasCampaignSessionList)
                    {
                        var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel();
                        request.LanguageID = GetCurrentLanguage();
                        request.MonitoringSessionID = campaignSession.SessionKey;
                        var result = await VeterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, token);
                        if (result != null)
                        {
                            if (result.FirstOrDefault(r => r.DiseaseID == item.idfsDiagnosis  || r.SampleTypeID == item.idfsSpeciesType) != null)
                            {
                                found = true;
                                break;

                            }
                        }
                    }
                }

            }
            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            {
                if (VasCampaignSessionList != null)
                {
                    foreach (var campaignSession in VasCampaignSessionList)
                    {
                        var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel();
                        request.LanguageID = GetCurrentLanguage();
                        request.MonitoringSessionID = campaignSession.SessionKey;
                        var result = await VeterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, token);
                        if (result != null)
                        {
                            if (result.FirstOrDefault(r => r.DiseaseID == item.idfsDiagnosis || r.SpeciesTypeID == item.idfsSpeciesType || r.SampleTypeID == item.idfsSpeciesType) != null)
                            {
                                found = true;
                                break;

                            }
                        }
                    }
                }
            }


          

            if (found)
            {
                await ShowMessageDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage);

            }
            else
            {

                buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                dialogParams = new()
                {
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {


                        if (item.idfCampaignToDiagnosis <= 0)
                        {
                            DiseaseSpeciesSamples.Remove(item);
                            PendingSaveDiseaseSpeciesSamples.Remove(item);
                            DiseaseSpeciesNewRecordCount--;
                        }
                        else
                        {
                            var deletedRecord = item.ShallowCopy();
                            deletedRecord.RowAction = (int)RowActionTypeEnum.Delete;
                            deletedRecord.RowStatus = (int)RowStatusTypeEnum.Inactive;
                            DiseaseSpeciesSamples.Remove(item);
                            DiseaseSpeciesCount--;

                            TogglePendingSaveDiseaseSpecies(deletedRecord, item);

                        }
                    }
            }
            await CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);
            if (DiseaseSpeciesSamples != null)
                DiseaseSpeciesCount = DiseaseSpeciesSamples.Count;

            await DiseaseSpeciesSampleGrid.Reload();
            AddButtonIsDisabled = false;

        }

        protected async Task OnSaveDiseaseSpeciesClick(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            var duplicateDiseaseList = new List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>();
            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            {
                 duplicateDiseaseList = DiseaseSpeciesSamples.Where(d => d.idfsDiagnosis == item.idfsDiagnosis 
                                                                         && d.idfsSampleType == item.idfsSampleType 
                                                                         && d.idfsSpeciesType == item.idfsSpeciesType
                                                                         && d.idfCampaignToDiagnosis != item.idfCampaignToDiagnosis).ToList();

            }
            if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
            {
                duplicateDiseaseList = DiseaseSpeciesSamples.Where(d => d.idfsDiagnosis == item.idfsDiagnosis && d.idfsSampleType == item.idfsSampleType ).ToList();

            }

            //if (item.RowAction == 1)
            //{
                if (duplicateDiseaseList.Count >= 1)
                {
                    await ShowMessageDialog(MessageResourceKeyConstants.DuplicateRecordsAreNotAllowedMessage);

                }
                else
                {
                    await DiseaseSpeciesSampleGrid.UpdateRow(item);

                }
            //}
            //else
            //{
            //    var duplicateDiseaseItem = new ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel();
            //    if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary))
            //    {
            //        duplicateDiseaseItem= duplicateDiseaseList.FirstOrDefault(d => d.idfsDiagnosis == item.idfsDiagnosis && d.idfsSampleType == item.idfsSampleType && d.idfsSpeciesType == item.idfsSpeciesType);
            //    }
            //    if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Human))
            //    {
            //        duplicateDiseaseItem = duplicateDiseaseList.FirstOrDefault(d => d.idfsDiagnosis == item.idfsDiagnosis && d.idfsSampleType == item.idfsSampleType);
            //    }

            //    if (duplicateDiseaseItem 1 )
            //    {
            //        await ShowMessageDialog(MessageResourceKeyConstants.DuplicateRecordsAreNotAllowedMessage);
            //    }
            //    else
            //    {
            //        await DiseaseSpeciesSampleGrid.UpdateRow(item);
            //    }
            //}
            item.IsInEditMode = false;
            await CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);
        }


        protected void CheckDiseaseSpeciesSamplesExist(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            if (DiseaseSpeciesSamples.FirstOrDefault(d => d.idfsDiagnosis == item.idfsDiagnosis && d.idfsSampleType == item.idfsSampleType && d.idfsSpeciesType == item.idfsSpeciesType) == null)
            {

            }
        }


        protected async Task OnCancelDiseaseSpeciesEditClickAsync(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel item)
        {
            DiseaseSpeciesSampleGrid.CancelEditRow(item);
            AddButtonIsDisabled = false;
            item.IsInEditMode = false;
            await CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveDiseaseSpecies(ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel record,
            ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel originalRecord)
        {
            int index;

            if (PendingSaveDiseaseSpeciesSamples == null)
                PendingSaveDiseaseSpeciesSamples = new List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>();

            if (PendingSaveDiseaseSpeciesSamples.Any(x => x.idfCampaignToDiagnosis == record.idfCampaignToDiagnosis))
            {
                index = PendingSaveDiseaseSpeciesSamples.IndexOf(originalRecord);
                PendingSaveDiseaseSpeciesSamples[index] = record;
            }
            else
            {
                PendingSaveDiseaseSpeciesSamples.Add(record);
            }
            
            CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);
        }

        protected async Task LoadDiseaseSpeciesSampleGrid(LoadDataArgs args)
        {
            try
            {
                if (CampaignId != null)
                {
                    int pageSize = 10;

                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (DiseaseSpeciesSamples is null)
                    {
                        IsLoading = true;
                    }

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                    {
                        string sortColumn,
                           sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = DEFAULT_SORT_COLUMN;
                            sortOrder = EIDSSConstants.SortConstants.Descending;
                        }
                        else
                        {
                            sortColumn = args.Sorts.FirstOrDefault()?.Property;
                            sortOrder = args.Sorts.FirstOrDefault()!.SortOrder.HasValue ? args.Sorts.FirstOrDefault()?.SortOrder.Value.ToString() : EIDSSConstants.SortConstants.Descending;
                        }

                        if (CampaignId != null)
                        {
                            var request = new ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel()
                            {
                                CampaignID = CampaignId.Value,
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = 1000,
                                SortColumn = "idfCampaign",
                                SortOrder = "desc"
                            };
                            DiseaseSpeciesSamples = await CrossCuttingClient.GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(request, token);
                        }

                        await SetSessionReportType();
                        DiseaseSpeciesDatabaseQueryCount = !DiseaseSpeciesSamples.Any() ? 0 : DiseaseSpeciesSamples.Count();

                        // Pagination refresh from the database, so check any pending save updates.
                        for (int index = 0; index < DiseaseSpeciesSamples.Count; index++)
                        {
                            if (PendingSaveDiseaseSpeciesSamples != null && PendingSaveDiseaseSpeciesSamples.Any(x => x.idfCampaignToDiagnosis == DiseaseSpeciesSamples[index].idfCampaignToDiagnosis))
                            {
                                if (PendingSaveDiseaseSpeciesSamples.First(x => x.idfCampaignToDiagnosis == PendingSaveDiseaseSpeciesSamples[index].idfCampaignToDiagnosis).RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    DiseaseSpeciesSamples.RemoveAt(index);
                                    DiseaseSpeciesDatabaseQueryCount--;
                                }
                                else
                                    DiseaseSpeciesSamples[index] = PendingSaveDiseaseSpeciesSamples.First(x => x.idfCampaignToDiagnosis == DiseaseSpeciesSamples[index].idfCampaignToDiagnosis);
                            }
                        }
                    }
                    else
                        DiseaseSpeciesDatabaseQueryCount = !DiseaseSpeciesSamples.Any() ? 0 : DiseaseSpeciesSamples.First().TotalRowCount;

                    DiseaseSpeciesCount = DiseaseSpeciesDatabaseQueryCount + DiseaseSpeciesNewRecordCount;

                    DiseaseSpeciesLastDatabasePage = Math.DivRem(DiseaseSpeciesDatabaseQueryCount, pageSize, out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0)
                        DiseaseSpeciesLastDatabasePage += 1;

                    for (int index = 0; index < DiseaseSpeciesSamples.Count; index++)
                    {
                        if (PendingSaveDiseaseSpeciesSamples != null && PendingSaveDiseaseSpeciesSamples.Any(x => x.idfCampaignToDiagnosis == DiseaseSpeciesSamples[index].idfCampaignToDiagnosis))
                        {
                            DiseaseSpeciesSamples[index] = PendingSaveDiseaseSpeciesSamples.First(x => x.idfCampaignToDiagnosis == DiseaseSpeciesSamples[index].idfCampaignToDiagnosis);
                        }
                    }

                    if (page >= DiseaseSpeciesLastDatabasePage && PendingSaveDiseaseSpeciesSamples != null && PendingSaveDiseaseSpeciesSamples.Any(x => x.idfCampaignToDiagnosis < 0))
                    {
                        List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel> newRecordsPendingSave = PendingSaveDiseaseSpeciesSamples.Where(x => x.idfCampaignToDiagnosis < 0).ToList();
                        int counter = 0;
                        int pendingSavePage = page - DiseaseSpeciesLastDatabasePage;
                        int quotientNewRecords = Math.DivRem(DiseaseSpeciesCount, pageSize, out var remainderNewRecords);

                        if (remainderNewRecords >= 5)
                            quotientNewRecords += 1;

                        if (pendingSavePage == 1)
                        {
                            if (remainderDatabaseQuery > newRecordsPendingSave.Count)
                                pageSize = newRecordsPendingSave.Count;
                            else
                                pageSize = remainderDatabaseQuery;
                        }
                        else if (page == quotientNewRecords)
                        {
                            pageSize = remainderNewRecords;
                            DiseaseSpeciesSamples.Clear();
                        }
                        else
                            DiseaseSpeciesSamples.Clear();

                        while (counter < pageSize)
                        {
                            if (pendingSavePage == 0)
                                DiseaseSpeciesSamples.Add(newRecordsPendingSave[counter]);
                            else
                                DiseaseSpeciesSamples.Add(newRecordsPendingSave[pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                            counter += 1;
                        }
                    }

                    DiseaseSpeciesLastDatabasePage = page;
                    IsLoading = false;
                }
                else
                {
                    if (DiseaseSpeciesSamples == null)
                    { 
                        DiseaseSpeciesSamples = new List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>();
                        DiseaseSpeciesCount = 0;
                    }
                }

                await CampaignDiseaseSpeciesSampleChanged.InvokeAsync(DiseaseSpeciesSamples);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsLoading = false;
            }
        }

        private async Task SetSessionReportType()
        {
           await InvokeAsync(StateHasChanged);
        }

        protected async Task OnDiseaseChange(long? diseaseId)
        {
            var args = new LoadDataArgs();
            await GetDiseasesAsync(args);
            SpeciesTypes = new List<BaseReferenceAdvancedListResponseModel>();
            SamplesTypes = new List<DiseaseSampleTypeByDiseaseResponseModel>();
            if (diseaseId != null)
            {
                await GetSampleTypesByDiseaseAsync(null, Convert.ToInt64(diseaseId));

                if (CampaignCategoryId == Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary)) 
                {
                    await GetSpeciesByDiseaseAsync(null, Convert.ToInt64(diseaseId));
                }
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {

            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = AccessoryCode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = null,
                AdvancedSearchTerm = args != null && args.Filter != null ? args.Filter: null  
            };

            DiseaseList= await CrossCuttingClient.GetFilteredDiseaseList(request);

            // there is a linked session so filter the diseases
            if (CampaignDiseaseIDs.Count > 0)
            {
                var filteredDiseases = DiseaseList.Where(d =>
                                        CampaignDiseaseIDs.Any(c => c.Value == d.DiseaseID));
                DiseaseList = filteredDiseases.ToList();
            }

        }

        protected async Task GetSpeciesAsync(LoadDataArgs args)
        {
          
            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = String.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                intHACode =AccessoryCode,
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                ReferenceTypeName = EIDSSConstants.BaseReferenceConstants.SpeciesList,
                SortColumn = "intOrder",
                SortOrder = "asc",
                
            };
           SpeciesTypes= await CrossCuttingClient.GetBaseReferenceAdvanceList(request);


        }

        protected async Task GetSpeciesByDiseaseAsync(LoadDataArgs args, long diseaseIds)
        {
            await GetDiseasesAsync(args);
            var diseaseHACode = DiseaseList.FirstOrDefault(d => d.DiseaseID == diseaseIds).intHACode;

            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = null,
                intHACode = diseaseHACode,
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                ReferenceTypeName = EIDSSConstants.BaseReferenceConstants.SpeciesList,
                SortColumn = "intOrder",
                SortOrder = "asc",

            };
            SpeciesTypes = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);


        }


        protected async Task GetSampleTypesByDiseaseAsync(LoadDataArgs args, long diseaseId)
        {
            var request = new DiseaseSampleTypeByDiseaseRequestModel()
            {
                idfsDiagnosis = diseaseId,
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                SortOrder = "asc",
                SortColumn = "intOrder"

            };
            SamplesTypes = await ConfigurationClient.GetDiseaseSampleTypeByDiseasePaged(request);
        }

        protected async Task ShowMessageDialog(string message)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(message));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    source?.Cancel();
                    source = new();
                    token = source.Token;
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
            
        }


    }

}
