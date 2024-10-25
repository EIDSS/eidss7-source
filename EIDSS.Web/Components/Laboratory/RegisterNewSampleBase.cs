#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Human.Person;
using EIDSS.Web.Components.Human.SearchActiveSurveillanceSession;
using EIDSS.Web.Components.Human.SearchDiseaseReport;
using EIDSS.Web.Components.Human.SearchPerson;
using EIDSS.Web.Components.Outbreak.Case.Veterinary.SearchCase;
using EIDSS.Web.Components.Vector.SearchVectorSurveillanceSession;
using EIDSS.Web.Components.Veterinary.Farm;
using EIDSS.Web.Components.Veterinary.SearchActiveSurveillanceSession;
using EIDSS.Web.Components.Veterinary.SearchDiseaseReport;
using EIDSS.Web.Components.Veterinary.SearchFarm;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class RegisterNewSampleBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<RegisterNewSampleBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }
        [Inject] private IHumanActiveSurveillanceSessionClient HumanActiveSurveillanceSessionClient { get; set; }
        [Inject] private IVectorClient VectorClient { get; set; }
        [Inject] private IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        private List<FilteredDiseaseGetListViewModel> AllDiseases { get; set; }
        public List<FilteredDiseaseGetListViewModel> FilteredDiseases { get; set; }
        public IEnumerable<BaseReferenceViewModel> ReportOrSessionTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> SampleCategoryTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> FilteredSampleCategoryTypes { get; set; }
        private List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> DiseaseSpeciesSampleTypes { get; set; }
        public List<BaseReferenceViewModel> SampleTypes { get; set; }
        public List<ActiveSurveillanceSessionDetailedInformationResponseModel> Patients { get; set; }
        public List<FarmViewModel> FarmsOrFarmOwners { get; set; }
        public List<BaseReferenceViewModel> SpeciesTypes { get; set; }
        public List<FarmInventoryGetListViewModel> Species { get; set; }
        public List<USP_VCTS_VECT_GetDetailResponseModel> Vectors { get; set; }
        public RegisterNewSampleViewModel Model { get; set; }
        protected RadzenTemplateForm<RegisterNewSampleViewModel> Form { get; set; }
        protected InterfaceEditorResource Disease { get; set; }
        protected RadzenDropDown<long?> DiseaseDropDown { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #region Constants

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public RegisterNewSampleBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected RegisterNewSampleBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecyle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            Model = new RegisterNewSampleViewModel
            {
                CollectionDate = DateTime.Now,
                NumberOfSamples = 1, 
                NewRecordAddedIndicator = false
            };

            base.OnInitialized();
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

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSampleCategoryTypes(LoadDataArgs args)
        {
            try
            {
                if (SampleCategoryTypes is null || !SampleCategoryTypes.Any())
                {
                    var organization =
                        await OrganizationClient.GetOrganizationDetail(GetCurrentLanguage(),
                            authenticatedUser.OfficeId);
                    var list = await CrossCuttingClient
                        .GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseType,
                            HACodeList.NoneHACode)
                        .ConfigureAwait(false);
                    var item = list.Find(x => x.IdfsBaseReference == (long) CaseTypeEnum.Veterinary);
                    if (item != null) list.Remove(item);

                    var accessoryCodesSplit = organization.AccessoryCodeIDsString.Split(",");
                    var organizationSampleCategoryTypeList = new List<BaseReferenceViewModel>();
                    // Only add the sample categories that match the logged on user's organization accessory codes.
                    foreach (var t in accessoryCodesSplit)
                    {
                        item = list.Find(x => x.IntHACode == Convert.ToInt32(t));
                        if (item != null) organizationSampleCategoryTypeList.Add(item);
                    }

                    SampleCategoryTypes = organizationSampleCategoryTypeList.AsODataEnumerable();
                }

                if (!IsNullOrEmpty(args.Filter))
                    FilteredSampleCategoryTypes =
                        SampleCategoryTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));
                else
                    FilteredSampleCategoryTypes = SampleCategoryTypes;

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetReportOrSessionTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.ReportOrSessionTypeList, HACodeList.NoneHACode).ConfigureAwait(false);

                ReportOrSessionTypes = list.AsODataEnumerable();

                if (Model.SampleCategoryTypeID is not null)
                    ReportOrSessionTypes = Model.SampleCategoryTypeID switch
                    {
                        (long) CaseTypeEnum.Human => ReportOrSessionTypes.Where(c =>
                            c.Name != null && c.IntHACode == (int) AccessoryCodeEnum.Human),
                        (long) CaseTypeEnum.Vector => ReportOrSessionTypes.Where(c =>
                            c.Name != null && c.IntHACode == (int) AccessoryCodeEnum.Vector),
                        (long) CaseTypeEnum.Avian => ReportOrSessionTypes.Where(c =>
                            (c.Name != null && c.IntHACode == (int) AccessoryCodeEnum.Avian) ||
                            c.IntHACode == (int) AccessoryCodeEnum.AvianAndLivestock),
                        (long) CaseTypeEnum.Livestock => ReportOrSessionTypes.Where(c =>
                            (c.Name != null && c.IntHACode == (int) AccessoryCodeEnum.Livestock) ||
                            c.IntHACode == (int) AccessoryCodeEnum.AvianAndLivestock),
                        _ => ReportOrSessionTypes
                    };

                if (!IsNullOrEmpty(args.Filter))
                    ReportOrSessionTypes =
                        ReportOrSessionTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <param name="accessoryCode"></param>
        /// <returns></returns>
        public async Task GetSampleTypes(LoadDataArgs args, int? accessoryCode)
        {
            try
            {
                if (accessoryCode is null)
                    SampleTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.SampleType, HACodeList.NoneHACode).ConfigureAwait(false);
                else
                    SampleTypes = await CrossCuttingClient
                        .GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.SampleType,
                            (int) accessoryCode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    SampleTypes =
                        SampleTypes.Where(c =>
                                c.Name != null && c.Name.Contains(args.Filter,
                                    StringComparison.CurrentCultureIgnoreCase))
                            .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <param name="accessoryCode"></param>
        /// <returns></returns>
        public async Task GetSpeciesTypes(LoadDataArgs args, int? accessoryCode)
        {
            try
            {
                if (accessoryCode is null)
                    SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.SpeciesList, HACodeList.NoneHACode).ConfigureAwait(false);
                else
                    SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.SpeciesList, (int) accessoryCode).ConfigureAwait(false);

                SpeciesTypes = SpeciesTypes.Where(c => c.Name != null).ToList();

                if (!IsNullOrEmpty(args.Filter))
                    SpeciesTypes = SpeciesTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase))
                        .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetVectorSpeciesTypes(LoadDataArgs args)
        {
            try
            {
                SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.VectorType, HACodeList.NoneHACode).ConfigureAwait(false);

                SpeciesTypes = SpeciesTypes.Where(c => c.Name != null).ToList();

                if (!IsNullOrEmpty(args.Filter))
                    SpeciesTypes = SpeciesTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase))
                        .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <param name="accessoryCode"></param>
        /// <returns></returns>
        public async Task GetDiseases(LoadDataArgs args, int? accessoryCode)
        {
            try
            {
                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = accessoryCode ?? HACodeList.NoneHACode,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    UsingType = (long) DiseaseUsingTypes.Standard,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                AllDiseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
                FilteredDiseases = AllDiseases;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Category Type Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnSampleCategoryTypeChange(object value)
        {
            try
            {
                Model.ActiveSurveillanceSessionID = null;
                Model.ReportOrSessionTypeID = null;
                Model.EIDSSReportOrSessionID = null;
                Model.HumanDiseaseReportID = null;
                Model.VectorSurveillanceSessionID = null;
                Model.VectorTypeID = null;
                Model.VectorID = null;
                Model.PatientFarmOrFarmOwnerID = null;
                Model.PatientFarmOrFarmOwnerName = null;
                Model.PatientSpeciesVectorInformation = null;
                Model.VeterinaryDiseaseReportID = null;
                Model.SampleTypeID = null;
                Model.SpeciesID = null;
                Model.SpeciesTypeID = null;
                Model.DiseaseID = null;
                Model.DiseaseIDDisabledIndicator = true;
                Model.ReportOrSessionTypeIDDisabledIndicator = true;
                Model.EIDSSReportOrSessionIDRequiredIndicator = false;
                Model.PatientFarmOrFarmOwnerNameRequiredIndicator = false;
                Model.SpeciesTypeRequiredIndicator = false;
                Patients = new List<ActiveSurveillanceSessionDetailedInformationResponseModel>();
                FarmsOrFarmOwners = new List<FarmViewModel>();
                FilteredDiseases = new List<FilteredDiseaseGetListViewModel>();
                SampleTypes = new List<BaseReferenceViewModel>();

                if (value is not null)
                {
                    Model.DiseaseIDDisabledIndicator = false;
                    switch ((long) value)
                    {
                        case (long) CaseTypeEnum.Human:
                            await GetReportOrSessionTypes(new LoadDataArgs());
                            await GetSampleTypes(new LoadDataArgs(), HACodeList.HumanHACode);
                            await GetDiseases(new LoadDataArgs(), HACodeList.HumanHACode);
                            break;
                        case (long) CaseTypeEnum.Vector:
                            await GetReportOrSessionTypes(new LoadDataArgs());
                            await GetSampleTypes(new LoadDataArgs(), HACodeList.VectorHACode);
                            await GetVectorSpeciesTypes(new LoadDataArgs());
                            await GetDiseases(new LoadDataArgs(), HACodeList.VectorHACode);
                            Model.SpeciesTypeRequiredIndicator = true;
                            break;
                        case (long) CaseTypeEnum.Avian:
                            await GetReportOrSessionTypes(new LoadDataArgs());
                            await GetSampleTypes(new LoadDataArgs(), HACodeList.AvianHACode);
                            await GetSpeciesTypes(new LoadDataArgs(), HACodeList.AvianHACode);
                            await GetDiseases(new LoadDataArgs(), HACodeList.AvianHACode);
                            break;
                        case (long) CaseTypeEnum.Livestock:
                            await GetReportOrSessionTypes(new LoadDataArgs());
                            await GetSampleTypes(new LoadDataArgs(), HACodeList.LivestockHACode);
                            await GetSpeciesTypes(new LoadDataArgs(), HACodeList.LivestockHACode);
                            await GetDiseases(new LoadDataArgs(), HACodeList.LivestockHACode);
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Report/Session Type Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnReportOrSessionTypeChange(object value)
        {
            try
            {
                if (value is null)
                {
                    Model.EIDSSReportOrSessionIDRequiredIndicator = false;
                    Model.PatientFarmOrFarmOwnerNameRequiredIndicator = false;
                    Model.SpeciesTypeRequiredIndicator = false;
                }
                else
                {
                    Model.EIDSSReportOrSessionIDRequiredIndicator =
                        (long) value is (long) ReportOrSessionTypeEnum.HumanActiveSurveillanceSession
                        or (long) ReportOrSessionTypeEnum.HumanOutbreakCase
                        or (long) ReportOrSessionTypeEnum.HumanDiseaseReport
                        or (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                        or (long) ReportOrSessionTypeEnum.VeterinaryDiseaseReport
                        or (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession
                        or (long) ReportOrSessionTypeEnum.VeterinaryOutbreakCase;

                    Model.PatientFarmOrFarmOwnerNameRequiredIndicator =
                        (long) value != (long) ReportOrSessionTypeEnum.VectorSurveillanceSession;

                    if (Model.SampleCategoryTypeID is not null &&
                        Model.SampleCategoryTypeID != (long) CaseTypeEnum.Human)
                        Model.SpeciesTypeRequiredIndicator = true;
                }

                StateHasChanged();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Search Patient or Farm Owner/Farm Name Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchPatientOrFarmOwnerClick()
        {
            try
            {
                dynamic result;

                if (Model.SampleCategoryTypeID == (long) CaseTypeEnum.Human)
                {
                    result = await DiagService.OpenAsync<SearchPerson>(
                        Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchPersonHeading),
                        new Dictionary<string, object>
                        {
                            {"Mode", SearchModeEnum.SelectNoRedirect},
                            {
                                "MonitoringSessionID",
                                Model.ReportOrSessionTypeID ==
                                (long) ReportOrSessionTypeEnum.HumanActiveSurveillanceSession
                                    ? Model.ActiveSurveillanceSessionID
                                    : null
                            }
                        },
                        new DialogOptions
                        {
                            Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                            Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result != null)
                    {
                        if (result is PersonViewModel record)
                        {
                            Model.HumanMasterID = record.HumanMasterID;
                            Model.PatientFarmOrFarmOwnerName = record.LastOrSurname +
                                                               (!IsNullOrEmpty(record.FirstOrGivenName)
                                                                   ? " " + record.FirstOrGivenName
                                                                   : Empty) + (!IsNullOrEmpty(record.SecondName)
                                                                   ? " " + record.SecondName
                                                                   : Empty);

                            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;

                            if (Patients is not null && Patients.Any(x => x.HumanMasterID == Model.HumanMasterID))
                                Model.PatientFarmOrFarmOwnerID = Patients.First().PersonID;
                        }
                        else if (result == "Add")
                        {
                            result = await DiagService.OpenAsync<PersonSections>(
                                Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalPersonHeading),
                                new Dictionary<string, object> {{"ShowInDialog", true}},
                                new DialogOptions
                                {
                                    Style = LaboratoryModuleCSSClassConstants.AddPersonDialog,
                                    AutoFocusFirstElement = true,
                                    CloseDialogOnOverlayClick = false,
                                    Draggable = false,
                                    Resizable = true
                                });

                            if (result is not null)
                            {
                                if (result is PersonViewModel newRecord)
                                {
                                    Model.HumanMasterID = newRecord.HumanMasterID;
                                    Model.PatientFarmOrFarmOwnerName = newRecord.FullName;
                                }

                                Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                            }
                        }
                    }
                }
                else
                {
                    long? farmTypeId = Model.ReportOrSessionTypeID switch
                    {
                        (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession =>
                            (long) AccessoryReferenceCodes.Avian,
                        (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession =>
                            (long) AccessoryReferenceCodes.Livestock,
                        _ => null
                    };

                    result = await DiagService.OpenAsync<SearchFarm>(
                        Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchFarmHeading),
                        new Dictionary<string, object>
                        {
                            {
                                "DisableAvian",
                                Model.ReportOrSessionTypeID is (long) ReportOrSessionTypeEnum
                                    .VeterinaryAvianActiveSurveillanceSession or (long) ReportOrSessionTypeEnum
                                    .VeterinaryLivestockActiveSurveillanceSession
                            },
                            {
                                "DisableLivestock",
                                Model.ReportOrSessionTypeID is (long) ReportOrSessionTypeEnum
                                    .VeterinaryAvianActiveSurveillanceSession or (long) ReportOrSessionTypeEnum
                                    .VeterinaryLivestockActiveSurveillanceSession
                            },
                            {"Mode", SearchModeEnum.SelectNoRedirect},
                            {
                                "MonitoringSessionID",
                                Model.ReportOrSessionTypeID is (long) ReportOrSessionTypeEnum
                                        .VeterinaryAvianActiveSurveillanceSession
                                    or (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession
                                    ? Model.ActiveSurveillanceSessionID
                                    : null
                            },
                            {"FarmTypeID", farmTypeId}
                        },
                        new DialogOptions
                        {
                            Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                            Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result != null)
                    {
                        var record = result as FarmViewModel;

                        if (record is {FarmOwnerID: null})
                        {
                            Model.PatientFarmOrFarmOwnerName = record.FarmName ?? record.EIDSSFarmID;
                            Model.FarmMasterID = record.FarmMasterID;
                            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                        }
                        else if (record is not null)
                        {
                            Model.PatientFarmOrFarmOwnerName = record.FarmOwnerLastName +
                                                               (!IsNullOrEmpty(record.FarmOwnerFirstName)
                                                                   ? " " + record.FarmOwnerFirstName
                                                                   : Empty) +
                                                               (!IsNullOrEmpty(record.FarmOwnerSecondName)
                                                                   ? " " + record.FarmOwnerSecondName
                                                                   : Empty);

                            Model.HumanMasterID = record.FarmOwnerID;
                            Model.FarmMasterID = record.FarmMasterID;
                            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                        }

                        if (FarmsOrFarmOwners is not null &&
                            FarmsOrFarmOwners.Any(x => x.FarmMasterID == Model.FarmMasterID))
                        {
                            Model.FarmID = FarmsOrFarmOwners.First().FarmID;
                            Model.PatientFarmOrFarmOwnerID = FarmsOrFarmOwners.First().FarmOwnerID;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Patient or Farm Owner Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddPatientOrFarmOwnerClick()
        {
            try
            {
                dynamic result;

                if (Model.SampleCategoryTypeID == (long) CaseTypeEnum.Human)
                {
                    result = await DiagService.OpenAsync<PersonSections>(
                        Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalPersonHeading),
                        new Dictionary<string, object> {{"ShowInDialog", true}},
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.AddPersonDialog,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result is not null)
                    {
                        if (result is PersonViewModel record)
                        {
                            Model.HumanMasterID = record.HumanMasterID;
                            Model.PatientFarmOrFarmOwnerName = record.FullName;
                            Model.PatientFarmOrFarmOwnerID = record.HumanMasterID;

                            var patient = new ActiveSurveillanceSessionDetailedInformationResponseModel
                            {
                                HumanMasterID = record.HumanMasterID,
                                PersonID = record.HumanMasterID,
                                PersonName = record.FullName
                            };
                            Patients.Add(patient);
                        }

                        Model.NewRecordAddedIndicator = true;
                        Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                    }
                }
                else
                {
                    result = await DiagService.OpenAsync<FarmSections>(
                        Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalFarmHeading),
                        new Dictionary<string, object> {{"LaboratoryModuleIndicator", true}},
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.AddFarmDialog,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result is not null)
                    {
                        var record = result as FarmViewModel;

                        if (record is {FarmOwnerID: null})
                            Model.PatientFarmOrFarmOwnerName = record.FarmName ?? record.EIDSSFarmID;
                        else if (record != null) Model.PatientFarmOrFarmOwnerName = record.FarmOwnerName;

                        if (record is not null)
                        {
                            Model.HumanMasterID = record.FarmOwnerID;
                            Model.FarmMasterID = record.FarmMasterID;

                            var farmOrFarmOwner = new FarmViewModel
                            {
                                FarmMasterID = record.FarmMasterID,
                                FarmName = record.FarmName,
                                FarmOwnerFirstName = record.FarmOwnerFirstName,
                                FarmOwnerID = record.FarmOwnerID,
                                FarmOwnerLastName = record.FarmOwnerLastName,
                                FarmOwnerName = record.FarmOwnerName,
                                FarmOwnerSecondName = record.FarmOwnerSecondName,
                                FarmTypeID = record.FarmTypeID, 
                                FarmTypeName = record.FarmTypeName,
                                EIDSSFarmID = record.EIDSSFarmID,
                                EIDSSFarmOwnerID = record.EIDSSFarmOwnerID
                            };

                            if (IsNullOrEmpty(farmOrFarmOwner.FarmOwnerLastName) && IsNullOrEmpty(farmOrFarmOwner.FarmOwnerFirstName))
                            {
                                farmOrFarmOwner.FarmOwnerName = IsNullOrEmpty(farmOrFarmOwner.FarmName) ? farmOrFarmOwner.EIDSSFarmID : farmOrFarmOwner.FarmName;
                            }
                            else
                            {
                                farmOrFarmOwner.FarmOwnerName = farmOrFarmOwner.FarmOwnerLastName +
                                                               (!IsNullOrEmpty(farmOrFarmOwner.FarmOwnerFirstName)
                                                                   ? " " + farmOrFarmOwner.FarmOwnerFirstName
                                                                   : Empty) +
                                                               (!IsNullOrEmpty(farmOrFarmOwner.FarmOwnerSecondName)
                                                                   ? " " + farmOrFarmOwner.FarmOwnerSecondName
                                                                   : Empty);
                            }
                            FarmsOrFarmOwners.Add(farmOrFarmOwner);
                        }

                        Model.NewRecordAddedIndicator = true;
                        Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Report or Session Text Box Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReportOrSessionTextBoxChange()
        {
            try
            {
                switch (Model.ReportOrSessionTypeID)
                {
                    case (long) ReportOrSessionTypeEnum.HumanActiveSurveillanceSession:
                        ActiveSurveillanceSessionRequestModel humanActiveSurveillanceSessionRequest = new()
                        {
                            ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           (long) SiteTypes.ThirdLevel,
                            LanguageID = GetCurrentLanguage(),
                            SessionID = Model.EIDSSReportOrSessionID,
                            PageNumber = 1,
                            PageSize = 10,
                            SortColumn = "SessionID",
                            SortOrder = SortConstants.Descending,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserOrganizationID = authenticatedUser.OfficeId,
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };

                        var humanActiveSurveillanceSessionResult =
                            await HumanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionListAsync(
                                humanActiveSurveillanceSessionRequest, _token);

                        if (humanActiveSurveillanceSessionResult.Any())
                        {
                            Model.EIDSSReportOrSessionID = humanActiveSurveillanceSessionResult[0].SessionID;
                            Model.ActiveSurveillanceSessionID = humanActiveSurveillanceSessionResult[0].SessionKey;
                        }

                        break;
                    case (long) ReportOrSessionTypeEnum.HumanDiseaseReport:
                        HumanDiseaseReportSearchRequestModel humanDiseaseReportRequest = new()
                        {
                            ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           (long) SiteTypes.ThirdLevel,
                            LanguageId = GetCurrentLanguage(),
                            ReportID = Model.EIDSSReportOrSessionID,
                            Page = 1,
                            PageSize = 10,
                            SortColumn = "ReportID",
                            SortOrder = SortConstants.Descending,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserOrganizationID = authenticatedUser.OfficeId,
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };

                        var humanDiseaseReportResult =
                            await HumanDiseaseReportClient.GetHumanDiseaseReports(humanDiseaseReportRequest, _token);

                        if (humanDiseaseReportResult.Any())
                        {
                            Model.EIDSSReportOrSessionID = humanDiseaseReportResult[0].ReportID;
                            Model.HumanDiseaseReportID = humanDiseaseReportResult[0].ReportKey;
                            Model.PatientFarmOrFarmOwnerID = humanDiseaseReportResult[0].PersonKey;
                            Model.PatientFarmOrFarmOwnerName = humanDiseaseReportResult[0].PersonName;
                            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                            Model.DiseaseID = humanDiseaseReportResult[0].DiseaseID;
                            Model.DiseaseName = humanDiseaseReportResult[0].DiseaseName;
                        }

                        break;
                    case (long) ReportOrSessionTypeEnum.HumanOutbreakCase:
                        await InvokeAsync(StateHasChanged);
                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession:
                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession:
                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryDiseaseReport:
                        VeterinaryDiseaseReportSearchRequestModel veterinaryDiseaseReportRequest = new()
                        {
                            ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           (long) SiteTypes.ThirdLevel,
                            LanguageId = GetCurrentLanguage(),
                            ReportID = Model.EIDSSReportOrSessionID,
                            Page = 1,
                            PageSize = 10,
                            SortColumn = "ReportID",
                            SortOrder = SortConstants.Descending,
                            UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                            UserOrganizationID = authenticatedUser.OfficeId,
                            UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                        };

                        var veterinaryDiseaseReportResult =await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(veterinaryDiseaseReportRequest, _token);
                        veterinaryDiseaseReportResult = veterinaryDiseaseReportResult.DistinctBy(r => r.ReportID).ToList();

                        if (veterinaryDiseaseReportResult.Any())
                        {
                            Model.EIDSSReportOrSessionID = veterinaryDiseaseReportResult[0].ReportID;
                            Model.VeterinaryDiseaseReportID = veterinaryDiseaseReportResult[0].ReportKey;
                            Model.PatientFarmOrFarmOwnerID = veterinaryDiseaseReportResult[0].FarmOwnerKey;
                            Model.PatientFarmOrFarmOwnerName = veterinaryDiseaseReportResult[0].FarmOwnerName;
                            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                            Model.DiseaseID = veterinaryDiseaseReportResult[0].DiseaseID;
                            Model.DiseaseName = veterinaryDiseaseReportResult[0].DiseaseName;
                            Model.FarmMasterID = veterinaryDiseaseReportResult[0].FarmMasterKey;
                            Model.FarmID = veterinaryDiseaseReportResult[0].idfFarm;

                            await GetDiseaseReportSpecies();
                        }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryOutbreakCase:
                        await InvokeAsync(StateHasChanged);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Patient Drop Down Change Event

        /// <summary>
        /// </summary>
        protected void OnPatientDropDownChange()
        {
            Model.PatientFarmOrFarmOwnerName = Model.PatientFarmOrFarmOwnerID is null
                ? null
                : Patients.First(x => x.PersonID == Model.PatientFarmOrFarmOwnerID).PersonName;
        }

        #endregion

        #region Farm or Farm Owner Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnFarmOrFarmOwnerDropDownChange(object value)
        {
            Model.PatientFarmOrFarmOwnerName = Model.FarmMasterID is null
                ? null
                : FarmsOrFarmOwners.First(x => x.FarmMasterID == (Model.FarmMasterID)).FarmOwnerName;
            Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
            Model.FarmID = Model.FarmMasterID is null
                ? null
                : FarmsOrFarmOwners.First(x => x.FarmMasterID == Model.FarmMasterID).FarmID;

            if (FarmsOrFarmOwners.Any(x => x.FarmMasterID == Model.FarmMasterID))
                if (FarmsOrFarmOwners.First(x => x.FarmMasterID == Model.FarmMasterID).FarmOwnerID is null)
                    Model.PatientFarmOrFarmOwnerID = null;

            if (Model.ReportOrSessionTypeID is (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                or (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession)
            {
                Model.SpeciesID = null;
                Model.SpeciesTypeID = null;
                Species?.Clear();
                SampleTypes?.Clear();

                if (FarmsOrFarmOwners.Any(x => x.FarmMasterID == Model.FarmMasterID))
                    await GetActiveSurveillanceSessionSpecies(FarmsOrFarmOwners.First(x =>
                        x.FarmMasterID == Model.FarmMasterID));
            }
        }

        #endregion

        #region Search Report or Session ID Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchReportOrSessionIDClick()
        {
            try
            {
                dynamic result;
                switch (Model.ReportOrSessionTypeID)
                {
                    case (long) ReportOrSessionTypeEnum.HumanActiveSurveillanceSession:
                        result = await DiagService.OpenAsync<SearchHumanActiveSurveillanceSession>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalHumanActiveSurveillanceSessionHeading),
                            new Dictionary<string, object> {{"Mode", SearchModeEnum.SelectNoRedirect}},
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is ActiveSurveillanceSessionResponseModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.SessionID;

                                var personsRequest = new ActiveSurveillanceSessionDetailedInformationRequestModel
                                {
                                    LanguageId = GetCurrentLanguage(),
                                    idfMonitoringSession = record.SessionKey,
                                    Page = 1,
                                    PageSize = MaxValue - 1,
                                    SortColumn = "intOrder",
                                    SortOrder = SortConstants.Ascending
                                };
                                Patients = await HumanActiveSurveillanceSessionClient
                                    .GetActiveSurveillanceSessionDetailedInformation(personsRequest, _token);
                                Patients = Patients.DistinctBy(x => x.HumanMasterID).ToList();
                                Model.PatientFarmOrFarmOwnerNameDisabledIndicator = false;

                                var request = new ActiveSurveillanceSessionDiseaseSampleTypeRequestModel
                                {
                                    LanguageID = GetCurrentLanguage(),
                                    MonitoringSessionID = record.SessionKey
                                };
                                var diseaseSpeciesSamples =
                                    await HumanActiveSurveillanceSessionClient
                                        .GetHumanActiveSurveillanceDiseaseSampleTypeListAsync(request, _token)
                                        .ConfigureAwait(false);
                                diseaseSpeciesSamples = diseaseSpeciesSamples.DistinctBy(x => x.DiseaseID).ToList();

                                SampleTypes.Clear();
                                foreach (var baseReferenceViewModel in from diseaseSpeciesSample in
                                             diseaseSpeciesSamples
                                         where diseaseSpeciesSample.SampleTypeID != null
                                         select new BaseReferenceViewModel
                                         {
                                             IdfsBaseReference = (long) diseaseSpeciesSample.SampleTypeID,
                                             Name = diseaseSpeciesSample.SampleTypeName
                                         })
                                    SampleTypes.Add(baseReferenceViewModel);
                                SampleTypes = SampleTypes.DistinctBy(x => x.IdfsBaseReference).ToList();
                                Model.SampleTypeIDDisabledIndicator = false;

                                AllDiseases.Clear();
                                foreach (var filteredDiseaseModel in from diseaseSpeciesSample in diseaseSpeciesSamples
                                         select new FilteredDiseaseGetListViewModel
                                         {
                                             DiseaseID = diseaseSpeciesSample.DiseaseID,
                                             DiseaseName = diseaseSpeciesSample.DiseaseName,
                                             SampleTypeID = diseaseSpeciesSample.SampleTypeID
                                         })
                                    AllDiseases.Add(filteredDiseaseModel);

                                if (diseaseSpeciesSamples.Count == 1)
                                {
                                    Model.DiseaseID = diseaseSpeciesSamples.First().DiseaseID;
                                    Model.DiseaseName = diseaseSpeciesSamples.First().DiseaseName;
                                    Model.DiseaseIDDisabledIndicator = true;
                                }
                                else
                                {
                                    Model.DiseaseIDDisabledIndicator = false;
                                }

                                Model.ActiveSurveillanceSessionID = record.SessionKey;
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.HumanDiseaseReport:
                        result = await DiagService.OpenAsync<SearchHumanDiseaseReport>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalHumanDiseaseReportHeading),
                            new Dictionary<string, object> {{"Mode", SearchModeEnum.SelectNoRedirect}},
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is HumanDiseaseReportViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.ReportID;
                                Model.HumanDiseaseReportID = record.ReportKey;
                                Model.PatientFarmOrFarmOwnerID = record.PersonKey;
                                Model.PatientFarmOrFarmOwnerName = record.PersonName;
                                Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                                Model.DiseaseID = record.DiseaseID;
                                Model.DiseaseName = record.DiseaseName;
                                Model.DiseaseIDDisabledIndicator = true;
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.HumanOutbreakCase:
                        result = await DiagService.OpenAsync<SearchHumanDiseaseReport>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalHumanDiseaseReportHeading),
                            new Dictionary<string, object>
                            {
                                {"Mode", SearchModeEnum.SelectNoRedirect},
                                {"OutbreakCasesIndicator", true}
                            },
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is HumanDiseaseReportViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.ReportID;
                                Model.HumanDiseaseReportID = record.ReportKey;
                                Model.PatientFarmOrFarmOwnerID = record.PersonKey;
                                Model.PatientFarmOrFarmOwnerName = record.PersonName;
                                Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                                Model.DiseaseID = record.DiseaseID;
                                Model.DiseaseName = record.DiseaseName;
                                Model.DiseaseIDDisabledIndicator = true;
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.VectorSurveillanceSession:
                        result = await DiagService.OpenAsync<SearchVectorSurveillanceSession>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalVectorSurveillanceSessionHeading),
                            new Dictionary<string, object> {{"Mode", SearchModeEnum.SelectNoRedirect}},
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is VectorSurveillanceSessionViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.SessionID;
                                Model.VectorSurveillanceSessionID = record.SessionKey;

                                if (!IsNullOrEmpty(record.Diseases))
                                {
                                    var diseaseIDsSplit = record.DiseaseIDs.Split(";");
                                    var diseaseNamesSplit = record.Diseases.Split(";");

                                    if (diseaseIDsSplit.Length == 1)
                                    {
                                        Model.DiseaseID = Convert.ToInt64(diseaseIDsSplit[0]);
                                        Model.DiseaseName = diseaseNamesSplit[0];
                                        Model.DiseaseIDDisabledIndicator = true;
                                    }
                                    else
                                    {
                                        if (AllDiseases is null)
                                            AllDiseases = new List<FilteredDiseaseGetListViewModel>();
                                        else if (AllDiseases.Any())
                                            AllDiseases.Clear();

                                        for (var index = 0; index < diseaseIDsSplit.Length; index++)
                                            AllDiseases?.Add(new FilteredDiseaseGetListViewModel
                                            {
                                                DiseaseID = Convert.ToInt64(diseaseIDsSplit[index]),
                                                DiseaseName = diseaseNamesSplit[index]
                                            });

                                        Model.DiseaseIDDisabledIndicator = false;
                                    }
                                }

                                if (!IsNullOrEmpty(record.Vectors)) await GetSessionVectors();
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                        or (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession:
                        result = await DiagService.OpenAsync<SearchVeterinaryActiveSurveillanceSession>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalVeterinaryActiveSurveillanceSessionHeading),
                            new Dictionary<string, object>
                            {
                                {"Mode", SearchModeEnum.SelectNoRedirect},
                                {
                                    "SessionCategoryTypeID",
                                    Model.SampleCategoryTypeID == (long) CaseTypeEnum.Avian
                                        ? (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                                        : (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession
                                }
                            },
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is VeterinaryActiveSurveillanceSessionViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.SessionID;

                                var farmsOrFarmOwnersRequest = new FarmSearchRequestModel
                                {
                                    MonitoringSessionID = record.SessionKey,
                                    SortColumn = "FarmOwnerName",
                                    SortOrder = SortConstants.Ascending,
                                    Page = 1,
                                    PageSize = MaxValue - 1,
                                    LanguageId = GetCurrentLanguage()
                                };
                                FarmsOrFarmOwners = await VeterinaryClient
                                    .GetFarmListAsync(farmsOrFarmOwnersRequest, _token).ConfigureAwait(false);

                                foreach (var item in FarmsOrFarmOwners)
                                {
                                    if (item.FarmOwnerID is null)
                                        item.FarmOwnerName = item.FarmName ?? item.EIDSSFarmID;
                                    else
                                    {
                                        item.FarmOwnerName = item.FarmOwnerLastName +
                                                              (!IsNullOrEmpty(item.FarmOwnerFirstName)
                                                                  ? " " + item.FarmOwnerFirstName
                                                                  : Empty) +
                                                              (!IsNullOrEmpty(item.FarmOwnerSecondName)
                                                                  ? " " + item.FarmOwnerSecondName
                                                                  : Empty);

                                        // Farm owner ID is present, but with no name so use farm name or identifier.
                                        if (IsNullOrEmpty(item.FarmOwnerName))
                                            item.FarmOwnerName = IsNullOrEmpty(item.FarmName) ? item.EIDSSFarmID : item.FarmName;
                                    }
                                }

                                Model.PatientFarmOrFarmOwnerNameDisabledIndicator = false;

                                var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel
                                {
                                    LanguageID = GetCurrentLanguage(),
                                    MonitoringSessionID = record.SessionKey
                                };
                                DiseaseSpeciesSampleTypes =
                                    await VeterinaryClient
                                        .GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, _token)
                                        .ConfigureAwait(false);

                                SampleTypes.Clear();
                                SpeciesTypes.Clear();
                                AllDiseases.Clear();
                                foreach (var diseaseSpeciesSample in DiseaseSpeciesSampleTypes)
                                {
                                    BaseReferenceViewModel baseReferenceViewModel;
                                    if (diseaseSpeciesSample.SampleTypeID != null)
                                    {
                                        baseReferenceViewModel = new BaseReferenceViewModel
                                        {
                                            IdfsBaseReference = (long) diseaseSpeciesSample.SampleTypeID,
                                            Name = diseaseSpeciesSample.SampleTypeName
                                        };
                                        SampleTypes.Add(baseReferenceViewModel);
                                    }

                                    if (diseaseSpeciesSample.SpeciesTypeID == null) continue;
                                    baseReferenceViewModel = new BaseReferenceViewModel
                                    {
                                        IdfsBaseReference = (long) diseaseSpeciesSample.SpeciesTypeID,
                                        Name = diseaseSpeciesSample.SpeciesTypeName
                                    };
                                    SpeciesTypes.Add(baseReferenceViewModel);

                                    AllDiseases.Add(new FilteredDiseaseGetListViewModel
                                    {
                                        DiseaseID = Convert.ToInt64(diseaseSpeciesSample.DiseaseID),
                                        DiseaseName = diseaseSpeciesSample.DiseaseName,
                                        SampleTypeID = diseaseSpeciesSample.SampleTypeID
                                    });
                                }

                                SpeciesTypes = SpeciesTypes.DistinctBy(x => x.IdfsBaseReference).ToList();
                                SampleTypes = SampleTypes.DistinctBy(x => x.IdfsBaseReference).ToList();
                                Model.SampleTypeIDDisabledIndicator = false;

                                AllDiseases = AllDiseases.DistinctBy(x => x.DiseaseID).ToList();
                                if (AllDiseases.Count == 1)
                                {
                                    Model.DiseaseID = AllDiseases.First().DiseaseID;
                                    Model.DiseaseName = AllDiseases.First().DiseaseName;
                                    Model.DiseaseIDDisabledIndicator = true;
                                }
                                else
                                {
                                    Model.DiseaseIDDisabledIndicator = false;
                                }

                                Model.ActiveSurveillanceSessionID = record.SessionKey;
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryDiseaseReport:
                        result = await DiagService.OpenAsync<SearchVeterinaryDiseaseReport>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalVeterinaryDiseaseReportHeading),
                            new Dictionary<string, object>
                            {
                                {"Mode", SearchModeEnum.SelectNoRedirect},
                                {
                                    "ReportType",
                                    Model.SampleCategoryTypeID == (long) CaseTypeEnum.Avian
                                        ? VeterinaryReportTypeEnum.Avian
                                        : VeterinaryReportTypeEnum.Livestock
                                }
                            },
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is VeterinaryDiseaseReportViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.ReportID;
                                Model.VeterinaryDiseaseReportID = record.ReportKey;
                                Model.PatientFarmOrFarmOwnerID = record.FarmOwnerKey;
                                if (IsNullOrEmpty(record.FarmOwnerName))
                                    Model.PatientFarmOrFarmOwnerName = IsNullOrEmpty(record.FarmName) ? record.FarmID : record.FarmName;
                                else
                                    Model.PatientFarmOrFarmOwnerName = record.FarmOwnerName;
                                Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                                Model.DiseaseID = record.DiseaseID;
                                Model.DiseaseName = record.DiseaseName;
                                Model.DiseaseIDDisabledIndicator = true;
                                Model.FarmID = record.idfFarm;
                                Model.FarmMasterID = record.FarmMasterKey;

                                await GetDiseaseReportSpecies();
                            }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryOutbreakCase:
                        result = await DiagService.OpenAsync<SearchVeterinaryCase>(
                            Localizer.GetString(HeadingResourceKeyConstants
                                .RegisterNewSampleModalOutbreakCaseHeading),
                            new Dictionary<string, object>
                            {
                                {"Mode", SearchModeEnum.SelectNoRedirect},
                                {
                                    "ReportType",
                                    Model.SampleCategoryTypeID == (long) CaseTypeEnum.Avian
                                        ? VeterinaryReportTypeEnum.Avian
                                        : VeterinaryReportTypeEnum.Livestock
                                }
                            },
                            new DialogOptions
                            {
                                Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                                Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                            if (result is VeterinaryCaseGetListViewModel record)
                            {
                                Model.EIDSSReportOrSessionID = record.CaseID;
                                Model.VeterinaryDiseaseReportID = record.DiseaseReportKey;
                                Model.PatientFarmOrFarmOwnerID = record.FarmOwnerKey;
                                if (IsNullOrEmpty(record.FarmOwnerName))
                                    Model.PatientFarmOrFarmOwnerName = IsNullOrEmpty(record.FarmName) ? record.FarmID : record.FarmName;
                                else
                                    Model.PatientFarmOrFarmOwnerName = record.FarmOwnerName;
                                Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                                Model.DiseaseID = record.DiseaseID;
                                Model.DiseaseName = record.DiseaseName;
                                Model.DiseaseIDDisabledIndicator = true;

                                await GetDiseaseReportSpecies();
                            }

                        break;
                }

                FilteredDiseases = AllDiseases;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Get Species Methods

        /// <summary>
        /// </summary>
        /// <param name="farm"></param>
        /// <returns></returns>
        private async Task GetActiveSurveillanceSessionSpecies(FarmViewModel farm)
        {
            if (Model.ActiveSurveillanceSessionID != null)
            {
                var farmInventoryRequest = new FarmInventoryGetListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    FarmID = farm.FarmID,
                    FarmMasterID = farm.FarmMasterID,
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "RecordID",
                    SortOrder = SortConstants.Ascending
                };

                var list = await VeterinaryClient.GetFarmInventoryList(farmInventoryRequest, _token)
                    .ConfigureAwait(false);
                if (list.Any(x => x.RecordType == RecordTypeConstants.Species))
                    Species = new List<FarmInventoryGetListViewModel>();

                foreach (var farmInventoryItem in list.Where(x => x.RecordType == RecordTypeConstants.Species))
                    if (farmInventoryItem.SpeciesTypeID != null)
                        Species.Add(farmInventoryItem);

                await InvokeAsync(StateHasChanged);
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task GetDiseaseReportSpecies()
        {
            if (Model.VeterinaryDiseaseReportID != null)
            {
                DiseaseReportGetDetailRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "EIDSSReportID",
                    SortOrder = SortConstants.Ascending,
                    DiseaseReportID = (long) Model.VeterinaryDiseaseReportID
                };
                var diseaseReport = await VeterinaryClient.GetDiseaseReportDetail(request, _token);

                var farmId = diseaseReport.First().FarmID;
                if (farmId != null)
                {
                    var farmInventoryRequest = new FarmInventoryGetListRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        DiseaseReportID = diseaseReport.First().DiseaseReportID,
                        FarmID = (long) farmId,
                        FarmMasterID = diseaseReport.First().FarmMasterID,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "RecordID",
                        SortOrder = SortConstants.Ascending
                    };

                    var list = await VeterinaryClient.GetFarmInventoryList(farmInventoryRequest, _token)
                        .ConfigureAwait(false);
                    if (list.Any(x => x.RecordType == RecordTypeConstants.Species))
                        Species = new List<FarmInventoryGetListViewModel>();
                    else
                        Model.FarmMasterID = diseaseReport.First().FarmMasterID;

                    foreach (var farmInventoryItem in list.Where(x => x.RecordType == RecordTypeConstants.Species))
                        if (farmInventoryItem.SpeciesTypeID != null)
                            Species.Add(farmInventoryItem);
                }
                else
                {
                    Model.FarmMasterID = diseaseReport.First().FarmMasterID;
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task GetSessionVectors()
        {
            if (Model.VectorSurveillanceSessionID != null)
            {
                var request = new USP_VCTS_VECT_GetDetailRequestModel
                {
                    LangID = GetCurrentLanguage(),
                    idfVectorSurveillanceSession = Model.VectorSurveillanceSessionID,
                    PageNumber = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "strVectorType",
                    SortOrder = SortConstants.Ascending
                };
                Vectors = await VectorClient.GetVectorDetails(request, _token);
            }
        }

        #endregion

        #region Species Type Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnSpeciesTypeChange(object value)
        {
            try
            {
                if (value is null) return;
                switch (Model.ReportOrSessionTypeID)
                {
                    case (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession
                        or (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession:
                        SampleTypes.Clear();

                        if (Species is not null && Species.Any(x => x.SpeciesID == (long)value))
                        {
                            var speciesTypeId = Species.First(x => x.SpeciesID == (long)value).SpeciesTypeID;
                            foreach (var baseReferenceViewModel in from diseaseSpeciesSample in DiseaseSpeciesSampleTypes
                                     where diseaseSpeciesSample.SampleTypeID != null &&
                                           diseaseSpeciesSample.SpeciesTypeID != null &&
                                           diseaseSpeciesSample.SpeciesTypeID == speciesTypeId
                                     select new BaseReferenceViewModel
                                     {
                                         IdfsBaseReference = (long) diseaseSpeciesSample.SampleTypeID,
                                         Name = diseaseSpeciesSample.SampleTypeName
                                     })
                                SampleTypes.Add(baseReferenceViewModel);
                        }
                        else
                        {
                            foreach (var baseReferenceViewModel in from diseaseSpeciesSample in DiseaseSpeciesSampleTypes
                                     where diseaseSpeciesSample.SampleTypeID != null &&
                                           diseaseSpeciesSample.SpeciesTypeID != null &&
                                           diseaseSpeciesSample.SpeciesTypeID == (long) value
                                     select new BaseReferenceViewModel
                                     {
                                         IdfsBaseReference = (long) diseaseSpeciesSample.SampleTypeID,
                                         Name = diseaseSpeciesSample.SampleTypeName
                                     })
                                SampleTypes.Add(baseReferenceViewModel);
                        }
                        SampleTypes = SampleTypes.DistinctBy(x => x.IdfsBaseReference).ToList();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Type Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnSampleTypeChange(object value)
        {
            try
            {
                if (value is null) return;
                switch (Model.ReportOrSessionTypeID)
                {
                    case (long) ReportOrSessionTypeEnum.HumanActiveSurveillanceSession:
                        FilteredDiseases = AllDiseases.Where(x => x.SampleTypeID == (long) value).ToList();
                        if (FilteredDiseases.Count == 1)
                        {
                            Model.DiseaseID = FilteredDiseases.First().DiseaseID;
                            Model.DiseaseName = FilteredDiseases.First().DiseaseName;
                            Model.DiseaseIDDisabledIndicator = true;
                        }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryAvianActiveSurveillanceSession:
                        FilteredDiseases = AllDiseases.Where(x => x.SampleTypeID == (long) value).ToList();
                        if (FilteredDiseases.Count == 1)
                        {
                            Model.DiseaseID = FilteredDiseases.First().DiseaseID;
                            Model.DiseaseName = FilteredDiseases.First().DiseaseName;
                            Model.DiseaseIDDisabledIndicator = true;
                        }

                        break;
                    case (long) ReportOrSessionTypeEnum.VeterinaryLivestockActiveSurveillanceSession:
                        FilteredDiseases = AllDiseases.Where(x => x.SampleTypeID == (long) value).ToList();
                        if (FilteredDiseases.Count == 1)
                        {
                            Model.DiseaseID = FilteredDiseases.First().DiseaseID;
                            Model.DiseaseName = FilteredDiseases.First().DiseaseName;
                            Model.DiseaseIDDisabledIndicator = true;
                        }

                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Sample Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddSampleClick()
        {
            try
            {
                var validateSpecies = Model.SampleCategoryTypeID != (long) CaseTypeEnum.Human &&
                                      Model.SpeciesID is null && Model.SpeciesTypeID is null &&
                                      Model.VectorID is null && Model.VectorTypeID is null;
                if (Form.EditContext.Validate() && !validateSpecies)
                {
                    if (Model.ReportOrSessionTypeID is not null)
                        Model.ReportOrSessionTypeName = ReportOrSessionTypes
                            .First(x => x.IdfsBaseReference == Model.ReportOrSessionTypeID).Name;

                    Model.SampleTypeName = SampleTypes.First(x => x.IdfsBaseReference == Model.SampleTypeID).Name;

                    if (DiseaseDropDown.SelectedItem is not null)
                    {
                        Model.DiseaseID = (DiseaseDropDown.SelectedItem as FilteredDiseaseGetListViewModel)?.DiseaseID;
                        Model.DiseaseName = (DiseaseDropDown.SelectedItem as FilteredDiseaseGetListViewModel)
                            ?.DiseaseName;
                    }

                    if (Model.SampleCategoryTypeID == (long) CaseTypeEnum.Vector)
                    {
                        if (Vectors is not null && Vectors.Count > 0 && Model.VectorID is not null)
                        {
                            Model.VectorID = Vectors.First(x => x.idfVector == Model.VectorID).idfVector;
                            Model.VectorTypeID = Vectors.First(x => x.idfVector == Model.VectorID).idfsVectorType;
                            Model.SpeciesTypeID = Vectors.First(x => x.idfVector == Model.VectorID).idfsVectorSubType;
                        }
                    }

                    if (Tab == LaboratoryTabEnum.MyFavorites)
                        Model.FavoriteIndicator = true;

                    await Register(Model, Tab);

                    DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Add});
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
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