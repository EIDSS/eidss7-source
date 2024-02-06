#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
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
using EIDSS.ClientLibrary;
using EIDSS.Domain.RequestModels.Veterinary;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DetailedAnimalSampleModalBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DetailedAnimalSampleModalBase> Logger { get; set; }
        [Inject] private IConfigurationClient ConfigurationClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<SampleGetListViewModel> Form { get; set; }
        protected RadzenDropDown<IEnumerable<long>> DiseaseDropDown { get; set; }
        public IList<FarmViewModel> Farms { get; set; }
        public IList<FarmInventoryGetListViewModel> Species { get; set; }
        public IList<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public IList<BaseReferenceViewModel> SampleTypes { get; set; }
        public IList<AnimalGetListViewModel> Animals { get; set; }
        public IList<ConfigurationMatrixViewModel> AnimalAges { get; set; }
        public IList<BaseReferenceViewModel> AnimalSexes { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> SentToOrganizations { get; set; }

        public string FilterSamplesByDiseaseFieldLabelResourceKey { get; set; }
        public string LabSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string FieldSampleIdFieldLabelResourceKey { get; set; }
        public string AnimalIdFieldLabelResourceKey { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string BirdStatusFieldLabelResourceKey { get; set; }
        public string AccessionDateFieldLabelResourceKey { get; set; }
        public string SampleConditionReceivedFieldLabelResourceKey { get; set; }
        public string CollectionDateFieldLabelResourceKey { get; set; }
        public string CollectedByInstitutionFieldLabelResourceKey { get; set; }
        public string CollectedByOfficerFieldLabelResourceKey { get; set; }
        public string SentDateFieldLabelResourceKey { get; set; }
        public string SentToOrganizationFieldLabelResourceKey { get; set; }
        public string AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey { get; set; }
        public string CollectionDateSentDateCompareValidatorResourceKey { get; set; }

        protected bool SpeciesIsDisabled { get; set; }
        protected bool SampleTypeIsDisabled { get; set; }
        protected bool DiseaseIsDisabled { get; set; }
        protected bool AnimalControlsDisabled { get; set; }
        protected bool FieldSampleIdDisabled { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            SetAnimalId();

            SetFieldOrLocalSampleId();

            FilterSamplesByDiseaseFieldLabelResourceKey =
                Localizer.GetString(FieldLabelResourceKeyConstants.FilterSamplesByDiseaseLabel);

            if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
            {
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalSampleTypeFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalFieldSampleIDFieldLabel;
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalSpeciesFieldLabel;
                BirdStatusFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalBirdStatusFieldLabel;
                AccessionDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalAccessionDateFieldLabel;
                SampleConditionReceivedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalSampleConditionReceivedFieldLabel;
                AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalAdditionalTestRequestedAndSampleNotesFieldLabel;
                CollectionDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalCollectionDateFieldLabel;
                CollectedByInstitutionFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalCollectionByInstitutionFieldLabel;
                CollectedByOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalCollectionByOfficerFieldLabel;
                SentDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalSentDateFieldLabel;
                SentToOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSampleDetailsModalSentToOrganizationFieldLabel;

                CollectionDateSentDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .AvianDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage;
            }
            else
            {
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalSampleTypeFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalFieldSampleIDFieldLabel;
                AnimalIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalAnimalIDFieldLabel;
                AccessionDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalAccessionDateFieldLabel;
                SampleConditionReceivedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalSampleConditionReceivedFieldLabel;
                AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalAdditionalTestRequestedAndSampleNotesFieldLabel;
                CollectionDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalCollectionDateFieldLabel;
                CollectedByInstitutionFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalCollectionByInstitutionFieldLabel;
                CollectedByOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalCollectionByOfficerFieldLabel;
                SentDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalSentDateFieldLabel;
                SentToOrganizationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalSentToOrganizationFieldLabel;

                CollectionDateSentDateCompareValidatorResourceKey = MessageResourceKeyConstants
                    .LivestockDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage;
            }

            await GetSentToOrganizations(new LoadDataArgs()).ConfigureAwait(false);

            await base.OnInitializedAsync().ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Farms

        protected void GetFarms(LoadDataArgs args)
        {
            try
            {
                Farms ??= new List<FarmViewModel>();

                // get the farms list from the session farms list
                if (StateContainer.Farms != null && StateContainer.Farms.Any())
                {
                    Farms = StateContainer.Farms;
                }

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    Farms = Farms.Where(f => f.FarmMasterID != null && (f.EIDSSFarmID.Contains(args.Filter)
                                                                        || f.FarmName.Contains(args.Filter))).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnFarmChange(object value)
        {
            if (value is null)
            {
                StateContainer.AnimalSampleDetail.SpeciesID = null;
                StateContainer.AnimalSampleDetail.Species = null;
                StateContainer.AnimalSampleDetail.SpeciesTypeID = null;
                StateContainer.AnimalSampleDetail.SpeciesTypeName = null;
                SpeciesIsDisabled = true;
            }
            else
            {
                StateContainer.AnimalSampleDetail.FarmMasterID = (long)value;
                if (StateContainer.Farms != null && StateContainer.Farms.Any(x => x.FarmMasterID == (long)value))
                {
                    StateContainer.AnimalSampleDetail.FarmID =
                        StateContainer.Farms.First(x => x.FarmMasterID == (long)value).FarmID;
                }
                SpeciesIsDisabled = false;
                Species = null;
                await GetSpecies(new LoadDataArgs());
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Species

        protected async Task GetSpecies(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.AnimalSampleDetail.FarmMasterID != null)
                {
                    // see if the species already exist in the current farm inventory
                    var species = StateContainer.FarmInventory?.Where(x =>
                        x.FarmMasterID == StateContainer.AnimalSampleDetail.FarmMasterID
                        && x.RowStatus != (long)RowStatusTypeEnum.Inactive
                        && x.RecordType == RecordTypeConstants.Species).ToList();

                    // did not find the selected farm in the current farm inventory
                    //  so try to get the species from the api
                    if (species is null or { Count: 0 })
                    {
                        var request = new FarmInventoryGetListRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = int.MaxValue - 1,
                            SortColumn = "RecordID",
                            SortOrder = SortConstants.Ascending,
                            FarmMasterID = StateContainer.AnimalSampleDetail.FarmMasterID,
                            MonitoringSessionID = null,
                            FarmID = StateContainer.Farms.FirstOrDefault(x =>
                                x.FarmMasterID == StateContainer.AnimalSampleDetail.FarmMasterID &&
                                x.FarmID.GetValueOrDefault() > 0)?.FarmID
                        };

                        var farmInventory = await VeterinaryClient.GetFarmInventoryList(request, _token);
                        if (farmInventory is { Count: 0 })
                        {
                            // no inventory found by farm so check the entire session
                            request.FarmMasterID = null;
                            request.MonitoringSessionID = StateContainer.SessionKey;
                            request.FarmID = null;
                            farmInventory = await VeterinaryClient.GetFarmInventoryList(request, _token);
                        }

                        if (farmInventory is { Count: > 0 })
                        {
                            species = farmInventory.Where(x =>
                                x.FarmMasterID == StateContainer.AnimalSampleDetail.FarmMasterID
                                && x.RowStatus != (long)RowStatusTypeEnum.Inactive
                                && x.RecordType == RecordTypeConstants.Species).ToList();
                        }
                    }

                    Species = species?.ToList();

                    // filter by filter criteria
                    if (!string.IsNullOrEmpty(args.Filter))
                    {
                        Species = Species?.Where(s => s.SpeciesTypeName != null && s.SpeciesTypeName.Contains(args.Filter)).ToList();
                    }

                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnSpeciesChange(object value)
        {
            if (value is null)
            {
                StateContainer.AnimalSampleDetail.SampleTypeID = 0;
                SampleTypeIsDisabled = true;
            }
            else
            {
                SampleTypeIsDisabled = false;
                StateContainer.AnimalSampleDetail.SpeciesTypeID =
                    Species.First(f => f.SpeciesID == (long)value).SpeciesTypeID;
                await GetAnimalAges(new LoadDataArgs());
                await GetSampleTypes(new LoadDataArgs());
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Sample Types

        protected async Task GetSampleTypes(LoadDataArgs args)
        {
            try
            {
                SampleTypes ??= new List<BaseReferenceViewModel>();

                if (string.IsNullOrEmpty(args.Filter))
                {
                    SampleTypes = new List<BaseReferenceViewModel>();
                }

                // get the samples list from the Disease Species Sample Grid
                if (StateContainer.DiseaseSpeciesSamples is { Count: > 0 })
                {
                    var sampleTypes = StateContainer.DiseaseSpeciesSamples.Where(f =>
                        f.SpeciesTypeID == StateContainer.AnimalSampleDetail.SpeciesTypeID)
                        .Select(sample => new
                        {
                            sample.SampleTypeID,
                            sample.SampleTypeName
                        }).Distinct().ToList();
                    foreach (var sampleType in sampleTypes)
                    {
                        SampleTypes.Add(new BaseReferenceViewModel()
                        {
                            IdfsBaseReference = (long)sampleType.SampleTypeID,
                            Name = sampleType.SampleTypeName
                        });
                    }
                }

                if (!IsNullOrEmpty(args.Filter))
                    SampleTypes = SampleTypes.Where(c => c.Name != null && c.Name.StartsWith(args.Filter)).ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void OnSampleTypeChange(object value)
        {
            if (value is null)
            {
                StateContainer.AnimalSampleDetail.SelectedDiseases = null;
                DiseaseIsDisabled = true;
            }
            else
            {
                DiseaseIsDisabled = false;
                Diseases = null;
                GetDiseases(new LoadDataArgs());
            }
        }

        #endregion

        #region Diseases

        public void GetDiseases(LoadDataArgs args)
        {
            try
            {
                Diseases ??= new List<FilteredDiseaseGetListViewModel>();

                if (string.IsNullOrEmpty(args.Filter))
                {
                    Diseases = new List<FilteredDiseaseGetListViewModel>();
                }

                // get the diseases list from the Disease Species Sample Grid
                if (StateContainer.DiseaseSpeciesSamples is { Count: > 0 })
                {
                    var diseases = StateContainer.DiseaseSpeciesSamples.Where(f =>
                        f.SampleTypeID == StateContainer.AnimalSampleDetail.SampleTypeID
                        && f.SpeciesTypeID == StateContainer.AnimalSampleDetail.SpeciesTypeID);
                    foreach (var disease in diseases)
                    {
                        Diseases.Add(new FilteredDiseaseGetListViewModel()
                        {
                            DiseaseID = (long)disease.DiseaseID,
                            DiseaseName = disease.DiseaseName
                        });
                    }
                }

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    Diseases = Diseases.Where(d => d.DiseaseName != null && d.DiseaseName.Contains(args.Filter)).ToList();
                }
                if (Diseases.Count == 1)
                {
                    StateContainer.AnimalSampleDetail.SelectedDiseases = Diseases.Select(x => x.DiseaseID).ToList();
                    OnDiseaseChange(StateContainer.AnimalSampleDetail.SelectedDiseases);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void OnDiseaseChange(object value)
        {
            if (value is null)
            {
                if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                {
                    StateContainer.AnimalSampleDetail.AnimalID = null;
                    StateContainer.AnimalSampleDetail.AnimalName = null;
                    StateContainer.AnimalSampleDetail.EIDSSAnimalID = null;
                    AnimalControlsDisabled = true;
                }

                FieldSampleIdDisabled = true;
            }
            else
            {
                if (value is not IEnumerable<long> enumerable) return;

                var selectedItems = enumerable.ToList();
                if (selectedItems.Count == 0)
                {
                    StateContainer.AnimalSampleDetail.SelectedDiseases = null;
                }
                else
                {
                    var unselectedItems = StateContainer.AnimalSampleToDiseases.Where(x => !selectedItems.Contains(x.DiseaseID)
                        && x.SampleID == StateContainer.AnimalSampleDetail.SampleID
                        && x.SampleTypeID == StateContainer.AnimalSampleDetail.SampleTypeID).ToList();
                    foreach (var item in unselectedItems)
                    {
                        var record = item.ShallowCopy();
                        record.RowAction = (int)RowActionTypeEnum.Update;
                        record.RowStatus = (int)RowStatusTypeEnum.Inactive;

                        StateContainer.AnimalSampleToDiseases.Remove(item);
                        TogglePendingSaveAnimalSampleToDiseases(record, item);
                    }

                    AnimalControlsDisabled = false;
                    FieldSampleIdDisabled = false;
                    SetFieldOrLocalSampleId();
                    GetAnimals(new LoadDataArgs());
                    SetAnimalId();
                }
            }
        }

        #endregion

        #region Field Sample Id

        private void SetFieldOrLocalSampleId()
        {
            if (StateContainer.AnimalSampleDetail.SampleID > 0
                || !string.IsNullOrEmpty(StateContainer.AnimalSampleDetail.EIDSSLocalOrFieldSampleID)) return;

            StateContainer.AnimalSamples ??= new List<SampleGetListViewModel>();

            if (StateContainer.AnimalSampleDetail.SelectedDiseases.Any())
            {
                FieldSampleIdDisabled = false;
                StateContainer.AnimalSampleDetail.EIDSSLocalOrFieldSampleID = "(" +
                                                                              Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                                                                              + " " +
                                                                              ((StateContainer.PendingSaveAnimalSamples?.Count(x => x.SampleID <= 0) ?? 0) + 1).ToString("0#") + ")";
            }
            else
            {
                FieldSampleIdDisabled = true;
            }
        }

        #endregion

        #region Animals

        protected void GetAnimals(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.AnimalSampleDetail.SampleID <= 0 && string.IsNullOrEmpty(StateContainer.AnimalSampleDetail.EIDSSAnimalID))
                {
                    if (StateContainer.ReportTypeID != ASSpeciesType.Avian)
                    {
                        Animals ??= new List<AnimalGetListViewModel>();
                        var tempAnimalId = new AnimalGetListViewModel()
                        {
                            AnimalID = (Animals.Count + 1) * -1,
                            EIDSSAnimalID = "(" +
                                            Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                                            + " " +
                                            ((StateContainer.PendingSaveAnimalSamples?.Count(x => x.SampleID <= 0 && !string.IsNullOrEmpty(x.EIDSSAnimalID)) ?? 0) + 1).ToString("0#") + ")"
                        };
                        
                        Animals.Add(tempAnimalId);
                        StateContainer.AnimalSampleDetail.AnimalID = tempAnimalId.AnimalID;
                        StateContainer.AnimalSampleDetail.EIDSSAnimalID = tempAnimalId.EIDSSAnimalID;
                    }
                }

                if (StateContainer.AnimalSamples is null || !StateContainer.AnimalSamples.Any()) return;
                Animals ??= new List<AnimalGetListViewModel>();

                foreach (var animal in StateContainer.AnimalSamples.Where(x => x.AnimalID is not null).ToList())
                {
                    if (Animals.All(x => x.AnimalID != animal.AnimalID))
                    {
                        Animals.Add(new AnimalGetListViewModel()
                        {
                            AnimalID = animal.AnimalID.GetValueOrDefault(),
                            EIDSSAnimalID = animal.EIDSSAnimalID,
                            SpeciesID = animal.SpeciesID,
                            SpeciesTypeID = animal.SpeciesTypeID
                        });
                    }
                }

                if (!IsNullOrEmpty(args.Filter))
                    Animals = Animals.Where(c => c.EIDSSAnimalID != null && c.EIDSSAnimalID.Contains(args.Filter)).ToList();
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
        protected async Task GetAnimalAges(LoadDataArgs args)
        {
            try
            {
                SpeciesAnimalAgeGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsSpeciesType = StateContainer.AnimalSampleDetail.SpeciesTypeID,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = "asc"
                };

                AnimalAges = await ConfigurationClient.GetSpeciesAnimalAgeList(request).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    AnimalAges = AnimalAges.Where(c => c.strAnimalType != null && c.strAnimalType.Contains(args.Filter)).ToList();
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
        protected async Task GetAnimalSexes(LoadDataArgs args)
        {
            try
            {
                AnimalSexes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AnimalSex, StateContainer.HACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    AnimalSexes = AnimalSexes.Where(c => c.Name != null && c.Name.Contains(args.Filter)).ToList();
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
        protected async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Laboratory
                };

                SentToOrganizations =
                    await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private void SetAnimalId()
        {
            //if (StateContainer.AnimalSampleDetail.SampleID > 0 &&
            //    StateContainer.ReportTypeID != ASSpeciesType.Livestock) return;

            AnimalControlsDisabled = !StateContainer.AnimalSampleDetail.SelectedDiseases.Any()
                                     || StateContainer.ReportTypeID == ASSpeciesType.Avian;
        }

        #endregion

        #region Filter By Disease Check Box Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnFilterByDiseaseChange(bool value)
        {
            try
            {
                SampleTypes = null;

                await GetSampleTypes(new LoadDataArgs());
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Add Collected By Person Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddSentToOrganizationClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object> { { "OrganizationID", StateContainer.AnimalSampleDetail.SentToOrganizationID } };

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
                    }).ConfigureAwait(false);

                if (result == null)
                    return;

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        public void OnSaveClick()
        {
            if (!Form.EditContext.Validate()) return;

            switch (StateContainer.AnimalSampleDetail.SampleID)
            {
                case 0:
                    StateContainer.AnimalSampleDetail.SampleID = (StateContainer.PendingSaveAnimalSamples != null
                        ? (StateContainer.PendingSaveAnimalSamples.Count(x => x.SampleID <= 0) + 1) * -1
                        : -1);
                    StateContainer.AnimalSampleDetail.MonitoringSessionID = StateContainer.SessionKey;
                    StateContainer.AnimalSampleDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    StateContainer.AnimalSampleDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                    StateContainer.AnimalSampleDetail.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    break;

                case > 0:
                    StateContainer.AnimalSampleDetail.RowAction = (int)RowActionTypeEnum.Update;
                    break;
            }

            if (StateContainer.Farms.Any(x => x.FarmMasterID == StateContainer.AnimalSampleDetail.FarmMasterID))
                StateContainer.AnimalSampleDetail.EIDSSFarmID = StateContainer.Farms.First(x => x.FarmMasterID == StateContainer.AnimalSampleDetail.FarmMasterID).EIDSSFarmID;

            if (SampleTypes.Any(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetail.SampleTypeID))
                StateContainer.AnimalSampleDetail.SampleTypeName = SampleTypes.First(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetail.SampleTypeID).Name;

            if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                if (Animals != null && Animals.Any(x => x.EIDSSAnimalID == StateContainer.AnimalSampleDetail.EIDSSAnimalID))
                    StateContainer.AnimalSampleDetail.AnimalName =
                        Animals.First(x => x.EIDSSAnimalID == StateContainer.AnimalSampleDetail.EIDSSAnimalID).AnimalName;

            if (SentToOrganizations.Any(x => x.idfOffice == StateContainer.AnimalSampleDetail.SentToOrganizationID))
                StateContainer.AnimalSampleDetail.SentToOrganizationName =
                    SentToOrganizations.First(x => x.idfOffice == StateContainer.AnimalSampleDetail.SentToOrganizationID).name;

            if (StateContainer.ReportTypeID == ASSpeciesType.Livestock)
            {
                if (StateContainer.AnimalSampleDetail.EIDSSAnimalID is null)
                {
                    StateContainer.AnimalSampleDetail.AnimalID = null;
                }
                else
                {
                    if (Animals != null && Animals.Any(x => x.EIDSSAnimalID == StateContainer.AnimalSampleDetail.EIDSSAnimalID))
                        StateContainer.AnimalSampleDetail.AnimalID = Animals.First(x => x.EIDSSAnimalID == StateContainer.AnimalSampleDetail.EIDSSAnimalID).AnimalID;
                }
            }

            if (StateContainer.AnimalSampleDetail.SpeciesID is null)
            {
                StateContainer.AnimalSampleDetail.Species = null;
                StateContainer.AnimalSampleDetail.SpeciesTypeID = null;
                StateContainer.AnimalSampleDetail.SpeciesTypeName = null;
            }
            else
            {
                var flockOrHerd = StateContainer.ReportTypeID == ASSpeciesType.Livestock ? Localizer.GetString(FieldLabelResourceKeyConstants.VeterinarySessionHerdSpeciesHerdFieldLabel) : Localizer.GetString(FieldLabelResourceKeyConstants.VeterinarySessionFlockSpeciesFlockFieldLabel);
                StateContainer.AnimalSampleDetail.Species = $"{flockOrHerd} {Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetail.SpeciesID)?.Species}";
                StateContainer.AnimalSampleDetail.SpeciesTypeID = Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetail.SpeciesID)?.SpeciesTypeID;
                StateContainer.AnimalSampleDetail.SpeciesTypeName = Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetail.SpeciesID)?.SpeciesTypeName;
            }

            if (string.IsNullOrEmpty(StateContainer.AnimalSampleDetail.EIDSSLocalOrFieldSampleID))
                SetFieldOrLocalSampleId();

            BuildSampleToDiseaseList();

            StateContainer.AnimalSampleDetail.DiseaseNames = GetDiseaseListString();

            DiagService.Close(Form.EditContext.Model);
        }

        private void BuildSampleToDiseaseList()
        {
            StateContainer.AnimalSampleToDiseases ??= new List<SampleToDiseaseGetListViewModel>();
            if (StateContainer.AnimalSampleDetail.SelectedDiseases is null) return;
            foreach (var diseaseId in StateContainer.AnimalSampleDetail.SelectedDiseases)
            {
                var sampleToDisease = StateContainer.AnimalSampleToDiseases.FirstOrDefault(x =>
                    x.SampleID == StateContainer.AnimalSampleDetail.SampleID
                    && x.DiseaseID == diseaseId);

                if (sampleToDisease is null)
                {
                    // new sample to disease record
                    sampleToDisease = new SampleToDiseaseGetListViewModel()
                    {
                        MonitoringSessionToMaterialID =
                            (StateContainer.AnimalSampleToDiseases.Count + 1) * -1,
                        MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                        SampleID = StateContainer.AnimalSampleDetail.SampleID,
                        SampleTypeID = StateContainer.AnimalSampleDetail.SampleTypeID,
                        DiseaseID = diseaseId,
                        DiseaseName = StateContainer.DiseaseSpeciesSamples.FirstOrDefault(x => x.DiseaseID == diseaseId)?.DiseaseName,
                        RowStatus = (int)RowStatusTypeEnum.Active,
                        RowAction = (int)RowActionTypeEnum.Insert
                    };

                    StateContainer.AnimalSampleToDiseases.Add(sampleToDisease);
                    TogglePendingSaveAnimalSampleToDiseases(sampleToDisease, null);
                }
                else
                {
                    // update existing record
                    var clonedRecord = sampleToDisease.ShallowCopy();
                    clonedRecord.SampleID = StateContainer.AnimalSampleDetail.SampleID;
                    clonedRecord.SampleTypeID = StateContainer.AnimalSampleDetail.SampleTypeID;
                    clonedRecord.DiseaseID = diseaseId;
                    clonedRecord.DiseaseName = sampleToDisease.DiseaseName;
                    clonedRecord.RowAction = (int)RowActionTypeEnum.Update;

                    var index = StateContainer.AnimalSampleToDiseases.IndexOf(sampleToDisease);
                    StateContainer.AnimalSampleToDiseases[index] = clonedRecord;
                    TogglePendingSaveAnimalSampleToDiseases(clonedRecord, sampleToDisease);
                }
            }

            // find all the diseases for this sample that were unselected
            // and mark them for soft delete
            var selectedItems = StateContainer.AnimalSampleDetail.SelectedDiseases.ToList();
            var unselectedItems = StateContainer.AnimalSampleToDiseases.Where(x => !selectedItems.Contains(x.DiseaseID)
                && x.SampleID == StateContainer.AnimalSampleDetail.SampleID
                && x.SampleTypeID == StateContainer.AnimalSampleDetail.SampleTypeID).ToList();
            foreach (var item in unselectedItems)
            {
                var record = item.ShallowCopy();
                record.RowAction = (int)RowActionTypeEnum.Update;
                record.RowStatus = (int)RowStatusTypeEnum.Inactive;

                StateContainer.AnimalSampleToDiseases.Remove(item);
                TogglePendingSaveAnimalSampleToDiseases(record, item);
            }
        }

        protected string GetDiseaseListString()
        {
            var diseaseString = Empty;
            var separator = Empty;

            //generate the list of diseases and positive quantity for this aggregate collection
            if (StateContainer.AnimalSampleDetail.SelectedDiseases is null) return diseaseString;

            if (StateContainer.AnimalSampleToDiseases is not { Count: > 0 }) return diseaseString;
            var diseaseList = StateContainer.AnimalSampleToDiseases
                .Where(x => x.SampleID == StateContainer.AnimalSampleDetail.SampleID).ToList();

            diseaseString = string.Join("; ", diseaseList.Select(x => x.DiseaseName)).TrimEnd(';');

            return diseaseString;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAnimalSampleToDiseases(SampleToDiseaseGetListViewModel record, SampleToDiseaseGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveAnimalSampleToDiseases ??= new List<SampleToDiseaseGetListViewModel>();

            if (StateContainer.PendingSaveAnimalSampleToDiseases.Any(x => x.MonitoringSessionToMaterialID == record.MonitoringSessionToMaterialID
                                                                          && x.SampleID == record.SampleID
                                                                          && x.DiseaseID == record.DiseaseID) && originalRecord is not null)
            {
                var index = StateContainer.PendingSaveAnimalSampleToDiseases.IndexOf(originalRecord);
                StateContainer.PendingSaveAnimalSampleToDiseases[index] = record;
            }
            else
            {
                StateContainer.PendingSaveAnimalSampleToDiseases.Add(record);
            }
        }

        #endregion

        #region Cancel Button Click Event

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
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                            .ConfigureAwait(false);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
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