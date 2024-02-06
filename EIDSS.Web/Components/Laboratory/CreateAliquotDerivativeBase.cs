#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.RequestModels.Laboratory.Freezer;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Laboratory.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class CreateAliquotDerivativeBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CreateAliquotDerivativeBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFreezerClient FreezerClient { get; set; }
        [Inject] private IConfigurationClient ConfigurationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public SampleDivisionTypeEnum FormationType { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public bool IsAliquotDerivativeLoading { get; set; }
        public bool IsDerivativeTypesLoading { get; set; }
        public bool IsDerivativeTypesDisabled { get; set; }
        public bool IsDerivativeTypesValidationVisible { get; set; }
        public EditContext EditContext { get; set; }
        public List<SamplesGetListViewModel> Samples { get; set; }
        public IList<SamplesGetListViewModel> SelectedSamples { get; set; }
        public IList<SamplesGetListViewModel> AliquotDerivativeSamples { get; set; }
        public List<FreezerViewModel> Freezers { get; set; }
        public List<StorageLocationViewModel> StorageLocations { get; set; }
        public List<ConfigurationMatrixViewModel> DerivativeTypes { get; set; }
        public AliquotDerivativeViewModel AliquotDerivative { get; set; } = new();
        public RadzenDataGrid<SamplesGetListViewModel> SamplesGrid;
        public RadzenDataGrid<SamplesGetListViewModel> AliquotDerivativeGrid;
        private IEnumerable<BaseReferenceViewModel> FreezerSubdivisionTypes { get; set; }
        public int SamplesCount { get; set; }
        public SamplesGetListViewModel SampleToDelete { get; set; }
        public bool IsSaveDisabled { get; set; }
        public bool PrintBarcodes { get; set; }

        public bool IsSelected
        {
            get
            {
                _isSelected = false;
                if (Samples != null)
                    _isSelected = Samples.Any(i => SelectedSamples != null && SelectedSamples.Contains(i));

                return _isSelected;
            }
        }

        public bool IsOkDisabled => !IsSelected || AliquotDerivative.NewSampleCount <= 0;

        #endregion

        #region Member Variables

        private bool _isSelected;
        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #region Constants

        public const string CssDisabledBoxLocationCurrent = "disabledBoxLocationCurrent";
        public const string CssDisabledBoxLocation = "disabledBoxLocation";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public CreateAliquotDerivativeBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected CreateAliquotDerivativeBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (Samples is null)
                IsLoading = true;

            switch (FormationType)
            {
                case SampleDivisionTypeEnum.Aliquot:
                    AliquotDerivative.FormationType = (int) SampleDivisionTypeEnum.Aliquot;
                    IsDerivativeTypesDisabled = true;
                    break;
                case SampleDivisionTypeEnum.Derivative:
                    AliquotDerivative.FormationType = (int) SampleDivisionTypeEnum.Derivative;
                    IsDerivativeTypesDisabled = false;
                    break;
                default:
                    IsDerivativeTypesDisabled = true;
                    IsDerivativeTypesValidationVisible = false;
                    break;
            }

            IsSaveDisabled = true;

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    await GetStorageLocations();

                    await JsRuntime.InvokeVoidAsync("LaboratoryCreateSampleDivision.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this));
                }

                await base.OnAfterRenderAsync(firstRender);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        public async Task LoadSamplesData()
        {
            try
            {
                IsLoading = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        Samples = (List<SamplesGetListViewModel>) LaboratoryService.SelectedSamples;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        LaboratoryService.SelectedSamples = new List<SamplesGetListViewModel>();

                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            if (LaboratoryService.Samples is not null &&
                                LaboratoryService.Samples.Any(x => x.SampleID == myFavorite.SampleID))
                                LaboratoryService.SelectedSamples.Add(
                                    LaboratoryService.Samples.First(x => x.SampleID == myFavorite.SampleID));
                            else
                                LaboratoryService.SelectedSamples.Add(await GetSample(myFavorite.SampleID));
                        Samples = (List<SamplesGetListViewModel>) LaboratoryService.SelectedSamples;
                        break;
                }

                SelectedSamples = new List<SamplesGetListViewModel>();
                SamplesCount = !Samples.Any() ? 0 : Samples.Count;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GenerateAliquotDerivativeGrid()
        {
            try
            {
                IsAliquotDerivativeLoading = true;

                AliquotDerivativeSamples ??= new List<SamplesGetListViewModel>();

                if (SelectedSamples is not null)
                {
                    var indexForSampleId = AliquotDerivativeSamples.Count * -1;

                    foreach (var selectedSample in SelectedSamples)
                    {
                        // Has sample previously been divided?
                        var request = new SamplesGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "Query",
                            SortOrder = SortConstants.Ascending,
                            DaysFromAccessionDate = MaxValue - 1,
                            ParentSampleID = selectedSample.SampleID,
                            TestCompletedIndicator = null,
                            TestUnassignedIndicator = null,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                            UserOrganizationID = authenticatedUser.OfficeId,
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                            UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                                ? null
                                : Convert.ToInt64(authenticatedUser.SiteGroupID)
                        };
                        var parentSamples = await LaboratoryClient.GetSamplesList(request, _token);

                        // Set the index to how may times it has already been divided.
                        var index = parentSamples.Count;

                        if (AliquotDerivativeSamples.Count > 0)
                        {
                            var samples = AliquotDerivativeSamples.Where(a =>
                                a.ParentEIDSSLaboratorySampleID == selectedSample.EIDSSLaboratorySampleID);
                            var samplesGetListViewModels = samples.ToList();
                            if (samplesGetListViewModels.Any())
                                index = samplesGetListViewModels
                                    .Select(s => Convert.ToInt32(s.EIDSSLaboratorySampleID[^1..])).Max();
                        }

                        for (var i = 0; i < AliquotDerivative.NewSampleCount; i++)
                        {
                            string sampleTypeName;
                            var sampleTypeId = selectedSample.SampleTypeID;
                            if (AliquotDerivative.FormationType == (int) SampleDivisionTypeEnum.Derivative)
                            {
                                var derivative = DerivativeTypes.FirstOrDefault(d =>
                                    d.idfsDerivativeType == AliquotDerivative.SelectedDerivativeID);
                                if (derivative?.idfsDerivativeType != null)
                                    sampleTypeId = derivative.idfsDerivativeType;
                                sampleTypeName = derivative?.strDerivative;
                            }
                            else
                            {
                                sampleTypeName = selectedSample.SampleTypeName;
                            }

                            var newSample = selectedSample.ShallowCopy();
                            newSample.SampleID = indexForSampleId - 1;
                            newSample.AccessionByPersonID = selectedSample.AccessionByPersonID;
                            newSample.RowAction = (int) RowActionTypeEnum.InsertAliquotDerivative;
                            newSample.ParentEIDSSLaboratorySampleID = selectedSample.EIDSSLaboratorySampleID;
                            newSample.ParentSampleID = selectedSample.SampleID;
                            newSample.RootSampleID = selectedSample.ParentSampleID ?? selectedSample.SampleID;
                            newSample.EIDSSLaboratorySampleID =
                                selectedSample.EIDSSLaboratorySampleID + "-" + (index + 1);
                            newSample.SampleKindTypeID =
                                AliquotDerivative.FormationType == (int) SampleDivisionTypeEnum.Aliquot
                                    ? (long) SampleKindTypeEnum.Aliquot
                                    : (long) SampleKindTypeEnum.Derivative;
                            newSample.SampleTypeID = sampleTypeId;
                            newSample.SampleTypeName = sampleTypeName;

                            if (Tab == LaboratoryTabEnum.MyFavorites)
                                newSample.FavoriteIndicator = true;

                            newSample.ActionPerformedIndicator = true;
                            AliquotDerivativeSamples.Add(newSample);

                            index++;
                            indexForSampleId--;
                        }
                    }
                }

                await AliquotDerivativeGrid.Reload();

                if (AliquotDerivativeSamples.Count > 0) IsSaveDisabled = false;

                IsAliquotDerivativeLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetDerivatives()
        {
            try
            {
                IsDerivativeTypesLoading = true;

                if (SelectedSamples is not null && SelectedSamples.Any())
                {
                    var request = new SampleTypeDerivativeMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsSampleType = SelectedSamples.First().SampleTypeID,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "strDerivative",
                        SortOrder = SortConstants.Ascending
                    };

                    DerivativeTypes = await ConfigurationClient.GetSampleTypeDerivativeMatrixList(request);
                }

                IsDerivativeTypesLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Record Selection Methods

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(SamplesGetListViewModel item)
        {
            try
            {
                if (SelectedSamples != null && SelectedSamples.Any(x => x.SampleID == item.SampleID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected async Task OnRecordSelectionChange(bool? value, SamplesGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = SelectedSamples.First(x => x.SampleID == item.SampleID);

                    SelectedSamples.Remove(item);
                }
                else
                {
                    if (AliquotDerivative.FormationType == (int) SampleDivisionTypeEnum.Derivative && Samples != null &&
                        Samples.GroupBy(x => x.SampleTypeID).Count() > 1)
                        SelectedSamples.Clear();

                    item.FreezerSubdivisionID = null;
                    item.OldFreezerSubdivisionID = null;
                    item.OldStorageBoxPlace = null;
                    item.OldStorageSubdivision = new FreezerSubdivisionViewModel();
                    item.StorageBoxLocation = null;
                    item.StorageBoxPlace = null;
                    SelectedSamples.Add(item);

                    if (AliquotDerivative.FormationType == (int) SampleDivisionTypeEnum.Derivative)
                        await GetDerivatives();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Formation Type Change Event

        /// <summary>
        /// </summary>
        /// <param name="formationType"></param>
        protected void OnFormationTypeChange(int formationType)
        {
            if (AliquotDerivative.FormationType == (int) SampleDivisionTypeEnum.Derivative && Samples != null &&
                Samples.GroupBy(x => x.SampleTypeID).Count() > 1)
                SelectedSamples.Clear();

            IsDerivativeTypesDisabled = formationType != (int) SampleDivisionTypeEnum.Derivative;
            IsDerivativeTypesValidationVisible = !IsDerivativeTypesDisabled;
        }

        #endregion

        #region Delete Row Methods

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected async Task DeleteRow(SamplesGetListViewModel item)
        {
            SampleToDelete = item;

            try
            {
                DiagService.OnClose -= HandleDeleteResponse;
                DiagService.OnClose += HandleDeleteResponse;
                await ShowConfirmDeleteMessage();

                if (!AliquotDerivativeSamples.Any()) IsSaveDisabled = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task ShowConfirmDeleteMessage()
        {
            var buttons = new List<DialogButton>();

            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);

            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };
            buttons.Add(noButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                }
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading),
                dialogParams);
        }

        /// <summary>
        /// </summary>
        /// <param name="result"></param>
        protected async void HandleDeleteResponse(dynamic result)
        {
            result = (DialogReturnResult) result;
            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                try
                {
                    if (AliquotDerivativeSamples.Contains(SampleToDelete))
                    {
                        AliquotDerivativeSamples.Remove(SampleToDelete);
                        await AliquotDerivativeGrid.Reload();
                    }
                    else
                    {
                        AliquotDerivativeGrid.CancelEditRow(SampleToDelete);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                DiagService.OnClose -= HandleDeleteResponse;
                await AliquotDerivativeGrid.Reload();
            }
        }

        #endregion

        #region Save Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnSaveClick")]
        public async Task OnSaveClick()
        {
            try
            {
                var returnCode = await CreateAliquotDerivative(AliquotDerivativeSamples);

                if (returnCode == 0)
                {
                    if (PrintBarcodes)
                    {
                        var samplesList = AliquotDerivativeSamples.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));
                        samplesList = samplesList.Remove(samplesList.Length - 1, 1);
                        await GenerateBarcodeReport(samplesList);
                    }

                    DiagService.Close(returnCode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideSampleDivisionProcessingIndicator", _token)
                    .ConfigureAwait(false);
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnFormSubmit()
        {
            try
            {
                await GenerateAliquotDerivativeGrid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Storage Location Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task GetStorageLocations()
        {
            FreezerSubdivisionTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.FreezerSubdivisionType, HACodeList.NoneHACode);

            Freezers = await GetFreezers();

            LaboratoryService.FreezerSubdivisions ??= new List<FreezerSubdivisionViewModel>();
            StorageLocations = new List<StorageLocationViewModel>();
            var storageLocationId = 1;

            foreach (var f in Freezers)
            {
                StorageLocationViewModel shelfStorageLocation;
                StorageLocationViewModel rackStorageLocation;
                if (f.FreezerID != null)
                {
                    var storageLocation = new StorageLocationViewModel
                    {
                        StorageLocationId = storageLocationId,
                        StorageLocationName = "(" +
                                              Localizer.GetString(FieldLabelResourceKeyConstants
                                                  .FreezerDetailsBuildingFieldLabel) +
                                              (!IsNullOrEmpty(f.Building) ? " " + f.Building : Empty) + " / " +
                                              Localizer.GetString(FieldLabelResourceKeyConstants
                                                  .FreezerDetailsRoomFieldLabel) +
                                              (!IsNullOrEmpty(f.Room) ? " " + f.Room : Empty) + ") " + f.FreezerName,
                        FreezerId = (long) f.FreezerID
                    };

                    FreezerSubdivisionRequestModel subdivisionRequest = new()
                    {
                        LanguageID = GetCurrentLanguage(),
                        SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        FreezerID = f.FreezerID
                    };

                    StorageLocations.Add(storageLocation);

                    if (LaboratoryService.FreezerSubdivisions.All(x => x.FreezerID != f.FreezerID))
                        LaboratoryService.FreezerSubdivisions.AddRange(
                            await FreezerClient.GetFreezerSubdivisionList(subdivisionRequest));

                    foreach (var location in LaboratoryService.FreezerSubdivisions.Where(x =>
                                 x.FreezerID == f.FreezerID && x.SubdivisionTypeID == (long) SubdivisionTypes.Shelf))
                    {
                        storageLocationId += 1;
                        shelfStorageLocation = new StorageLocationViewModel
                        {
                            StorageLocationId = storageLocationId,
                            FreezerId = (long) location.FreezerID,
                            SubdivisionId = (long) location.FreezerSubdivisionID,
                            StorageLocationName = location.FreezerSubdivisionName,
                            StorageTypeId = (long) SubdivisionTypes.Shelf
                        };

                        foreach (var rackLocation in LaboratoryService.FreezerSubdivisions.Where(x =>
                                     x.FreezerID == f.FreezerID &&
                                     x.ParentFreezerSubdivisionID == shelfStorageLocation.SubdivisionId))
                        {
                            storageLocationId += 1;
                            rackStorageLocation = new StorageLocationViewModel
                            {
                                StorageLocationId = storageLocationId,
                                FreezerId = (long) rackLocation.FreezerID,
                                SubdivisionId = (long) rackLocation.FreezerSubdivisionID,
                                StorageLocationName = rackLocation.FreezerSubdivisionName,
                                StorageTypeId = (long) SubdivisionTypes.Rack
                            };

                            foreach (var boxLocation in LaboratoryService.FreezerSubdivisions.Where(x =>
                                         x.FreezerID == f.FreezerID && x.ParentFreezerSubdivisionID ==
                                         rackStorageLocation.SubdivisionId))
                            {
                                storageLocationId += 1;
                                if (boxLocation.FreezerSubdivisionID == null) continue;
                                if (boxLocation.FreezerID == null) continue;
                                var boxStorageLocation = new StorageLocationViewModel
                                {
                                    StorageLocationId = storageLocationId,
                                    FreezerId = (long) boxLocation.FreezerID,
                                    SubdivisionId = (long) boxLocation.FreezerSubdivisionID,
                                    StorageLocationName = boxLocation.FreezerSubdivisionName,
                                    StorageTypeId = (long) SubdivisionTypes.Box
                                };

                                rackStorageLocation.Children ??= new List<StorageLocationViewModel>();
                                rackStorageLocation.Children.Add(boxStorageLocation);
                            }

                            shelfStorageLocation.Children ??= new List<StorageLocationViewModel>();
                            shelfStorageLocation.Children.Add(rackStorageLocation);
                        }

                        storageLocation.Children ??= new List<StorageLocationViewModel>();
                        storageLocation.Children.Add(shelfStorageLocation);
                    }
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="sample"></param>
        /// <returns></returns>
        public bool ShouldSelectThisNode(object value, SamplesGetListViewModel sample)
        {
            if (sample?.FreezerSubdivisionID == null) return false;
            var box = new FreezerSubdivisionViewModel();
            var rack = new FreezerSubdivisionViewModel();
            var shelf = new FreezerSubdivisionViewModel();

            if (LaboratoryService.FreezerSubdivisions.Any(x =>
                    x.FreezerSubdivisionID == sample.FreezerSubdivisionID))
            {
                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == sample.FreezerSubdivisionID))
                    box = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == sample.FreezerSubdivisionID);

                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID))
                    rack = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID);

                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID))
                    shelf = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID);
            }

            if (value is not StorageLocationViewModel location) return false;

            if (location.StorageTypeId is null && shelf.FreezerID == location.FreezerId)
                return true;

            return location.StorageTypeId switch
            {
                (long) FreezerSubdivisionTypeEnum.Shelf when location.SubdivisionId == shelf.FreezerSubdivisionID =>
                    true,
                (long) FreezerSubdivisionTypeEnum.Rack when location.SubdivisionId == rack.FreezerSubdivisionID => true,
                (long) FreezerSubdivisionTypeEnum.Box when location.SubdivisionId == box.FreezerSubdivisionID => true,
                _ => false
            };
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task<List<FreezerViewModel>> GetFreezers()
        {
            FreezerRequestModel request = new()
            {
                LanguageID = GetCurrentLanguage(),
                SiteList = authenticatedUser.SiteId,
                FreezerName = null,
                Note = null,
                StorageTypeID = null,
                Building = null,
                Room = null,
                SearchString = null,
                PaginationSet = 1,
                PageSize = 9999,
                MaxPagesPerFetch = 9999
            };

            return await FreezerClient.GetFreezerList(request);
        }

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        /// <param name="boxPlace"></param>
        public void SetStorageBoxPlace(SamplesGetListViewModel sample, string boxPlace)
        {
            sample.OldStorageBoxPlace = sample.StorageBoxPlace;
            sample.StorageBoxPlace = boxPlace;

            List<FreezerSubdivisionBoxLocationAvailability> oldBoxPlaceAvailability = null;

            if (!IsNullOrEmpty(sample.OldStorageBoxPlace))
            {
                if (sample.FreezerSubdivisionID is not null &&
                    LaboratoryService.FreezerSubdivisions.Any(
                        x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID))
                    oldBoxPlaceAvailability =
                        JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(LaboratoryService
                            .FreezerSubdivisions.First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                            .BoxPlaceAvailability);

                if (oldBoxPlaceAvailability is not null)
                    foreach (var slot in oldBoxPlaceAvailability.Where(slot =>
                                 slot.BoxLocation == sample.OldStorageBoxPlace.Replace("-", "")))
                    {
                        slot.AvailabilityIndicator = true;
                        break;
                    }
            }

            sample.OldFreezerSubdivisionID = sample.FreezerSubdivisionID;
            sample.FreezerSubdivisionID = sample.SelectedStorageLocationId;

            if (sample.OldFreezerSubdivisionID == sample.SelectedStorageLocationId)
            {
                if (oldBoxPlaceAvailability != null)
                {
                    foreach (var slot in oldBoxPlaceAvailability.Where(
                                 slot => slot.BoxLocation == boxPlace.Replace("-", "")))
                    {
                        slot.AvailabilityIndicator = false;
                        break;
                    }

                    if (LaboratoryService.FreezerSubdivisions
                            .Any(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID) && LaboratoryService
                            .FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID)
                            .BoxPlaceAvailability is not null)
                    {
                        LaboratoryService.FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID)
                            .BoxPlaceAvailability = JsonConvert.SerializeObject(oldBoxPlaceAvailability);
                        LaboratoryService.FreezerSubdivisions.First(x =>
                                x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID).RowAction =
                            RowActionTypeEnum.Update.ToString();
                    }
                }
            }
            else
            {
                foreach (var slot in sample.BoxLocationAvailability.Where(
                             slot => slot.BoxLocation == boxPlace.Replace("-", "")))
                {
                    slot.AvailabilityIndicator = false;
                    break;
                }

                if (LaboratoryService.FreezerSubdivisions
                        .Any(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID) && LaboratoryService
                        .FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID)
                        .BoxPlaceAvailability is not null)
                {
                    LaboratoryService.FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID)
                        .BoxPlaceAvailability = JsonConvert.SerializeObject(oldBoxPlaceAvailability);
                    LaboratoryService.FreezerSubdivisions.First(x =>
                            x.FreezerSubdivisionID == sample.OldFreezerSubdivisionID).RowAction =
                        RowActionTypeEnum.Update.ToString();
                }

                if (LaboratoryService.FreezerSubdivisions
                        .Any(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID) && LaboratoryService
                        .FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                        .BoxPlaceAvailability is not null)
                {
                    LaboratoryService.FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID)
                        .BoxPlaceAvailability = JsonConvert.SerializeObject(sample.BoxLocationAvailability);
                    LaboratoryService.FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == sample.FreezerSubdivisionID).RowAction =
                        RowActionTypeEnum.Update.ToString();
                }
            }

            var box = new FreezerSubdivisionViewModel();
            var rack = new FreezerSubdivisionViewModel();
            var shelf = new FreezerSubdivisionViewModel();

            if (LaboratoryService.FreezerSubdivisions.Any(x =>
                    x.FreezerSubdivisionID == sample.FreezerSubdivisionID))
            {
                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == sample.FreezerSubdivisionID))
                    box = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == sample.FreezerSubdivisionID);

                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID))
                    rack = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID);

                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID))
                    shelf = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID);
            }

            sample.StorageBoxLocation =
                Freezers.First(x => x.FreezerID == box.FreezerID).FreezerName;

            sample.StorageBoxLocation += " " +
                                         FreezerSubdivisionTypes.First(x =>
                                             x.IdfsBaseReference ==
                                             (long) FreezerSubdivisionTypeEnum.Shelf).Name +
                                         " #" +
                                         shelf.FreezerSubdivisionName;

            sample.StorageBoxLocation += " " +
                                         FreezerSubdivisionTypes.First(x =>
                                             x.IdfsBaseReference ==
                                             (long) FreezerSubdivisionTypeEnum.Rack).Name +
                                         " #" +
                                         rack.FreezerSubdivisionName;

            if (sample.StorageBoxPlace != null)
            {
                sample.StorageBoxLocation += " " +
                                             FreezerSubdivisionTypes.First(x =>
                                                 x.IdfsBaseReference ==
                                                 (long) FreezerSubdivisionTypeEnum.Box).Name +
                                             " #" +
                                             sample.StorageBoxPlace;


                sample.OldStorageBoxPlace ??= sample.StorageBoxPlace;
            }

            AliquotDerivativeSamples.First(x => x.SampleID == sample.SampleID).FreezerSubdivisionID =
                sample.SelectedStorageLocationId;
            AliquotDerivativeSamples.First(x => x.SampleID == sample.SampleID).StorageBoxPlace = boxPlace;

            StateHasChanged();

            foreach (var item in AliquotDerivativeSamples)
            {
                if (item.SelectedStorageLocationId == sample.SelectedStorageLocationId)
                    item.BoxLocationAvailability = sample.BoxLocationAvailability;

                if (item.SelectedStorageLocationId != 0)
                    OnStorageLocationChange(new TreeEventArgs { Value = new StorageLocationViewModel { StorageTypeId = (long) FreezerSubdivisionTypeEnum.Box, SubdivisionId = item.FreezerSubdivisionID }}, item);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <param name="sample"></param>
        public void OnStorageLocationChange(TreeEventArgs args, SamplesGetListViewModel sample)
        {
            try
            {
                if (args.Value is not StorageLocationViewModel
                    {
                        StorageTypeId: (long) FreezerSubdivisionTypeEnum.Box
                    } freezerSubdivision) return;
                if (freezerSubdivision.SubdivisionId != null)
                    sample.SelectedStorageLocationId = (long) freezerSubdivision.SubdivisionId;

                var boxPlaceAvailability = LaboratoryService.FreezerSubdivisions
                    .First(x =>
                        x.FreezerSubdivisionID == sample.SelectedStorageLocationId)
                    .BoxPlaceAvailability;
                if (boxPlaceAvailability == null) return;
                {
                    sample.BoxSizeTypeName = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == sample.SelectedStorageLocationId).BoxSizeTypeName;
                    sample.BoxLocationAvailability =
                        JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(
                            boxPlaceAvailability);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}