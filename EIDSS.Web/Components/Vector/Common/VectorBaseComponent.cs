using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Administration;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using static System.String;
using Radzen;

namespace EIDSS.Web.Components.Vector.Common
{
    public class VectorBaseComponent : BaseComponent
    {
        #region Globals



        #region Dependencies

        [Inject]
        protected VectorSessionStateContainer VectorSessionStateContainer { get; set; }

        [Inject]
        protected ISiteClient SiteClient { get; set; }

        [Inject]
        protected IVectorClient VectorClient { get; set; }

        [Inject]
        protected IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ILogger<VectorBaseComponent> Logger { get; set; }

        [Inject] private INotificationSiteAlertService NotificationSiteAlertService { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        #endregion Dependencies

        #region Member Variables

        private bool _disposedValue;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Enumerations

        public enum VectorTabs
        {
            VectorSessionTab = 0,
            DetailedCollectionsTab = 1,
            AggregateCollectionsTab = 2
        }

        #endregion Enumerations

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            _source = new();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            return base.OnInitializedAsync();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
        }

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion Lifecycle Methods

        #region Initialize Detailed Collection

        public void InitializeDetailedCollection()
        {
            VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = false;
            VectorSessionStateContainer.VectorDetailedCollectionKey = null;
            VectorSessionStateContainer.DetailRowAction = (int)RowActionTypeEnum.Read;
            VectorSessionStateContainer.DetailRowStatus = (int)RowStatusTypeEnum.Active;

            // set detailed collection fields to defaults
            VectorSessionStateContainer.DetailBasisOfRecordID = null;
            VectorSessionStateContainer.DetailCollectedByInstitutionID = null;
            VectorSessionStateContainer.DetailCollectedByPersonID = null;
            VectorSessionStateContainer.DetailCollectionMethodID = null;
            VectorSessionStateContainer.DetailCollectionTimePeriodID = null;
            VectorSessionStateContainer.DetailCollectionDate = null;
            VectorSessionStateContainer.DetailComment = null;
            VectorSessionStateContainer.DetailEctoparasitesCollectedID = null;
            VectorSessionStateContainer.DetailFieldPoolVectorID = null;
            VectorSessionStateContainer.DetailFieldSessionID = null;
            VectorSessionStateContainer.DetailForeignAddress = null;
            VectorSessionStateContainer.DetailGeoLocationTypeID = EIDSSConstants.GeoLocationTypes.ExactPoint;
            VectorSessionStateContainer.DetailGeoReferenceSource = null;
            VectorSessionStateContainer.DetailHostReferenceID = null;
            VectorSessionStateContainer.DetailIdentifiedByInstitutionID = null;
            VectorSessionStateContainer.DetailIdentifiedByMethodID = null;
            VectorSessionStateContainer.DetailIdentifiedByPersonID = null;
            VectorSessionStateContainer.DetailIdentifiedDate = null;
            VectorSessionStateContainer.DetailObservationID = null;
            VectorSessionStateContainer.DetailQuantity = null;
            VectorSessionStateContainer.DetailSpeciesID = null;
            VectorSessionStateContainer.DetailVectorTypeID = null;
            VectorSessionStateContainer.DetailedCollectionsSamplesList = null;
            VectorSessionStateContainer.DetailedCollectionsFieldTestsList = null;

            // flex form
            VectorSessionStateContainer.VectorFlexForm = new FlexFormQuestionnaireGetRequestModel();

            // populate the address from the surveillance session by default
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value = null;
            VectorSessionStateContainer.DetailLocationViewModel.Apartment = null;
            VectorSessionStateContainer.DetailLocationViewModel.Building = null;
            VectorSessionStateContainer.DetailLocationViewModel.House = null;
            VectorSessionStateContainer.DetailLocationViewModel.Street = null;
            VectorSessionStateContainer.DetailLocationViewModel.StreetText = null;
            VectorSessionStateContainer.DetailLocationViewModel.PostalCode = null;
            VectorSessionStateContainer.DetailLocationViewModel.Latitude = null;
            VectorSessionStateContainer.DetailLocationViewModel.Longitude = null;
            VectorSessionStateContainer.DetailLocationViewModel.SettlementId = null;
            VectorSessionStateContainer.DetailForeignAddress = null;
            VectorSessionStateContainer.DetailLocationDirection = null;
            VectorSessionStateContainer.DetailLocationDistance = null;
            VectorSessionStateContainer.DetailLocationGroundTypeID = null;
            VectorSessionStateContainer.DetailLocationDescription = null;
        }

        #endregion Initialize Detailed Collection

        #region Initialize Aggregate Collection

        public void InitializeAggregateCollection()
        {
            VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = false;
            VectorSessionStateContainer.VectorSessionSummaryKey = null;
            VectorSessionStateContainer.SummaryRowStatus = (int)RowStatusTypes.Active;
            VectorSessionStateContainer.SummaryRowAction = (int)RowActionTypeEnum.Read;

            // set aggregate collection fields to defaults
            VectorSessionStateContainer.SummaryCollectionDateTime = null;
            VectorSessionStateContainer.SummaryForeignAddress = null;
            VectorSessionStateContainer.SummaryGeoLocationTypeID = null;
            VectorSessionStateContainer.SummaryInfoSexID = null;
            VectorSessionStateContainer.SummaryInfoSpeciesID = null;
            VectorSessionStateContainer.SummaryRecordID = null;
            VectorSessionStateContainer.PoolsAndVectors = null;
            VectorSessionStateContainer.SummaryVectorTypeID = null;

            // populate the address from the surveillance session by default
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel4Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel5Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel6Value = null;
            VectorSessionStateContainer.SummaryLocationViewModel.Apartment = null;
            VectorSessionStateContainer.SummaryLocationViewModel.Building = null;
            VectorSessionStateContainer.SummaryLocationViewModel.House = null;
            VectorSessionStateContainer.SummaryLocationViewModel.Street = null;
            VectorSessionStateContainer.SummaryLocationViewModel.StreetText = null;
            VectorSessionStateContainer.SummaryLocationViewModel.PostalCode = null;
            VectorSessionStateContainer.SummaryLocationViewModel.Latitude = null;
            VectorSessionStateContainer.SummaryLocationViewModel.Longitude = null;
            VectorSessionStateContainer.SummaryLocationViewModel.SettlementId = null;
            VectorSessionStateContainer.SummaryForeignAddress = null;
            VectorSessionStateContainer.SummaryLocationDirection = null;
            VectorSessionStateContainer.SummaryLocationDistance = null;
            VectorSessionStateContainer.SummaryLocationGroundTypeID = null;
            VectorSessionStateContainer.SummaryLocationDescription = null;
        }

        #endregion Initialize Aggregate Collection

        #region OnCancel Method

        /// <summary>
        /// Cancels from any of the 3
        /// cancel buttons.
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnCancel")]
        public async Task OnCancel()
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);
                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();
                        _source?.Cancel();
                        var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession";
                        NavManager.NavigateTo(uri, true);
                    }
                    else
                    {
                        DiagService.Close(result);
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
        }

        #endregion OnCancel Method

        #region OnDelete Method

        /// <summary>
        /// Deletes the surveillance session only.
        /// (Collections are deleted from the lists.
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnDelete")]
        public async Task OnDelete()
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);
                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        var response = await VectorClient.DeleteVectorSurveillanceSessionAsync(VectorSessionStateContainer.VectorSessionKey.GetValueOrDefault(), _token);
                        switch (response.ReturnCode)
                        {
                            case 0:
                                await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                    null);
                                DiagService.Close();
                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession";

                                NavManager.NavigateTo(uri, true);
                                break;

                            case 1:
                                await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                    null);
                                break;

                            case 2:
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants.VectorSurveillanceSessionUnableToDeleteDependentOnAnotherObjectMessage, null);
                                break;
                        }
                    }
                    else
                    {
                        DiagService.Close(result);
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
        }

        #endregion OnDelete Method

        #region OnSave Method

        /// <summary>
        /// Saves the session, aggregate collections,
        /// and detailed collections from any of the
        /// 3 save buttons.
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public async Task OnSave()
        {
            try
            {
                bool validAggregate;
                if (VectorSessionStateContainer.AggregateCollectionsModifiedIndicator)
                {
                    validAggregate = VectorSessionStateContainer.AggregateCollectionsValidIndicator &
                                     VectorSessionStateContainer.AggregateCollectionLocationValidIndicator;
                }
                else
                {
                    validAggregate = true;
                }

                bool validDetail;
                if (VectorSessionStateContainer.DetailedCollectionsModifiedIndicator)
                {
                    validDetail = VectorSessionStateContainer.DetailCollectionsValidIndicator &
                                  VectorSessionStateContainer.DetailCollectionsVectorDataValidIndicator;
                }
                else
                {
                    validDetail = true;
                }

                if (!VectorSessionStateContainer.SessionSummaryValidIndicator ||
                    !VectorSessionStateContainer.SessionLocationValidIndicator ||
                    !validAggregate ||
                    !validDetail
                   )
                    return;

                VectorSessionStateContainer.PendingSaveEvents ??=
                    new List<Domain.RequestModels.Administration.EventSaveRequestModel>();

                // save the aggregate collection to memory first
                // if the user clicked save on the aggregate collection
                // tab
                if (VectorSessionStateContainer.AggregateCollectionsModifiedIndicator)
                {
                    SaveAggregateCollection();
                    VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = false;
                }

                // save the detailed collection to memory first
                // if the user clicked save on the detailed collection
                // tab
                if (VectorSessionStateContainer.DetailedCollectionsModifiedIndicator)
                {
                    SaveDetailedCollection();
                    VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = false;
                }

                var result = await SaveSurveillanceSession();

                if (result != null)
                {
                    dynamic dialogResult = null;

                    if (result.ReturnCode == 0)
                    {
                        if (VectorSessionStateContainer.VectorSessionKey == 0)
                        {
                            var message = Format(Localizer.GetString(MessageResourceKeyConstants.VectorSurveillanceSessionNewSessionSavedSuccessfullyMessage), result.SessionID);

                            if (VectorSessionStateContainer.OutbreakKey is null)
                            {
                                dialogResult = await ShowSuccessDialog(null, message, null,
                                    ButtonResourceKeyConstants.ReturnToDashboardButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturnToVectorSurveillanceSessionButton);
                            }
                            else
                            {
                                dialogResult = await ShowSuccessDialogWithOutbreak(null, message,
                                    ButtonResourceKeyConstants.ReturnToDashboardButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturnToVectorSurveillanceSessionButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturntoOutbreakSessionButtonText);
                            }
                        }
                        else
                        {
                            if (VectorSessionStateContainer.OutbreakKey is null)
                            {
                                dialogResult = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                    null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturnToVectorSurveillanceSessionButton);
                            }
                            else
                            {
                                dialogResult = await ShowSuccessDialogWithOutbreak(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                                    null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturnToVectorSurveillanceSessionButton,
                                    ButtonResourceKeyConstants.VectorSurveillanceSessionReturntoOutbreakSessionButtonText);
                            }
                        }
                    }

                    if (dialogResult is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText ==
                            Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                        {
                            DiagService.Close();

                            _source?.Cancel();

                            var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                            NavManager.NavigateTo(uri, true);
                        }
                        else if (returnResult.ButtonResultText ==
                                 Localizer.GetString(ButtonResourceKeyConstants.VectorSurveillanceSessionReturntoOutbreakSessionButtonText))
                        {
                            var uri = $"{NavManager.BaseUri}Outbreak/OutbreakCases/Index?queryData=" + VectorSessionStateContainer.OutbreakKey;
                            NavManager.NavigateTo(uri, true);
                        }
                        else
                        {
                            DiagService.Close();

                            VectorSessionStateContainer.VectorSessionKey = result.SessionKey;

                            var path = "Vector/VectorSurveillanceSession/Edit";
                            var query = $"?sessionKey={VectorSessionStateContainer.VectorSessionKey}";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        /// Saves the surveillance session, detailed
        /// collections, and aggregate collections in one save using
        /// USP_VCTS_SURVEILLANCE_SESSION_SET.
        /// </summary>
        /// <returns>VectorSessionResponseModel</returns>
        public async Task<VectorSessionResponseModel> SaveSurveillanceSession()
        {
            NotificationSiteAlertService.Events ??= new List<EventSaveRequestModel>();

            try
            {
                // surveillance session
                var request = new VectorSessionSetRequestModel
                {
                    idfsVectorSurveillanceStatus = VectorSessionStateContainer.StatusID,
                    strSessionID = VectorSessionStateContainer.SessionID,
                    strFieldSessionID = VectorSessionStateContainer.FieldSessionID,
                    datStartDate = VectorSessionStateContainer.StartDate,
                    datCloseDate = VectorSessionStateContainer.CloseDate,
                    idfOutbreak = VectorSessionStateContainer.OutbreakKey,
                    intCollectionEffort = VectorSessionStateContainer.CollectionEffort,
                    strDescription = VectorSessionStateContainer.Description,
                    strLocationDescription = VectorSessionStateContainer.LocationDescription,
                    idfsGeolocationType = VectorSessionStateContainer.GeoLocationTypeID
                };

                // location lowest level
                if (VectorSessionStateContainer.LocationViewModel.AdminLevel6Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel6Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel5Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel5Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel4Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel4Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel3Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel3Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel2Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel2Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel1Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel1Value;
                }
                else if (VectorSessionStateContainer.LocationViewModel.AdminLevel0Value != null)
                {
                    request.idfsLocation = VectorSessionStateContainer.LocationViewModel.AdminLevel0Value;
                }

                if (VectorSessionStateContainer.GeoLocationID is > 1)
                {
                    request.idfGeoLocation = VectorSessionStateContainer.GeoLocationID;
                }

                // location coordinates and elevations
                request.dblLongitude = VectorSessionStateContainer.LocationViewModel.Longitude;
                request.dblLatitude = VectorSessionStateContainer.LocationViewModel.Latitude;
                request.Elevation = VectorSessionStateContainer.LocationViewModel.Elevation;
                request.dblDirection = VectorSessionStateContainer.LocationDirection;
                request.dblDistance = VectorSessionStateContainer.LocationDistance;
                request.idfsGroundType = VectorSessionStateContainer.LocationGroundTypeID;

                // location address information
                request.strStreetName = VectorSessionStateContainer.LocationViewModel.StreetText;
                request.strHouse = VectorSessionStateContainer.LocationViewModel.House;
                request.strApartment = VectorSessionStateContainer.LocationViewModel.Apartment;
                request.strBuilding = VectorSessionStateContainer.LocationViewModel.Building;
                request.strPostalCode = VectorSessionStateContainer.LocationViewModel.PostalCodeText;
                request.strForeignAddress = VectorSessionStateContainer.ForeignAddress;
                request.strLocationDescription = VectorSessionStateContainer.LocationDescription;

                // required request information
                request.SiteID = VectorSessionStateContainer.SiteID ??= Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                request.AuditUser = _tokenService.GetAuthenticatedUser().UserName;
                request.idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey;

                if (request.idfVectorSurveillanceSession is null or <= 0)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == (long)request.SiteID
                        ? SystemEventLogTypes.NewVectorSurveillanceSessionWasCreatedAtYourSite
                        : SystemEventLogTypes.NewVectorSurveillanceSessionWasCreatedAtAnotherSite;
                    var notification =
                        await NotificationSiteAlertService.CreateEvent(0, null, eventTypeId, (long)request.SiteID,
                            null);
                    Events ??= new List<EventSaveRequestModel>();
                    Events.Add(notification);
                    NotificationSiteAlertService.Events.Add(notification);
                    VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                }

                if (VectorSessionStateContainer.AddingToOutbreakIndicator)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == (long)request.SiteID
                        ? SystemEventLogTypes.NewVectorSurveillanceSessionWasAddedToOutbreakSessionAtYourSite
                        : SystemEventLogTypes.NewVectorSurveillanceSessionWasAddedToOutbreakSessionAtAnotherSite;
                    var notification =
                        await NotificationSiteAlertService.CreateEvent(0, null, eventTypeId, (long)request.SiteID,
                            null);
                    Events ??= new List<EventSaveRequestModel>();
                    Events.Add(notification);
                    NotificationSiteAlertService.Events.Add(notification);
                    VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                }

                // aggregate collections
                request.AggregateCollections = JsonConvert.SerializeObject(BuildAggregateCollections(VectorSessionStateContainer.PendingAggregateCollectionList));

                // aggregate collection diagnosis
                request.DiagnosisInfo = JsonConvert.SerializeObject(BuildAggregateDiagnosisInfo(VectorSessionStateContainer.PendingAggregateCollectionDiseaseList));

                // new diagnosis notifications for aggregate collection
                if (VectorSessionStateContainer.PendingAggregateCollectionDiseaseList is { Count: > 0 })
                {
                    var newDiseases = VectorSessionStateContainer.PendingAggregateCollectionDiseaseList
                        .Where(x => x.idfsVSSessionSummaryDiagnosis <= 0).DistinctBy(x => x.DiseaseID);
                    foreach (var disease in newDiseases)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == (long)request.SiteID
                            ? SystemEventLogTypes.NewDiseaseForVectorSurveillanceSessionWasDetectedAtYourSite
                            : SystemEventLogTypes.NewDiseaseForVectorSurveillanceSessionWasDetectedAtAnotherSite;
                        var notification = await NotificationSiteAlertService.CreateEvent(
                            VectorSessionStateContainer.VectorSessionKey ?? 0, disease.DiseaseID, eventTypeId,
                            (long)request.SiteID, null);
                        Events ??= new List<EventSaveRequestModel>();
                        Events.Add(notification);
                        NotificationSiteAlertService.Events.Add(notification);
                        VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                    }
                }

                // new diagnosis notifications for detailed collections
                if (VectorSessionStateContainer.PendingDetailedCollectionsSamplesList is { Count: > 0 })
                {
                    var newDiseases = VectorSessionStateContainer.PendingDetailedCollectionsSamplesList
                        .Where(x => x.SampleID <= 0).DistinctBy(x => x.DiseaseID);
                    foreach (var disease in newDiseases)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == (long)request.SiteID
                            ? SystemEventLogTypes.NewDiseaseForVectorSurveillanceSessionWasDetectedAtYourSite
                            : SystemEventLogTypes.NewDiseaseForVectorSurveillanceSessionWasDetectedAtAnotherSite;
                        var notification = await NotificationSiteAlertService.CreateEvent(
                            VectorSessionStateContainer.VectorSessionKey ?? 0, disease.DiseaseID, eventTypeId,
                            (long)request.SiteID, null);
                        Events ??= new List<EventSaveRequestModel>();
                        Events.Add(notification);
                        NotificationSiteAlertService.Events.Add(notification);
                        VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                    }
                }

                // detailed collections
                var detailedCollections =
                    await BuildDetailedCollections(VectorSessionStateContainer.PendingDetailedCollectionsDetailsList);
                request.DetailedCollections = JsonConvert.SerializeObject(detailedCollections);

                request.Events = JsonConvert.SerializeObject(VectorSessionStateContainer.PendingSaveEvents);

                var results = await VectorClient.SaveVectorSurveillanceSessionAsync(request, _token);
                return results.FirstOrDefault();
            }
            catch (Exception ex)
            {
                Logger.LogError($"Error while saving the vector surveillance session: {ex.Message}", ex);
                throw;
            }
        }

        public List<VectorAggregateCollectionRequestModel> BuildAggregateCollections(IList<VectorSessionDetailResponseModel> pendingAggregateCollections)
        {
            var aggregateCollectionsRequestList = new List<VectorAggregateCollectionRequestModel>();

            if (pendingAggregateCollections is null)
                return aggregateCollectionsRequestList;

            foreach (var item in pendingAggregateCollections)
            {
                long? locationId = null;
                if (item.AdminLevel3Value != null)
                {
                    locationId = item.AdminLevel3Value;
                }
                else if (item.AdminLevel2Value != null)
                {
                    locationId = item.AdminLevel2Value;
                }
                else if (item.AdminLevel1Value != null)
                {
                    locationId = item.AdminLevel1Value;
                }
                else if (item.AdminLevel0Value != null)
                {
                    locationId = item.AdminLevel0Value;
                }

                var aggregate = new VectorAggregateCollectionRequestModel()
                {
                    VectorSessionKey = item.idfVectorSurveillanceSession,
                    CollectionDateTime = item.datCollectionDateTime,
                    GeoLocationID = item.idfGeoLocation,
                    VectorSessionSummaryKey = item.idfsVSSessionSummary,
                    PoolsVectors = item.intQuantity,
                    SummaryInfoSex = item.idfsSex,
                    SummaryInfoSpecies = item.idfsVectorSubType,
                    Distance = item.dblDistance,
                    GeoLocationTypeID = item.idfsGeoLocationType,
                    LocationID = locationId,
                    GroundTypeID = item.idfsGroundType,
                    Apartment = item.Apartment,
                    Building = item.Building,
                    House = item.House,
                    Description = item.strDescription,
                    Longitude = item.dblLongitude,
                    Latitude = item.dblLatitude,
                    PostCode = item.PostalCode,
                    Accuracy = item.dblAccuracy,
                    Alignment = item.dblAlignment,
                    Elevation = item.dblElevation,
                    StreetName = item.StreetName,
                    ForeignAddress = item.strForeignAddress,
                    IsForeignAddress = IsNullOrEmpty(item.strForeignAddress),
                    IsGeoLocationShared = false,
                    ResidentTypeID = null,
                    SummarySessionID = item.strVSSessionSummaryID,
                    RowAction = item.RowAction,
                    RowStatus = item.intRowStatus
                };
                aggregateCollectionsRequestList.Add(aggregate);
            }

            return aggregateCollectionsRequestList;
        }

        public List<VectorAggregateDiagnosisInfoRequestModel> BuildAggregateDiagnosisInfo(IList<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> pendingAggregateCollectionDiseaseList)
        {
            var aggregateCollectionsDiseaseList = new List<VectorAggregateDiagnosisInfoRequestModel>();

            if (pendingAggregateCollectionDiseaseList is null)
                return aggregateCollectionsDiseaseList;

            foreach (var diagnosis in pendingAggregateCollectionDiseaseList)
            {
                var diagnosisRequest = new VectorAggregateDiagnosisInfoRequestModel()
                {
                    idfsDiagnosis = diagnosis.DiseaseID,
                    idfsVSSessionSummaryDiagnosis = diagnosis.idfsVSSessionSummaryDiagnosis,
                    idfsVSSessionSummary = diagnosis.idfsVSSessionSummary,
                    intPositiveQuantity = diagnosis.intPositiveQuantity,
                    RowAction = diagnosis.RowAction,
                    RowStatus = diagnosis.intRowStatus
                };
                aggregateCollectionsDiseaseList.Add(diagnosisRequest);
            }

            return aggregateCollectionsDiseaseList;
        }

        public async Task<List<VectorDetailCollectionRequestModel>> BuildDetailedCollections(IList<VectorDetailedCollectionViewModel> pendingDetailedCollections)
        {
            var detailCollectionsRequestList = new List<VectorDetailCollectionRequestModel>();

            if (pendingDetailedCollections is null)
                return detailCollectionsRequestList;

            foreach (var item in pendingDetailedCollections)
            {
                long? locationId = null;
                if (item.LocationViewModel.AdminLevel6Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel6Value;
                }
                if (item.LocationViewModel.AdminLevel5Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel5Value;
                }
                if (item.LocationViewModel.AdminLevel4Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel4Value;
                }
                if (item.LocationViewModel.AdminLevel3Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel3Value;
                }
                else if (item.LocationViewModel.AdminLevel2Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel2Value;
                }
                else if (item.LocationViewModel.AdminLevel1Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel1Value;
                }
                else if (item.LocationViewModel.AdminLevel0Value != null)
                {
                    locationId = item.LocationViewModel.AdminLevel0Value;
                }

                var detailCollection = new VectorDetailCollectionRequestModel()
                {
                    VectorSessionKey = item.VectorSessionKey,
                    CollectionDateTime = item.CollectionDateTime,
                    GeoLocationID = item.GeoLocationID,
                    VectorSessionDetailedKey = item.VectorSessionDetailKey.GetValueOrDefault(),
                    GeoLocationTypeID = item.GeoLocationTypeID,
                    LocationID = locationId,
                    GroundTypeID = item.GroundTypeID,
                    Apartment = item.Apartment,
                    Building = item.Building,
                    House = item.House,
                    Description = item.Description,
                    Longitude = item.Longitude,
                    Latitude = item.Latitude,
                    PostCode = item.PostCode,
                    Accuracy = item.Accuracy,
                    Alignment = item.Alignment,
                    Distance = item.Distance,
                    Elevation = item.Elevation,
                    StreetName = item.StreetName,
                    ForeignAddress = item.ForeignAddress,
                    IsForeignAddress = IsNullOrEmpty(item.ForeignAddress),
                    IsGeoLocationShared = false,
                    ResidentTypeID = null,
                    DetailSessionID = item.DetailSessionID,
                    BasisOfRecordID = item.BasisOfRecordID,
                    CollectedByOfficeID = item.CollectedByOfficeID,
                    CollectionByPersonID = item.CollectionByPersonID,
                    CollectionMethodID = item.CollectionMethodID,
                    Comment = item.Comment,
                    EctoparASSitesCollectionID = item.EctoparasitesCollectionID,
                    DetailedElevation = item.DetailedElevation,
                    DayPeriodID = item.DayPeriodID,
                    DetailedSurroundings = item.DetailedSurroundings,
                    DetailedVectorTypeID = item.VectorTypeID,
                    FormTemplateID = item.FormTemplateID,
                    FieldVectorID = item.FieldVectorID,
                    IdentifiedByFieldOfficeID = item.IdentifiedByFieldOfficeID,
                    IdentificationMethodID = item.IdentificationMethodID,
                    IdentifiedByPersonID = item.IdentifiedByPersonID,
                    IdentifiedDateTime = item.IdentifiedDateTime,
                    HostVectorID = item.HostVectorID,
                    GeoReferenceSource = item.GeoReferenceSource,
                    ObservationID = item.ObservationID,
                    Quantity = item.Quantity,
                    SexID = item.SexID,
                    VectorSubTypeID = item.VectorSubTypeID,
                    RowAction = item.RowAction,
                    RowStatus = item.RowStatus,
                    Samples = JsonConvert.SerializeObject(BuildSampleParameters(item.PendingSamples)),
                    FieldTests = JsonConvert.SerializeObject(await BuildFieldTestParameters(item.PendingFieldTests))
                };

                detailCollectionsRequestList.Add(detailCollection);
            }

            return detailCollectionsRequestList;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="samples"></param>
        /// <returns></returns>
        private List<SampleSaveRequestModel> BuildSampleParameters(IList<VectorSampleGetListViewModel> samples)
        {
            List<SampleSaveRequestModel> requests = new();

            if (samples is null)
                return new List<SampleSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                var request = new SampleSaveRequestModel();
                {
                    request.AnimalID = null;
                    request.BirdStatusTypeID = null;
                    request.CurrentSiteID = null;
                    request.DiseaseID = sampleModel.DiseaseID;
                    request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLocalOrFieldSampleID.Contains(Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)) ? Empty : sampleModel.EIDSSLocalOrFieldSampleID;
                    request.EnteredDate = sampleModel.EnteredDate;
                    request.FarmID = null;
                    request.FarmMasterID = null;
                    request.CollectedByOrganizationID = sampleModel.CollectedByOrganizationID;
                    request.CollectedByPersonID = sampleModel.CollectedByPersonID;
                    request.CollectionDate = sampleModel.CollectionDate;
                    request.SentDate = sampleModel.SentDate;
                    request.SentToOrganizationID = sampleModel.SentToOrganizationID;
                    request.HumanDiseaseReportID = null;
                    request.HumanMasterID = sampleModel.HumanMasterID;
                    request.HumanID = sampleModel.HumanID;
                    request.MonitoringSessionID = null;
                    request.Comments = sampleModel.Comments;
                    request.ParentSampleID = sampleModel.ParentSampleID;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RootSampleID = sampleModel.RootSampleID;
                    request.SampleID = sampleModel.SampleID;
                    request.SampleStatusTypeID = sampleModel.SampleStatusTypeID;
                    request.SampleTypeID = sampleModel.SampleTypeID;
                    request.SiteID = sampleModel.SiteID;
                    request.SpeciesID = sampleModel.SpeciesID;
                    request.VectorID = sampleModel.VectorID;
                    request.VectorSessionID = sampleModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = null;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RowAction = sampleModel.RowAction;
                    request.RowStatus = sampleModel.RowStatus;
                }
                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="tests"></param>
        /// <returns></returns>
        private async Task<List<LaboratoryTestSaveRequestModel>> BuildFieldTestParameters(IList<FieldTestGetListViewModel> tests)
        {
            List<LaboratoryTestSaveRequestModel> requests = new();
            Events ??= new List<EventSaveRequestModel>();
            NotificationSiteAlertService.Events ??= new List<EventSaveRequestModel>();

            if (tests is null)
                return new List<LaboratoryTestSaveRequestModel>();

            foreach (var laboratoryTestModel in tests)
            {
                var request = new LaboratoryTestSaveRequestModel();
                {
                    request.BatchTestID = laboratoryTestModel.BatchTestID;
                    request.Comments = laboratoryTestModel.Comments;
                    request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                    request.DiseaseID = Convert.ToInt64(laboratoryTestModel.DiseaseID);
                    request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                    request.HumanDiseaseReportID = null;
                    request.MonitoringSessionID = null;
                    request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                    request.ObservationID = laboratoryTestModel.ObservationID;
                    request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                    request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                    request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                    request.ResultDate = laboratoryTestModel.ResultDate;
                    request.ResultEnteredByOrganizationID = laboratoryTestModel.ResultEnteredByOrganizationID;
                    request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                    request.SampleID = laboratoryTestModel.SampleID;
                    request.StartedDate = laboratoryTestModel.StartedDate;
                    request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                    request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                    request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                    request.TestID = laboratoryTestModel.TestID;
                    request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                    request.TestNumber = laboratoryTestModel.TestNumber;
                    request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                    request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID <= 0
                        ? (long)TestStatusTypeEnum.NotStarted
                        : laboratoryTestModel.TestStatusTypeID;
                    request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                    request.VectorSessionID = laboratoryTestModel.VectorID;
                    request.VeterinaryDiseaseReportID = null;
                    request.RowAction = laboratoryTestModel.RowAction;
                    request.RowStatus = laboratoryTestModel.RowStatus;
                }

                if (laboratoryTestModel.OriginalTestResultTypeID != laboratoryTestModel.TestResultTypeID)
                {
                    SystemEventLogTypes eventTypeId;
                    EventSaveRequestModel notification;

                    if (laboratoryTestModel.OriginalTestResultTypeID is null)
                    {
                        if (laboratoryTestModel.NonLaboratoryTestIndicator)
                        {
                            eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          VectorSessionStateContainer.SiteID
                                ? SystemEventLogTypes
                                    .NewFieldTestResultForVectorSurveillanceSessionWasRegisteredAtYourSite
                                : SystemEventLogTypes
                                    .NewFieldTestResultForVectorSurveillanceSessionWasRegisteredAtAnotherSite;
                            notification = await CreateEvent(VectorSessionStateContainer.VectorSessionKey ?? 0,
                                laboratoryTestModel.DiseaseID, eventTypeId,
                                (long)VectorSessionStateContainer.SiteID,
                                null);
                            Events ??= new List<EventSaveRequestModel>();
                            Events.Add(notification);
                            NotificationSiteAlertService.Events.Add(notification);
                            VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                        }
                        else
                        {
                            eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                          VectorSessionStateContainer.SiteID
                                ? SystemEventLogTypes
                                    .NewLaboratoryTestResultForVectorSurveillanceSessionWasRegisteredAtYourSite
                                : SystemEventLogTypes
                                    .NewLaboratoryTestResultForVectorSurveillanceSessionWasRegisteredAtAnotherSite;
                            notification = await CreateEvent(VectorSessionStateContainer.VectorSessionKey ?? 0,
                                laboratoryTestModel.DiseaseID, eventTypeId,
                                (long)VectorSessionStateContainer.SiteID,
                                null);
                            Events ??= new List<EventSaveRequestModel>();
                            Events.Add(notification);
                            NotificationSiteAlertService.Events.Add(notification);
                            VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                        }
                    }
                    else
                    {
                        eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) ==
                                      VectorSessionStateContainer.SiteID
                            ? SystemEventLogTypes
                                .LaboratoryTestResultForVectorSurveillanceSessionWasAmendedAtYourSite
                            : SystemEventLogTypes
                                .LaboratoryTestResultForVectorSurveillanceSessionWasAmendedAtAnotherSite;
                        notification = await CreateEvent(VectorSessionStateContainer.VectorSessionKey ?? 0,
                            laboratoryTestModel.DiseaseID, eventTypeId,
                            (long)VectorSessionStateContainer.SiteID,
                            null);
                        Events ??= new List<EventSaveRequestModel>();
                        Events.Add(notification);
                        NotificationSiteAlertService.Events.Add(notification);
                        VectorSessionStateContainer.PendingSaveEvents.Add(notification);
                    }
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion OnSave Method

        #region Save Aggregate Collection Method

        /// <summary>
        /// Saves an aggregate collection to memory
        /// </summary>
        /// <returns></returns>
        protected void SaveAggregateCollection()
        {
            try
            {
                // just save the aggregate collection to the master list
                var item = VectorSessionStateContainer.VectorSessionSummaryKey <= 0
                    ? new VectorSessionDetailResponseModel()
                    : VectorSessionStateContainer.AggregateCollectionList.First(x => x.idfsVSSessionSummary == VectorSessionStateContainer.VectorSessionSummaryKey);

                // set the fields
                item.idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey.GetValueOrDefault();
                item.idfsVSSessionSummary = VectorSessionStateContainer.VectorSessionSummaryKey.GetValueOrDefault();
                item.strVSSessionSummaryID = VectorSessionStateContainer.VectorSessionKey <= 0 ? "(new)" : VectorSessionStateContainer.SummaryRecordID;

                item.datCollectionDateTime = VectorSessionStateContainer.SummaryCollectionDateTime;
                item.idfsVectorSubType = VectorSessionStateContainer.SummaryInfoSpeciesID.GetValueOrDefault();
                item.idfsVectorType = VectorSessionStateContainer.SummaryVectorTypeID;
                item.idfsSex = VectorSessionStateContainer.SummaryInfoSexID;
                item.intQuantity = VectorSessionStateContainer.PoolsAndVectors;

                // vector
                var vector = VectorSessionStateContainer.VectorTypesList.Find(x => x.IdfsVectorType == VectorSessionStateContainer.SummaryVectorTypeID);
                if (vector != null) item.strVectorType = vector.StrName;

                // sex
                var sex = VectorSessionStateContainer.AnimalSexList.Find(x => x.IdfsBaseReference == VectorSessionStateContainer.SummaryInfoSexID);
                if (sex != null) item.strSex = sex.Name;

                // species (vector sub type)
                var species = VectorSessionStateContainer.SpeciesList.Find(x => x.KeyId == VectorSessionStateContainer.SummaryInfoSpeciesID);
                if (species != null) item.strVectorSubType = species.StrName;

                // location data
                item.strDescription = VectorSessionStateContainer.SummaryLocationDescription;
                item.idfsGeoLocationType = VectorSessionStateContainer.SummaryGeoLocationTypeID.GetValueOrDefault();
                long? locationId = null;
                if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel6Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel6Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel5Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel5Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel4Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel4Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value;
                }
                else if (VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value != null)
                {
                    locationId = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value;
                }
                item.AdminLevel3Text = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Text;
                item.AdminLevel3Value = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value;
                item.AdminLevel2Text = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Text;
                item.AdminLevel2Value = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value;
                item.AdminLevel1Text = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Text;
                item.AdminLevel1Value = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value;
                item.AdminLevel0Text = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Text;
                item.AdminLevel0Value = VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value;
                item.idfGeoLocation = locationId;

                // location coordinates and elevations
                item.dblLongitude = VectorSessionStateContainer.SummaryLocationViewModel.Longitude;
                item.dblLatitude = VectorSessionStateContainer.SummaryLocationViewModel.Latitude;
                item.dblElevation = VectorSessionStateContainer.SummaryLocationViewModel.Elevation;
                item.dblAlignment = VectorSessionStateContainer.SummaryLocationDirection;
                item.dblDistance = VectorSessionStateContainer.SummaryLocationDistance;

                // location address information
                item.StreetName = VectorSessionStateContainer.SummaryLocationViewModel.StreetText;
                item.House = VectorSessionStateContainer.SummaryLocationViewModel.House;
                item.Apartment = VectorSessionStateContainer.SummaryLocationViewModel.Apartment;
                item.Building = VectorSessionStateContainer.SummaryLocationViewModel.Building;
                item.PostalCode = VectorSessionStateContainer.SummaryLocationViewModel.PostalCodeText;

                // set the status of the row
                item.RowAction = VectorSessionStateContainer.VectorSessionSummaryKey <= 0 ? (int)RowActionTypeEnum.Insert : (int)RowActionTypeEnum.Update;
                item.intRowStatus = VectorSessionStateContainer.SummaryRowStatus;

                if (VectorSessionStateContainer.AggregateCollectionList != null && VectorSessionStateContainer.AggregateCollectionList.Any(x => x.idfsVSSessionSummary == item.idfsVSSessionSummary))
                {
                    var index = VectorSessionStateContainer.AggregateCollectionList.IndexOf(item);
                    VectorSessionStateContainer.AggregateCollectionList[index] = item;
                    TogglePendingSaveAggregateCollection(item, item);
                }
                else
                {
                    VectorSessionStateContainer.AggregateCollectionList?.Add(item);
                    VectorSessionStateContainer.AggregateNewCollectionsCount++;
                    TogglePendingSaveAggregateCollection(item, null);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAggregateCollection(VectorSessionDetailResponseModel record,
            VectorSessionDetailResponseModel originalRecord)
        {
            VectorSessionStateContainer.PendingAggregateCollectionList ??= new List<VectorSessionDetailResponseModel>();

            if (VectorSessionStateContainer.PendingAggregateCollectionList.Any(x => x.idfsVSSessionSummary == record.idfsVSSessionSummary))
            {
                var index = VectorSessionStateContainer.PendingAggregateCollectionList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingAggregateCollectionList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingAggregateCollectionList.Add(record);
            }
        }

        #endregion Save Aggregate Collection Method

        #region Save Detailed Collection Method

        /// <summary>
        /// Saves a detailed collection to memory
        /// </summary>
        /// <returns></returns>
        protected void SaveDetailedCollection()
        {
            // saves only to the collections in state container
            var detailedCollection = new USP_VCTS_VECT_GetDetailResponseModel();

            try
            {
                VectorDetailedCollectionViewModel request = new()
                {
                    VectorSessionKey = VectorSessionStateContainer.VectorSessionKey.GetValueOrDefault(),
                    VectorSessionDetailKey = VectorSessionStateContainer.VectorDetailedCollectionKey.GetValueOrDefault(),
                    RowStatus = (int)RowStatusTypeEnum.Active,
                    RowAction = VectorSessionStateContainer.VectorDetailedCollectionKey.GetValueOrDefault() <= 0 ? (int)RowActionTypeEnum.Insert : (int)RowActionTypeEnum.Update,
                    DetailSessionID = VectorSessionStateContainer.DetailSessionID,
                    //Collection Data
                    FieldVectorID = VectorSessionStateContainer.DetailFieldPoolVectorID,
                    VectorTypeID = VectorSessionStateContainer.DetailVectorTypeID,
                    GeoReferenceSource = VectorSessionStateContainer.DetailGeoReferenceSource,
                    BasisOfRecordID = VectorSessionStateContainer.DetailBasisOfRecordID,
                    HostVectorID = VectorSessionStateContainer.DetailHostReferenceID,
                    CollectedByOfficeID = VectorSessionStateContainer.DetailCollectedByInstitutionID,
                    CollectionByPersonID = VectorSessionStateContainer.DetailCollectedByPersonID,
                    CollectionDateTime = VectorSessionStateContainer.DetailCollectionDate,
                    DayPeriodID = VectorSessionStateContainer.DetailCollectionTimePeriodID,
                    CollectionMethodID = VectorSessionStateContainer.DetailCollectionMethodID,
                    EctoparasitesCollectionID = VectorSessionStateContainer.DetailEctoparasitesCollectedID,
                    //Vector Data
                    Quantity = VectorSessionStateContainer.DetailQuantity,
                    VectorSubTypeID = VectorSessionStateContainer.DetailSpeciesID,
                    SexID = VectorSessionStateContainer.DetailSpeciesSexID,
                    IdentifiedByFieldOfficeID = VectorSessionStateContainer.DetailIdentifiedByInstitutionID,
                    IdentifiedByPersonID = VectorSessionStateContainer.DetailIdentifiedByPersonID,
                    IdentificationMethodID = VectorSessionStateContainer.DetailIdentifiedByMethodID,
                    IdentifiedDateTime = VectorSessionStateContainer.DetailIdentifiedDate,
                    Comment = VectorSessionStateContainer.DetailComment,
                    //Vector Specific Data
                    ObservationID = VectorSessionStateContainer.DetailObservationID,
                    //Location Data
                    LocationViewModel = new LocationViewModel()
                };

                long? locationId = null;
                if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value;
                }
                else if (VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value != null)
                {
                    locationId = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value;
                }

                request.GeoLocationTypeID = VectorSessionStateContainer.DetailGeoLocationTypeID;
                request.GeoLocationID = locationId;
                request.LocationViewModel.AdminLevel6Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value;
                request.LocationViewModel.AdminLevel5Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value;
                request.LocationViewModel.AdminLevel4Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value;
                request.LocationViewModel.AdminLevel3Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value;
                request.LocationViewModel.AdminLevel2Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value;
                request.LocationViewModel.AdminLevel1Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value;
                request.LocationViewModel.AdminLevel0Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value;
                request.LocationViewModel.SettlementId = VectorSessionStateContainer.DetailLocationViewModel.SettlementId;
                request.LocationViewModel.StreetText = VectorSessionStateContainer.DetailLocationViewModel.StreetText;
                request.LocationViewModel.Apartment = VectorSessionStateContainer.DetailLocationViewModel.Apartment;
                request.LocationViewModel.Building = VectorSessionStateContainer.DetailLocationViewModel.Building;
                request.LocationViewModel.PostalCodeText = VectorSessionStateContainer.DetailLocationViewModel.PostalCodeText;
                request.LocationViewModel.Longitude = VectorSessionStateContainer.DetailLocationViewModel.Longitude;
                request.Latitude = VectorSessionStateContainer.DetailLocationViewModel.Latitude;
                request.Longitude = VectorSessionStateContainer.DetailLocationViewModel.Longitude;
                request.LocationViewModel.Latitude = VectorSessionStateContainer.DetailLocationViewModel.Latitude;
                request.Accuracy = VectorSessionStateContainer.DetailLocationViewModel.Elevation;
                request.DetailedElevation = (int?)VectorSessionStateContainer.DetailLocationElevation;
                request.DetailedSurroundings = VectorSessionStateContainer.DetailLocationSurroundings;

                // create the detailed collection summary item for the grid
                detailedCollection.datCollectionDateTime = request.CollectionDateTime.GetValueOrDefault();
                detailedCollection.idfVector = request.VectorSessionDetailKey.GetValueOrDefault();
                detailedCollection.idfsSex = request.SexID;
                detailedCollection.idfsVectorSubType = request.VectorSubTypeID.GetValueOrDefault();
                detailedCollection.idfsVectorType = request.VectorTypeID.GetValueOrDefault();
                if (VectorSessionStateContainer.VectorTypesList.Any(x => x.IdfsVectorType == request.VectorTypeID))
                    detailedCollection.strVectorType = VectorSessionStateContainer.VectorTypesList.First(x => x.IdfsVectorType == request.VectorTypeID).StrName;
                detailedCollection.idfVectorSurveillanceSession = request.VectorSessionKey;
                detailedCollection.intCollectionEffort = request.Quantity;
                detailedCollection.AdminLevel0Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Text;
                detailedCollection.AdminLevel0Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value;
                detailedCollection.AdminLevel1Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Text;
                detailedCollection.AdminLevel1Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value;
                detailedCollection.AdminLevel2Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Text;
                detailedCollection.AdminLevel2Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value;
                detailedCollection.AdminLevel3Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Text;
                detailedCollection.AdminLevel3Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value;
                detailedCollection.AdminLevel4Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Text;
                detailedCollection.AdminLevel4Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value;
                detailedCollection.AdminLevel5Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Text;
                detailedCollection.AdminLevel5Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value;
                detailedCollection.AdminLevel6Text = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Text;
                detailedCollection.AdminLevel6Value = VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value;
                detailedCollection.strComment = request.Comment;
                detailedCollection.strFieldVectorID = request.FieldVectorID;
                detailedCollection.strSessionID = VectorSessionStateContainer.SessionID;
                detailedCollection.strVectorID = request.DetailSessionID;

                // samples
                request.PendingSamples = VectorSessionStateContainer.PendingDetailedCollectionsSamplesList;
                request.Samples = VectorSessionStateContainer.DetailedCollectionsSamplesList;

                // field tests
                request.PendingFieldTests = VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList;
                request.FieldTests = VectorSessionStateContainer.DetailedCollectionsFieldTestsList;

                // save the entire detailed collection to the state container
                if (VectorSessionStateContainer.DetailedCollectionList != null && VectorSessionStateContainer.DetailedCollectionList.Any(x => x.idfVector == detailedCollection.idfVector))
                {
                    var originalRecord = VectorSessionStateContainer.DetailedCollectionList.First(x => x.idfVector == detailedCollection.idfVector);
                    ToggleDetailedCollection(detailedCollection, originalRecord);
                }
                else
                {
                    ToggleDetailedCollection(detailedCollection, null);
                }

                if (VectorSessionStateContainer.DetailedCollectionsDetailsList != null && VectorSessionStateContainer.DetailedCollectionsDetailsList.Any(x => x.VectorSessionDetailKey == request.VectorSessionDetailKey))
                {
                    var originalRecord = VectorSessionStateContainer.DetailedCollectionsDetailsList.First(x => x.VectorSessionDetailKey == request.VectorSessionDetailKey);
                    ToggleDetailedCollectionDetails(request, originalRecord);
                    var originalPending = VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.First(x => x.VectorSessionDetailKey == request.VectorSessionDetailKey);
                    TogglePendingSaveDetailedCollectionDetails(request, originalPending);
                }
                else
                {
                    ToggleDetailedCollectionDetails(request, null);
                    TogglePendingSaveDetailedCollectionDetails(request, null);
                }
                // reset the samples list, field test list, and lab tests
                VectorSessionStateContainer.DetailedCollectionsSamplesList = null;
                VectorSessionStateContainer.DetailedCollectionsFieldTestsList = null;
                VectorSessionStateContainer.LaboratoryTestsList = null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void ToggleDetailedCollectionDetails(VectorDetailedCollectionViewModel record,
            VectorDetailedCollectionViewModel originalRecord)
        {
            VectorSessionStateContainer.DetailedCollectionsDetailsList ??= new List<VectorDetailedCollectionViewModel>();

            if (VectorSessionStateContainer.DetailedCollectionsDetailsList.Any(x => x.VectorSessionDetailKey == record.VectorSessionDetailKey))
            {
                var index = VectorSessionStateContainer.DetailedCollectionsDetailsList.IndexOf(originalRecord);
                VectorSessionStateContainer.DetailedCollectionsDetailsList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.DetailedCollectionsDetailsList.Add(record);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void ToggleDetailedCollection(USP_VCTS_VECT_GetDetailResponseModel record,
            USP_VCTS_VECT_GetDetailResponseModel originalRecord)
        {
            VectorSessionStateContainer.DetailedCollectionList ??= new List<USP_VCTS_VECT_GetDetailResponseModel>();

            if (VectorSessionStateContainer.DetailedCollectionList.Any(x => x.idfVector == record.idfVector))
            {
                var index = VectorSessionStateContainer.DetailedCollectionList.IndexOf(originalRecord);
                VectorSessionStateContainer.DetailedCollectionList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.DetailedCollectionList.Add(record);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveDetailedCollectionDetails(VectorDetailedCollectionViewModel record,
            VectorDetailedCollectionViewModel originalRecord)
        {
            VectorSessionStateContainer.PendingDetailedCollectionsDetailsList ??= new List<VectorDetailedCollectionViewModel>();

            if (VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Any(x => x.VectorSessionDetailKey == record.VectorSessionDetailKey))
            {
                var index = VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingDetailedCollectionsDetailsList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingDetailedCollectionsDetailsList.Add(record);
            }
        }

        #endregion Save Detailed Collection Method

        #region Get Surveillance Session

        /// <summary>
        /// Get the vector surveillance session details
        /// </summary>
        /// <returns></returns>
        protected async Task GetSurveillanceSessionDetail()
        {
            try
            {
                USP_VCTS_VSSESSION_NEW_GetDetailRequestModel request = new()
                {
                    idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey.GetValueOrDefault(),
                    LangID = GetCurrentLanguage()
                };
                var result = await VectorClient.GetVectorSurveillanceSessionMasterAsync(request, _token);
                var response = result.FirstOrDefault();
                if (response is not null)
                {
                    VectorSessionStateContainer.CloseDate = response.datCloseDate;
                    VectorSessionStateContainer.StartDate = response.datStartDate;
                    VectorSessionStateContainer.StatusID = response.idfsVectorSurveillanceStatus;
                    VectorSessionStateContainer.VectorSessionKey = response.idfVectorSurveillanceSession;
                    VectorSessionStateContainer.SiteID = response.idfsSite;
                    VectorSessionStateContainer.CollectionEffort = response.intCollectionEffort;
                    VectorSessionStateContainer.Description = response.strDescription;
                    VectorSessionStateContainer.FieldSessionID = response.strFieldSessionID;
                    VectorSessionStateContainer.SessionID = response.strSessionID;
                    VectorSessionStateContainer.DiseaseString = response.strDiagnoses;
                    VectorSessionStateContainer.VectorTypeString = response.strVectors;

                    //Load Location Data
                    VectorSessionStateContainer.LocationViewModel = new LocationViewModel();
                    VectorSessionStateContainer.GeoLocationID = response.idfGeoLocation;
                    VectorSessionStateContainer.LocationViewModel.DefaultCountry = response.AdminLevel0Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel0Value = response.AdminLevel0Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel1Value = response.AdminLevel1Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel1Text = response.AdminLevel1Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel2Value = response.AdminLevel2Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel2Text = response.AdminLevel2Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel3Value = response.AdminLevel3Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel3Text = response.AdminLevel3Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel4Value = response.AdminLevel4Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel4Text = response.AdminLevel4Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel5Value = response.AdminLevel5Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel5Text = response.AdminLevel5Text;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel6Value = response.AdminLevel6Value;
                    VectorSessionStateContainer.LocationViewModel.AdminLevel6Text = response.AdminLevel6Text;
                    VectorSessionStateContainer.GeoLocationTypeID = response.idfsGeoLocationType;
                    VectorSessionStateContainer.LocationDescription = response.LocationDescription;
                    VectorSessionStateContainer.LocationViewModel.StreetText = response.strStreetName;
                    VectorSessionStateContainer.LocationViewModel.Apartment = response.strApartment;
                    VectorSessionStateContainer.LocationViewModel.House = response.strHouse;
                    VectorSessionStateContainer.LocationViewModel.PostalCodeText = response.strPostCode;
                    VectorSessionStateContainer.LocationViewModel.Building = response.strBuilding;
                    VectorSessionStateContainer.LocationDirection = response.dblDirection;
                    VectorSessionStateContainer.LocationDistance = response.dblDistance;
                    VectorSessionStateContainer.LocationViewModel.Latitude = response.dblLatitude;
                    VectorSessionStateContainer.LocationViewModel.Longitude = response.dblLongitude;
                    VectorSessionStateContainer.LocationGroundTypeID = response.idfsGroundType;
                    VectorSessionStateContainer.ForeignAddress = response.strForeignAddress;
                    VectorSessionStateContainer.OutbreakID = response.strOutbreakID;
                    VectorSessionStateContainer.OutbreakKey = response.idfOutbreak;

                    await SwitchLocation(VectorSessionStateContainer.GeoLocationTypeID,
                        VectorSessionStateContainer.LocationViewModel,
                        VectorTabs.VectorSessionTab);

                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
        }

        #endregion Get Surveillance Session

        #region Get Aggregate Collection Details

        protected async Task GetAggregateCollection()
        {
            try
            {
                VectorSessionDetailResponseModel aggregateDetail = null;
                if (VectorSessionStateContainer.VectorSessionSummaryKey <= 0)
                {
                    IList<VectorSessionDetailResponseModel> pendingResult = VectorSessionStateContainer
                        .AggregateCollectionList.Where(x =>
                            x.idfVectorSurveillanceSession == VectorSessionStateContainer.VectorSessionSummaryKey)
                        .ToList();
                    if (pendingResult.Any())
                    {
                        aggregateDetail = pendingResult.First();
                    }
                }
                else
                {
                    var requestModel = new VectorSessionDetailRequestModel
                    {
                        idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey,
                        idfsVSSessionSummary = VectorSessionStateContainer.VectorSessionSummaryKey,
                        LangID = GetCurrentLanguage()
                    };
                    var results = await VectorClient.GetVectorSessionAggregateCollectionDetail(requestModel, _token);
                    if (results != null && results.Any())
                    {
                        aggregateDetail = results.First();
                    }
                }

                if (aggregateDetail != null)
                {
                    VectorSessionStateContainer.SummaryLocationViewModel.DefaultCountry = aggregateDetail.AdminLevel0Text;
                    VectorSessionStateContainer.SummaryRecordID = aggregateDetail.strVSSessionSummaryID;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Value = aggregateDetail.AdminLevel0Value;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel0Text = aggregateDetail.AdminLevel0Text;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value = aggregateDetail.AdminLevel1Value;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Text = aggregateDetail.AdminLevel1Text;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Value = aggregateDetail.AdminLevel2Value;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel2Text = aggregateDetail.AdminLevel2Text;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Value = aggregateDetail.AdminLevel3Value;
                    VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel3Text = aggregateDetail.AdminLevel3Text;
                    VectorSessionStateContainer.SummaryLocationDescription = aggregateDetail.strDescription;
                    VectorSessionStateContainer.SummaryLocationViewModel.PostalCode = aggregateDetail.PostalCodeID;
                    VectorSessionStateContainer.SummaryLocationViewModel.Street = aggregateDetail.StreetID;
                    VectorSessionStateContainer.SummaryLocationViewModel.StreetText = aggregateDetail.StreetName;
                    VectorSessionStateContainer.SummaryLocationViewModel.House = aggregateDetail.House;
                    VectorSessionStateContainer.SummaryLocationViewModel.Apartment = aggregateDetail.Apartment;
                    VectorSessionStateContainer.SummaryLocationViewModel.Building = aggregateDetail.Building;
                    VectorSessionStateContainer.SummaryLocationViewModel.Latitude = aggregateDetail.dblLatitude;
                    VectorSessionStateContainer.SummaryLocationViewModel.Longitude = aggregateDetail.dblLongitude;
                    VectorSessionStateContainer.SummaryGeoLocationTypeID = aggregateDetail.idfsGeoLocationType;
                    VectorSessionStateContainer.PoolsAndVectors = aggregateDetail.intQuantity;
                    VectorSessionStateContainer.SummaryInfoSexID = aggregateDetail.idfsSex;
                    VectorSessionStateContainer.SummaryInfoSpeciesID = aggregateDetail.idfsVectorSubType;
                    VectorSessionStateContainer.SummaryVectorTypeID = aggregateDetail.idfsVectorType;
                    VectorSessionStateContainer.SummaryCollectionDateTime = aggregateDetail.datCollectionDateTime;
                    VectorSessionStateContainer.SessionID = VectorSessionStateContainer.SessionID;
                    VectorSessionStateContainer.VectorSessionKey = aggregateDetail.idfVectorSurveillanceSession;

                    await SwitchLocation(VectorSessionStateContainer.SummaryGeoLocationTypeID,
                        VectorSessionStateContainer.SummaryLocationViewModel,
                        VectorTabs.AggregateCollectionsTab);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting aggregate collection.");
                throw;
            }
        }

        #endregion Get Aggregate Collection Details

        #region Get Detailed Collection Details

        protected async Task GetDetailCollection()
        {
            try
            {
                if (VectorSessionStateContainer.VectorDetailedCollectionKey <= 0)
                {
                    IList<VectorDetailedCollectionViewModel> pendingResult = VectorSessionStateContainer
                        .DetailedCollectionsDetailsList.Where(x =>
                            x.VectorSessionDetailKey == VectorSessionStateContainer.VectorDetailedCollectionKey)
                        .ToList();
                    if (pendingResult.Any())
                    {
                        var pendingDetailCollection = pendingResult.First();

                        // location admin levels
                        VectorSessionStateContainer.DetailLocationViewModel = pendingDetailCollection.LocationViewModel;

                        // other location information
                        VectorSessionStateContainer.DetailLocationElevation = pendingDetailCollection.DetailedElevation;
                        VectorSessionStateContainer.DetailLocationSurroundings =
                            pendingDetailCollection.DetailedSurroundings;
                        VectorSessionStateContainer.DetailLocationDescription = pendingDetailCollection.Description;
                        VectorSessionStateContainer.DetailLocationID = pendingDetailCollection.LocationID;
                        VectorSessionStateContainer.DetailLocationDistance = pendingDetailCollection.Distance;
                        VectorSessionStateContainer.DetailLocationGroundTypeID = pendingDetailCollection.GroundTypeID;
                        VectorSessionStateContainer.DetailGeoLocationTypeID = pendingDetailCollection.GeoLocationTypeID;
                        VectorSessionStateContainer.DetailLocationViewModel.StreetText =
                            pendingDetailCollection.StreetName;
                        VectorSessionStateContainer.DetailLocationViewModel.PostalCodeText =
                            pendingDetailCollection.PostCode;
                        VectorSessionStateContainer.DetailLocationViewModel.House = pendingDetailCollection.House;
                        VectorSessionStateContainer.DetailLocationViewModel.Building = pendingDetailCollection.Building;
                        VectorSessionStateContainer.DetailForeignAddress = pendingDetailCollection.ForeignAddress;
                        VectorSessionStateContainer.DetailLocationViewModel.Latitude = pendingDetailCollection.Latitude;
                        VectorSessionStateContainer.DetailLocationViewModel.Longitude =
                            pendingDetailCollection.Longitude;
                        VectorSessionStateContainer.DetailLocationViewModel.Apartment =
                            pendingDetailCollection.Apartment;

                        // collection data
                        VectorSessionStateContainer.DetailQuantity = pendingDetailCollection.Quantity;
                        VectorSessionStateContainer.DetailEctoparasitesCollectedID =
                            pendingDetailCollection.EctoparasitesCollectionID;
                        VectorSessionStateContainer.DetailCollectionTimePeriodID = pendingDetailCollection.DayPeriodID;
                        VectorSessionStateContainer.DetailCollectionMethodID =
                            pendingDetailCollection.IdentificationMethodID;
                        VectorSessionStateContainer.DetailHostReferenceID = pendingDetailCollection.HostVectorID;
                        VectorSessionStateContainer.DetailBasisOfRecordID = pendingDetailCollection.BasisOfRecordID;
                        VectorSessionStateContainer.DetailIdentifiedByMethodID = pendingDetailCollection.IdentificationMethodID;
                        VectorSessionStateContainer.DetailIdentifiedDate = pendingDetailCollection.IdentifiedDateTime;
                        VectorSessionStateContainer.DetailIdentifiedByInstitutionID =
                            pendingDetailCollection.IdentifiedByFieldOfficeID;
                        VectorSessionStateContainer.DetailIdentifiedByPersonID =
                            pendingDetailCollection.IdentifiedByPersonID;
                        VectorSessionStateContainer.DetailObservationID = pendingDetailCollection.ObservationID;
                        VectorSessionStateContainer.DetailGeoReferenceSource =
                            pendingDetailCollection.GeoReferenceSource;
                        VectorSessionStateContainer.DetailSessionID = pendingDetailCollection.DetailSessionID;
                        VectorSessionStateContainer.DetailFieldSessionID = pendingDetailCollection.FieldVectorID;
                        VectorSessionStateContainer.DetailFieldPoolVectorID = pendingDetailCollection.FieldVectorID;
                        VectorSessionStateContainer.DetailPoolVectorIID = pendingDetailCollection.DetailSessionID;
                        VectorSessionStateContainer.DetailCollectionDate = pendingDetailCollection.CollectionDateTime;
                        VectorSessionStateContainer.DetailVectorTypeID = pendingDetailCollection.VectorTypeID;
                        VectorSessionStateContainer.DetailSpeciesSexID = pendingDetailCollection.SexID;
                        VectorSessionStateContainer.DetailSpeciesID = pendingDetailCollection.VectorSubTypeID;
                        VectorSessionStateContainer.DetailCollectedByInstitutionID =
                            pendingDetailCollection.CollectedByOfficeID;
                        VectorSessionStateContainer.DetailCollectedByPersonID =
                            pendingDetailCollection.CollectionByPersonID;
                        VectorSessionStateContainer.DetailLocationID = pendingDetailCollection.LocationID;
                        VectorSessionStateContainer.DetailComment = pendingDetailCollection.Comment;

                        // flex form
                        VectorSessionStateContainer.VectorFlexForm = new FlexFormQuestionnaireGetRequestModel
                        {
                            idfsDiagnosis = pendingDetailCollection.VectorTypeID,
                            idfObservation = pendingDetailCollection.ObservationID
                        };
                    }
                }
                else
                {
                    var request = new USP_VCTS_VECTCollection_GetDetailRequestModel
                    {
                        idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey,
                        idfVector = VectorSessionStateContainer.VectorDetailedCollectionKey,
                        LangID = GetCurrentLanguage()
                    };

                    IList<USP_VCTS_VECTCollection_GetDetailResponseModel> result = await VectorClient.GetVectorDetailsCollection(request, _token);

                    if (result != null && result.Any())
                    {
                        USP_VCTS_VECTCollection_GetDetailResponseModel detailedCollection = result.First();

                        // location admin levels
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Text = detailedCollection.AdminLevel0Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel0Value = detailedCollection.AdminLevel0Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Text = detailedCollection.AdminLevel1Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value = detailedCollection.AdminLevel1Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Text = detailedCollection.AdminLevel2Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel2Value = detailedCollection.AdminLevel2Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Text = detailedCollection.AdminLevel3Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel3Value = detailedCollection.AdminLevel3Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Text = detailedCollection.AdminLevel4Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel4Value = detailedCollection.AdminLevel4Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Text = detailedCollection.AdminLevel5Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel5Value = detailedCollection.AdminLevel5Value;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Text = detailedCollection.AdminLevel6Text;
                        VectorSessionStateContainer.DetailLocationViewModel.AdminLevel6Value = detailedCollection.AdminLevel6Value;

                        // other location information
                        VectorSessionStateContainer.DetailLocationElevation = detailedCollection.intElevation;
                        VectorSessionStateContainer.DetailLocationSurroundings = detailedCollection.idfsSurrounding;
                        VectorSessionStateContainer.DetailLocationDescription = detailedCollection.strDescription;
                        VectorSessionStateContainer.DetailLocationID = detailedCollection.idfLocation;
                        VectorSessionStateContainer.DetailLocationDistance = detailedCollection.dblDistance;
                        VectorSessionStateContainer.DetailLocationGroundTypeID = detailedCollection.idfsGroundType;
                        VectorSessionStateContainer.DetailGeoLocationTypeID = detailedCollection.idfsGeoLocationType;
                        VectorSessionStateContainer.DetailLocationViewModel.StreetText = detailedCollection.strStreetName;
                        VectorSessionStateContainer.DetailLocationViewModel.PostalCodeText = detailedCollection.strPostCode;
                        VectorSessionStateContainer.DetailLocationViewModel.House = detailedCollection.strHouse;
                        VectorSessionStateContainer.DetailLocationViewModel.Building = detailedCollection.strBuilding;
                        VectorSessionStateContainer.DetailForeignAddress = detailedCollection.strForeignAddress;
                        VectorSessionStateContainer.DetailLocationViewModel.Latitude = detailedCollection.dblLatitude;
                        VectorSessionStateContainer.DetailLocationViewModel.Longitude = detailedCollection.dblLongitude;
                        VectorSessionStateContainer.DetailLocationViewModel.Apartment = detailedCollection.strApartment;

                        // collection data
                        VectorSessionStateContainer.DetailQuantity = detailedCollection.intQuantity;
                        VectorSessionStateContainer.DetailEctoparasitesCollectedID = detailedCollection.idfsEctoparasitesCollected;
                        VectorSessionStateContainer.DetailCollectionTimePeriodID = detailedCollection.idfsDayPeriod;
                        VectorSessionStateContainer.DetailCollectionMethodID = detailedCollection.idfsCollectionMethod;
                        VectorSessionStateContainer.DetailHostReferenceID = detailedCollection.idfHostVector;
                        VectorSessionStateContainer.DetailBasisOfRecordID = detailedCollection.idfsBasisOfRecord;
                        VectorSessionStateContainer.DetailIdentifiedByMethodID = detailedCollection.idfsIdentificationMethod;
                        VectorSessionStateContainer.DetailIdentifiedDate = detailedCollection.datIdentifiedDateTime;
                        VectorSessionStateContainer.DetailIdentifiedByInstitutionID = detailedCollection.idfIdentifiedByOffice;
                        VectorSessionStateContainer.DetailIdentifiedByPersonID = detailedCollection.idfIdentifiedByPerson;
                        VectorSessionStateContainer.DetailObservationID = detailedCollection.idfObservation;
                        VectorSessionStateContainer.DetailGeoReferenceSource = detailedCollection.strGEOReferenceSources;
                        VectorSessionStateContainer.DetailSessionID = detailedCollection.strVectorID;
                        VectorSessionStateContainer.DetailFieldSessionID = detailedCollection.strFieldVectorID;
                        VectorSessionStateContainer.DetailFieldPoolVectorID = detailedCollection.strFieldVectorID;
                        VectorSessionStateContainer.DetailPoolVectorIID = detailedCollection.strVectorID;
                        VectorSessionStateContainer.DetailCollectionDate = detailedCollection.datCollectionDateTime;
                        VectorSessionStateContainer.DetailVectorTypeID = detailedCollection.idfsVectorType;
                        VectorSessionStateContainer.DetailSpeciesSexID = detailedCollection.idfsSex;
                        VectorSessionStateContainer.DetailSpeciesID = detailedCollection.idfsVectorSubType;
                        VectorSessionStateContainer.DetailCollectedByInstitutionID = detailedCollection.idfCollectedByOffice;
                        VectorSessionStateContainer.DetailCollectedByPersonID = detailedCollection.idfCollectedByPerson;
                        VectorSessionStateContainer.DetailLocationID = detailedCollection.idfLocation;
                        VectorSessionStateContainer.DetailComment = detailedCollection.strComment;

                        // flex form
                        VectorSessionStateContainer.VectorFlexForm = new FlexFormQuestionnaireGetRequestModel
                        {
                            idfsDiagnosis = detailedCollection.idfsVectorType,
                            idfObservation = detailedCollection.idfObservation
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        #endregion Get Detailed Collection Details

        #region Switch Location Configuration

        public async Task SwitchLocation(long? geoLocationType, LocationViewModel model, VectorTabs selectedTab)
        {
            var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId), Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId));

            // reset to defaults
            model.AdminLevel0Value = siteDetails.CountryID;
            model.ShowAdminLevel0 = false;
            model.IsDbRequiredAdminLevel0 = false;
            model.ShowAdminLevel1 = true;
            model.ShowAdminLevel2 = true;
            model.ShowAdminLevel3 = true;
            model.IsDbRequiredAdminLevel1 = false;
            model.IsDbRequiredAdminLevel2 = false;
            model.IsDbRequiredAdminLevel3 = false;
            model.EnableAdminLevel1 = !VectorSessionStateContainer.ReportDisabledIndicator;
            model.EnableAdminLevel2 = !VectorSessionStateContainer.ReportDisabledIndicator;
            model.EnableAdminLevel3 = !VectorSessionStateContainer.ReportDisabledIndicator;
            model.IsDbRequiredAdminLevel4 = false;
            model.IsDbRequiredAdminLevel5 = false;
            model.ShowAdminLevel4 = false;
            model.ShowAdminLevel5 = false;
            model.ShowAdminLevel6 = false;
            model.ShowSettlement = true;
            model.ShowSettlementType = true;
            model.EnableSettlementType =
                !VectorSessionStateContainer.ReportDisabledIndicator;
            model.EnableStreet = false;
            model.EnablePostalCode = false;
            model.ShowPostalCode = false;
            model.ShowStreet = false;
            model.ShowApartment = false;
            model.ShowBuilding = false;
            model.ShowHouse = false;
            model.ShowBuildingHouseApartmentGroup = false;
            model.DivCoordinates = true;
            model.DivLatitude = true;
            model.DivLatitude = true;
            model.DivMap = true;
            model.ShowCoordinates = true;
            model.ShowLatitude = true;
            model.ShowLongitude = true;
            model.EnabledLongitude =
                !VectorSessionStateContainer.ReportDisabledIndicator;
            model.EnabledLatitude =
                !VectorSessionStateContainer.ReportDisabledIndicator;
            model.ShowMap = !VectorSessionStateContainer.ReportDisabledIndicator;
            model.ShowElevation = false;
            model.ShowLocationDirection = false;
            model.ShowLocationDistance = false;
            model.ShowGroundTypes = false;
            model.ShowLocationDescription = false;
            model.ShowLocationAddress = false;
            if (VectorSessionStateContainer.ReportDisabledIndicator)
                model.OperationType = LocationViewOperationType.ReadOnly;

            switch (geoLocationType)
            {
                case EIDSSConstants.GeoLocationTypes.ExactPoint: //Exact Point
                    model.IsDbRequiredAdminLevel1 = true;
                    model.IsDbRequiredAdminLevel2 = true;
                    model.ShowLocationDescription = true;

                    break;

                case EIDSSConstants.GeoLocationTypes.RelativePoint: // Relative Point
                    model.ShowGroundTypes = true;
                    model.ShowLocationDirection = true;
                    model.ShowLocationDistance = true;
                    model.ShowLocationDescription = true;
                    model.IsDbRequiredAdminLevel1 = true;
                    model.IsDbRequiredAdminLevel2 = true;
                    model.IsDbRequiredAdminLevel3 = true;
                    model.IsDbRequiredAdminLevel4 = true;
                    break;

                case EIDSSConstants.GeoLocationTypes.Foreign: // Foreign Address
                    model.ShowLocationAddress = true;
                    model.ShowAdminLevel0 = true;
                    model.EnableAdminLevel0 = true;
                    model.IsDbRequiredAdminLevel0 = true;
                    model.ShowAdminLevel1 = false;
                    model.ShowAdminLevel2 = false;
                    model.ShowAdminLevel3 = false;
                    model.ShowAdminLevel4 = false;
                    model.ShowAdminLevel5 = false;
                    model.ShowAdminLevel6 = false;
                    model.ShowSettlement = false;
                    model.ShowSettlementType = false;
                    model.ShowLatitude = false;
                    model.ShowLongitude = false;
                    model.ShowElevation = false;
                    model.ShowMap = false;
                    break;

                case EIDSSConstants.GeoLocationTypes.National: // National
                    model.ShowAdminLevel0 = true;
                    model.IsDbRequiredAdminLevel0 = false;
                    model.ShowAdminLevel1 = false;
                    model.ShowAdminLevel2 = false;
                    model.ShowAdminLevel3 = false;
                    model.ShowAdminLevel4 = false;
                    model.ShowAdminLevel5 = false;
                    model.ShowAdminLevel6 = false;
                    model.ShowSettlement = false;
                    model.ShowSettlementType = false;
                    model.ShowLatitude = false;
                    model.ShowLongitude = false;
                    model.ShowElevation = false;
                    model.ShowMap = false;
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Switch Location Configuration

        #region Set Disease and Matrix Strings

        protected string SetVectorTypeString(long vectorSessionSummaryKey)
        {
            var vectorString = Empty;
            var separator = Empty;

            //generate the list of diseases and positive quantity for this aggregate collection
            if (VectorSessionStateContainer.AggregateCollectionList is null) return vectorString;

            var vectorList = VectorSessionStateContainer.AggregateCollectionList
                .Where(x => x.idfsVSSessionSummary == VectorSessionStateContainer.VectorSessionSummaryKey).ToList();
            foreach (var item in vectorList)
            {
                if (vectorList.IndexOf(item) != vectorList.LastIndexOf(item))
                {
                    separator = "; ";
                }

                vectorString += $"{item.strVectorType}{separator}";
            }

            return vectorString;
        }

        protected string SetDiseaseListString(long vectorSessionSummaryKey)
        {
            var diseaseString = Empty;
            var separator = Empty;

            //generate the list of diseases and positive quantity for this aggregate collection
            if (VectorSessionStateContainer.AggregateCollectionDiseaseList is null) return diseaseString;

            var diseaseList = VectorSessionStateContainer.AggregateCollectionDiseaseList
                .Where(x => x.idfsVSSessionSummary == vectorSessionSummaryKey).ToList();
            foreach (var dss in diseaseList)
            {
                if (diseaseList.IndexOf(dss) != diseaseList.LastIndexOf(dss))
                {
                    separator = "; ";
                }

                diseaseString += $"{dss.DiseaseName}{separator}";
            }

            return diseaseString;
        }

        #endregion Set Disease and Matrix Strings

        #endregion Methods
    }
}