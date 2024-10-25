#region Usings

using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory.Freezer;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Laboratory.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class SampleDetailsBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SampleDetailsBase> Logger { get; set; }
        [Inject] private IFreezerClient FreezerClient { get; set; }
        [Inject] private IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SamplesGetListViewModel Sample { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<SamplesGetListViewModel> Form { get; set; }
        public List<FreezerViewModel> Freezers { get; set; }
        public List<StorageLocationViewModel> StorageLocations { get; set; }
        private IEnumerable<BaseReferenceViewModel> FreezerSubdivisionTypes { get; set; }
        public long SelectedStorageLocationId { get; set; }
        public List<FreezerSubdivisionBoxLocationAvailability> BoxLocationAvailability { get; set; }
        public string BoxSizeTypeName { get; set; }
        public long? OriginalFreezerSubdivisionId { get; set; }
        public string OriginalStorageBoxPlace { get; set; }
        public string OriginalStorageLocation { get; set; }
        public bool CanModifyAccessionDatePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }

        #endregion

        #region Constants

        public const string CssDisabledBoxLocationCurrent = "disabledBoxLocationCurrent";
        public const string CssDisabledBoxLocation = "disabledBoxLocation";

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public SampleDetailsBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected SampleDetailsBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();
                _userPermissions = GetUserPermissions(PagePermission.CanModifyAccessionDateAfterSave);
                CanModifyAccessionDatePermissionIndicator = _userPermissions.Execute;
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
                WritePermissionIndicator = _userPermissions.Write;

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await GetStorageLocations();

                Sample.OldFreezerSubdivisionID = Sample.FreezerSubdivisionID;
                Sample.OldStorageBoxPlace = Sample.StorageBoxPlace;
                OriginalFreezerSubdivisionId = Sample.FreezerSubdivisionID;
                OriginalStorageBoxPlace = Sample.StorageBoxPlace;

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            _disposedValue = true;
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

            if (LaboratoryService.FreezerSubdivisions.Count > 0)
                if (Sample.FreezerSubdivisionID != null)
                {
                    var box = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == Sample.FreezerSubdivisionID);
                    var rack = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID);
                    var shelf = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID);

                    Sample.StorageBoxLocation =
                        Freezers.First(x => x.FreezerID == box.FreezerID).FreezerName;

                    Sample.StorageBoxLocation += " " +
                                                 FreezerSubdivisionTypes.First(x =>
                                                     x.IdfsBaseReference ==
                                                     (long) FreezerSubdivisionTypeEnum.Shelf).Name +
                                                 " #" +
                                                 shelf.FreezerSubdivisionName;

                    Sample.StorageBoxLocation += " " +
                                                 FreezerSubdivisionTypes.First(x =>
                                                     x.IdfsBaseReference ==
                                                     (long) FreezerSubdivisionTypeEnum.Rack).Name +
                                                 " #" +
                                                 rack.FreezerSubdivisionName;

                    if (Sample.StorageBoxPlace != null)
                        Sample.StorageBoxLocation += " " +
                                                     FreezerSubdivisionTypes.First(x =>
                                                         x.IdfsBaseReference ==
                                                         (long) FreezerSubdivisionTypeEnum.Box).Name +
                                                     " #" +
                                                     Sample.StorageBoxPlace;
                }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public bool ShouldSelectThisNode(object value)
        {
            if (Sample?.FreezerSubdivisionID == null) return false;
            var box = new FreezerSubdivisionViewModel();
            var rack = new FreezerSubdivisionViewModel();
            var shelf = new FreezerSubdivisionViewModel();

            if (LaboratoryService.FreezerSubdivisions.Any(x =>
                    x.FreezerSubdivisionID == Sample.FreezerSubdivisionID))
            {
                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == Sample.FreezerSubdivisionID))
                    box = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == Sample.FreezerSubdivisionID);

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
                PaginationSet = 1,
                PageSize = 9999,
                MaxPagesPerFetch = 9999
            };

            return await FreezerClient.GetFreezerList(request);
        }

        /// <summary>
        /// </summary>
        /// <param name="boxPlace"></param>
        public void SetStorageBoxPlace(string boxPlace)
        {
            Sample.OldStorageBoxPlace = Sample.StorageBoxPlace;
            Sample.StorageBoxPlace = boxPlace;

            List<FreezerSubdivisionBoxLocationAvailability> oldBoxPlaceAvailability = null;

            if (!IsNullOrEmpty(Sample.OldStorageBoxPlace) || boxPlace is null)
            {
                if (boxPlace is null && LaboratoryService.FreezerSubdivisions.Any(
                        x => x.FreezerSubdivisionID == SelectedStorageLocationId))
                    oldBoxPlaceAvailability =
                        JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(
                            LaboratoryService
                                .FreezerSubdivisions.First(x => x.FreezerSubdivisionID == SelectedStorageLocationId)
                                .BoxPlaceAvailability);
                else if (Sample.FreezerSubdivisionID is not null &&
                         LaboratoryService.FreezerSubdivisions.Any(
                             x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID))
                    oldBoxPlaceAvailability =
                        JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(LaboratoryService
                            .FreezerSubdivisions.First(x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID)
                            .BoxPlaceAvailability);

                if (oldBoxPlaceAvailability is not null)
                    foreach (var slot in oldBoxPlaceAvailability.Where(slot =>
                                 slot.BoxLocation == Sample.OldStorageBoxPlace.Replace("-", "")))
                    {
                        slot.AvailabilityIndicator = true;
                        break;
                    }
            }

            Sample.OldFreezerSubdivisionID = Sample.FreezerSubdivisionID;
            Sample.FreezerSubdivisionID = SelectedStorageLocationId;

            if (Sample.OldFreezerSubdivisionID == SelectedStorageLocationId || boxPlace is null)
            {
                if (oldBoxPlaceAvailability != null)
                {
                    if (boxPlace is null)
                    {
                        if (LaboratoryService.FreezerSubdivisions
                                .Any(x => x.FreezerSubdivisionID == SelectedStorageLocationId) && LaboratoryService
                                .FreezerSubdivisions
                                .First(x => x.FreezerSubdivisionID == SelectedStorageLocationId)
                                .BoxPlaceAvailability is not null)
                        {
                            LaboratoryService.FreezerSubdivisions
                                .First(x => x.FreezerSubdivisionID == SelectedStorageLocationId)
                                .BoxPlaceAvailability = JsonConvert.SerializeObject(oldBoxPlaceAvailability);
                            LaboratoryService.FreezerSubdivisions.First(x =>
                                    x.FreezerSubdivisionID == SelectedStorageLocationId).RowAction =
                                RowActionTypeEnum.Update.ToString();
                        }

                        if (OriginalStorageBoxPlace is not null)
                        {
                            var boxPlaceAvailability = LaboratoryService.FreezerSubdivisions
                                .First(x =>
                                    x.FreezerSubdivisionID == OriginalFreezerSubdivisionId)
                                .BoxPlaceAvailability;

                            if (boxPlaceAvailability is not null)
                            {
                                var originalBoxLocationAvailability =
                                    JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(
                                        boxPlaceAvailability);

                                foreach (var slot in originalBoxLocationAvailability.Where(
                                             slot => slot.BoxLocation == OriginalStorageBoxPlace.Replace("-", "")))
                                {
                                    slot.AvailabilityIndicator = false;
                                    break;
                                }

                                if (LaboratoryService.FreezerSubdivisions
                                        .Any(x => x.FreezerSubdivisionID == OriginalFreezerSubdivisionId) &&
                                    LaboratoryService
                                        .FreezerSubdivisions
                                        .First(x => x.FreezerSubdivisionID == OriginalFreezerSubdivisionId)
                                        .BoxPlaceAvailability is not null)
                                    LaboratoryService.FreezerSubdivisions
                                            .First(x => x.FreezerSubdivisionID == OriginalFreezerSubdivisionId)
                                            .BoxPlaceAvailability =
                                        JsonConvert.SerializeObject(originalBoxLocationAvailability);
                            }
                        }
                    }
                    else
                    {
                        foreach (var slot in oldBoxPlaceAvailability.Where(
                                     slot => slot.BoxLocation == boxPlace.Replace("-", "")))
                        {
                            slot.AvailabilityIndicator = false;
                            break;
                        }

                        if (LaboratoryService.FreezerSubdivisions
                                .Any(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID) && LaboratoryService
                                .FreezerSubdivisions
                                .First(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID)
                                .BoxPlaceAvailability is not null)
                        {
                            LaboratoryService.FreezerSubdivisions
                                .First(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID)
                                .BoxPlaceAvailability = JsonConvert.SerializeObject(oldBoxPlaceAvailability);
                            LaboratoryService.FreezerSubdivisions.First(x =>
                                    x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID).RowAction =
                                RowActionTypeEnum.Update.ToString();
                        }
                    }
                }
            }
            else
            {
                foreach (var slot in BoxLocationAvailability.Where(
                             slot => slot.BoxLocation == boxPlace.Replace("-", "")))
                {
                    slot.AvailabilityIndicator = false;
                    break;
                }

                if (LaboratoryService.FreezerSubdivisions
                        .Any(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID) && LaboratoryService
                        .FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID)
                        .BoxPlaceAvailability is not null)
                {
                    LaboratoryService.FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID)
                        .BoxPlaceAvailability = JsonConvert.SerializeObject(oldBoxPlaceAvailability);
                    LaboratoryService.FreezerSubdivisions.First(x =>
                            x.FreezerSubdivisionID == Sample.OldFreezerSubdivisionID).RowAction =
                        RowActionTypeEnum.Update.ToString();
                }

                if (LaboratoryService.FreezerSubdivisions
                        .Any(x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID) && LaboratoryService
                        .FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID)
                        .BoxPlaceAvailability is not null)
                {
                    LaboratoryService.FreezerSubdivisions
                        .First(x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID)
                        .BoxPlaceAvailability = JsonConvert.SerializeObject(BoxLocationAvailability);
                    LaboratoryService.FreezerSubdivisions
                            .First(x => x.FreezerSubdivisionID == Sample.FreezerSubdivisionID).RowAction =
                        RowActionTypeEnum.Update.ToString();
                }
            }

            if (boxPlace is null) return;
            {
                var box = new FreezerSubdivisionViewModel();
                var rack = new FreezerSubdivisionViewModel();
                var shelf = new FreezerSubdivisionViewModel();

                if (LaboratoryService.FreezerSubdivisions.Any(x =>
                        x.FreezerSubdivisionID == Sample.FreezerSubdivisionID))
                {
                    if (LaboratoryService.FreezerSubdivisions.Any(x =>
                            x.FreezerSubdivisionID == Sample.FreezerSubdivisionID))
                        box = LaboratoryService.FreezerSubdivisions.First(x =>
                            x.FreezerSubdivisionID == Sample.FreezerSubdivisionID);

                    if (LaboratoryService.FreezerSubdivisions.Any(x =>
                            x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID))
                        rack = LaboratoryService.FreezerSubdivisions.First(x =>
                            x.FreezerSubdivisionID == box.ParentFreezerSubdivisionID);

                    if (LaboratoryService.FreezerSubdivisions.Any(x =>
                            x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID))
                        shelf = LaboratoryService.FreezerSubdivisions.First(x =>
                            x.FreezerSubdivisionID == rack.ParentFreezerSubdivisionID);
                }

                Sample.StorageBoxLocation =
                    Freezers.First(x => x.FreezerID == box.FreezerID).FreezerName;

                Sample.StorageBoxLocation += " " +
                                             FreezerSubdivisionTypes.First(x =>
                                                 x.IdfsBaseReference ==
                                                 (long) FreezerSubdivisionTypeEnum.Shelf).Name +
                                             " #" +
                                             shelf.FreezerSubdivisionName;

                Sample.StorageBoxLocation += " " +
                                             FreezerSubdivisionTypes.First(x =>
                                                 x.IdfsBaseReference ==
                                                 (long) FreezerSubdivisionTypeEnum.Rack).Name +
                                             " #" +
                                             rack.FreezerSubdivisionName;

                if (Sample.StorageBoxPlace != null)
                {
                    Sample.StorageBoxLocation += " " +
                                                 FreezerSubdivisionTypes.First(x =>
                                                     x.IdfsBaseReference ==
                                                     (long) FreezerSubdivisionTypeEnum.Box).Name +
                                                 " #" +
                                                 Sample.StorageBoxPlace;


                    Sample.OldStorageBoxPlace ??= Sample.StorageBoxPlace;
                }

                StateHasChanged();

                if (SelectedStorageLocationId != 0)
                    OnStorageLocationChange(new TreeEventArgs
                    {
                        Value = new StorageLocationViewModel
                        {
                            StorageTypeId = (long) FreezerSubdivisionTypeEnum.Box,
                            SubdivisionId = Sample.FreezerSubdivisionID
                        }
                    });
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        public void OnStorageLocationChange(TreeEventArgs args)
        {
            try
            {
                if (args.Value is not StorageLocationViewModel
                    {
                        StorageTypeId: (long) FreezerSubdivisionTypeEnum.Box
                    } freezerSubdivision) return;
                if (freezerSubdivision.SubdivisionId != null)
                    SelectedStorageLocationId = (long) freezerSubdivision.SubdivisionId;

                var boxPlaceAvailability = LaboratoryService.FreezerSubdivisions
                    .First(x =>
                        x.FreezerSubdivisionID == SelectedStorageLocationId)
                    .BoxPlaceAvailability;
                if (boxPlaceAvailability == null) return;
                {
                    BoxSizeTypeName = LaboratoryService.FreezerSubdivisions.First(x =>
                        x.FreezerSubdivisionID == SelectedStorageLocationId).BoxSizeTypeName;
                    BoxLocationAvailability =
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

        /// <summary>
        /// </summary>
        protected async Task OnReportSessionClick()
        {
            var uri = "";
            if (Sample.HumanDiseaseReportID is not null)
            {
                uri = $"{NavManager.BaseUri}Human/HumanDiseaseReport/SelectForReadOnly/{Sample.HumanDiseaseReportID}";
            }
            else if (Sample.VeterinaryDiseaseReportID is not null)
            {
                DiseaseReportGetDetailRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "EIDSSReportID",
                    SortOrder = SortConstants.Ascending,
                    DiseaseReportID = (long) Sample.VeterinaryDiseaseReportID
                };
                var diseaseReport =
                    (await VeterinaryClient.GetDiseaseReportDetail(request, _token).ConfigureAwait(false)).First();
                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                var query =
                    $"?reportTypeID={diseaseReport.ReportTypeID}&farmID={diseaseReport.FarmID}&diseaseReportID={Sample.VeterinaryDiseaseReportID}&isReadOnly=true";
                uri = $"{NavManager.BaseUri}{path}{query}";
            }
            else if (Sample.VectorSessionID is not null)
            {
                const string path = "Vector/VectorSurveillanceSession/Edit";
                var query = $"?sessionKey={Sample.VectorSessionID}&isReadOnly=true";
                uri = $"{NavManager.BaseUri}{path}{query}";
            }

            NavManager.NavigateTo(uri, true);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnCancel()
        {
            //Sample.FreezerSubdivisionID = OriginalFreezerSubdivisionId;

            SetStorageBoxPlace(null);

            Sample.StorageBoxPlace = OriginalStorageBoxPlace;
            Sample.StorageBoxLocation = OriginalStorageLocation;
            Sample.FreezerSubdivisionID = OriginalFreezerSubdivisionId;
        }

        #endregion
    }
}