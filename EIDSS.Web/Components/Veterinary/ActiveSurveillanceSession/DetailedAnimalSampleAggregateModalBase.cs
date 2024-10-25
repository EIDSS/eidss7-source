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
using EIDSS.Web.Components.CrossCutting;
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
using EIDSS.Domain.RequestModels.Veterinary;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DetailedAnimalSampleAggregateModalBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DetailedAnimalSampleAggregateModalBase> Logger { get; set; }
        [Inject] private IConfigurationClient ConfigurationClient { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<VeterinaryActiveSurveillanceSessionAggregateViewModel> Form { get; set; }
        protected RadzenNumeric<int?> PositiveAnimalsQty { get; set; }
        public IList<FarmViewModel> Farms { get; set; }
        public IList<FarmInventoryGetListViewModel> Species { get; set; }
        public IList<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public IList<BaseReferenceViewModel> SampleTypes { get; set; }
        public IList<AnimalGetListViewModel> Animals { get; set; }
        public IList<ConfigurationMatrixViewModel> AnimalAges { get; set; }
        public IList<BaseReferenceViewModel> AnimalSexes { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> SentToOrganizations { get; set; }
        public bool AggregateDiseaseIsDisabled { get; set; }
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

        #endregion

        #region Member Variables

        protected bool SpeciesIsDisabled;
        protected bool SampleTypeIsDisabled;
        protected bool DiseaseIsDisabled;
        protected bool AnimalIdIsDisabled;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        private int _previousPositiveAnimalQty;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.AnimalSampleDetailAggregate ??= new VeterinaryActiveSurveillanceSessionAggregateViewModel();

            if (StateContainer.AnimalSampleDetailAggregate.MonitoringSessionSummaryID <= 0)
            {
                StateContainer.AnimalSampleDetailAggregate.EIDSSLocalOrFieldSampleID = "(" +
                    Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                    + " " + (StateContainer.AnimalSamples.Count + 1) + ")";
            }

            if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                AnimalIdIsDisabled = true;

            if (StateContainer.AnimalSampleDetailAggregate.FarmMasterID == null)
            {
                SpeciesIsDisabled = true;
            }

            if (StateContainer.AnimalSampleDetailAggregate.SpeciesID == null)
            {
                SampleTypeIsDisabled = true;
            }

            if (StateContainer.AnimalSampleDetailAggregate.SampleTypeID == null)
            {
                DiseaseIsDisabled = true;
            }

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

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Farms

        public void GetFarms(LoadDataArgs args)
        {
            try
            {
                Farms ??= new List<FarmViewModel>();

                // get the farms list from the session farms list
                if (StateContainer.FarmsAggregate != null && StateContainer.FarmsAggregate.Any())
                {
                    Farms = StateContainer.FarmsAggregate;
                }

                // filter by filter criteria
                if (!IsNullOrEmpty(args.Filter))
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
                StateContainer.AnimalSampleDetailAggregate.SpeciesID = null;
                StateContainer.AnimalSampleDetailAggregate.Species = null;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID = null;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeName = null;
                SpeciesIsDisabled = true;
            }
            else
            {
                StateContainer.AnimalSampleDetailAggregate.FarmMasterID = (long)value;
                if (StateContainer.FarmsAggregate != null && StateContainer.FarmsAggregate.Any(x => x.FarmMasterID == (long)value))
                {
                    StateContainer.AnimalSampleDetailAggregate.FarmID =
                        StateContainer.FarmsAggregate.First(x => x.FarmMasterID == (long)value).FarmID.GetValueOrDefault();
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
                if (StateContainer.AnimalSampleDetailAggregate.FarmMasterID != null)
                {
                    // see if the species already exist in the current farm inventory
                    var species = StateContainer.FarmInventoryAggregate?.Where(x =>
                        x.FarmMasterID == StateContainer.AnimalSampleDetailAggregate.FarmMasterID
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
                            FarmMasterID = StateContainer.AnimalSampleDetailAggregate.FarmMasterID,
                            MonitoringSessionID = null,
                            FarmID = StateContainer.FarmsAggregate.FirstOrDefault(x =>
                                x.FarmMasterID == StateContainer.AnimalSampleDetailAggregate.FarmMasterID &&
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
                                x.FarmMasterID == StateContainer.AnimalSampleDetailAggregate.FarmMasterID
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
                StateContainer.AnimalSampleDetailAggregate.SampleTypeID = 0;
                SampleTypeIsDisabled = true;
            }
            else
            {
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID = Species.FirstOrDefault(x => x.SpeciesID == (long)value)?.SpeciesTypeID;
                SampleTypeIsDisabled = false;
            }

            await GetSampleTypes(new LoadDataArgs());
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
                            f.SpeciesTypeID == StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID)
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
                StateContainer.AnimalSampleDetailAggregate.SelectedDiseases = null;
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

                // get the diseases list from the Disease Species Sample Grid
                if (StateContainer.DiseaseSpeciesSamples is { Count: > 0 })
                {
                    Diseases.Clear();
                    if (StateContainer.AnimalSampleDetailAggregate.SelectedDiseases != null &&
                        (!StateContainer.DiseaseSpeciesSamples.Any(x => x.SampleTypeID == StateContainer.AnimalSampleDetailAggregate.SampleTypeID
                        && x.DiseaseID == StateContainer.AnimalSampleDetailAggregate.SelectedDiseases.FirstOrDefault())))
                    {
                        StateContainer.AnimalSampleDetailAggregate.SelectedDiseases = new List<long>();
                    }
                    foreach (var disease in StateContainer.DiseaseSpeciesSamples
                        .Where(x => StateContainer.AnimalSampleDetailAggregate.SampleTypeID == 0 || x.SampleTypeID == StateContainer.AnimalSampleDetailAggregate.SampleTypeID))
                    {
                        if (Diseases.All(x => x.DiseaseID != disease.DiseaseID))
                        {
                            Diseases.Add(new FilteredDiseaseGetListViewModel()
                            {
                                DiseaseID = disease.DiseaseID.GetValueOrDefault(),
                                DiseaseName = disease.DiseaseName
                            });
                        }
                    }
                }

                // filter by filter criteria
                if (!IsNullOrEmpty(args.Filter))
                {
                    Diseases = Diseases.Where(d => d.DiseaseName != null && d.DiseaseName.Contains(args.Filter)).ToList();
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
                StateContainer.AnimalSampleDetailAggregate.AnimalID = null;
                StateContainer.AnimalSampleDetailAggregate.AnimalName = null;
                StateContainer.AnimalSampleDetailAggregate.EIDSSAnimalID = null;
                AnimalIdIsDisabled = true;
            }
            else
            {
                AnimalIdIsDisabled = false;
                GetAnimals(new LoadDataArgs());
            }
        }

        protected async Task OnPositiveAnimalsQtyChange(int? value)
        {
            try
            {
                if (StateContainer.AnimalSampleDetailAggregate.SampledAnimalsQuantity != null
                    && StateContainer.AnimalSampleDetailAggregate.PositiveAnimalsQuantity.GetValueOrDefault() > StateContainer.AnimalSampleDetailAggregate.SampledAnimalsQuantity.GetValueOrDefault())
                {
                    List<DialogButton> buttons = new();
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

                    Dictionary<string, object> dialogParams = new()
                    {
                        { nameof(EIDSSDialog.DialogButtons), buttons },
                        {
                            nameof(EIDSSDialog.Message),
                            new LocalizedString("Message", Format(Localizer.GetString(MessageResourceKeyConstants.VeterinarySessionAggregatePositiveSampleQtyMoreThanAnimalsSampledMessage),
                                StateContainer.AnimalSampleDetailAggregate.PositiveAnimalsQuantity.ToString(),
                                StateContainer.AnimalSampleDetailAggregate.SampledAnimalsQuantity.ToString()))
                        }
                    };

                    var result =
                        await DiagService.OpenAsync<EIDSSDialog>(String.Empty, dialogParams);

                    if (result == null)
                        return;

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            _source?.Cancel();

                            await PositiveAnimalsQty.FocusAsync();
                        }
                        else
                        {
                            StateContainer.AnimalSampleDetailAggregate.PositiveAnimalsQuantity = _previousPositiveAnimalQty;
                            await PositiveAnimalsQty.FocusAsync();
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

        #region Animals

        protected void GetAnimals(LoadDataArgs args)
        {
            try
            {
                if (Animals is null)
                {
                    if (StateContainer.AnimalSampleDetailAggregate.MonitoringSessionSummaryID <= 0)
                    {
                        if (StateContainer.ReportTypeID != ASSpeciesType.Avian)
                        {
                            var tempAnimalId = new AnimalGetListViewModel()
                            {
                                AnimalID = StateContainer.AnimalSamples.Count() + 1 * -1,
                                EIDSSAnimalID = "(" + Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel) + " " + (StateContainer.AnimalSamples.Count + 1) + ")"
                            };
                            if (Animals is null)
                            {
                                Animals = new List<AnimalGetListViewModel>();
                                Animals.Add(tempAnimalId);
                            }
                            StateContainer.AnimalSampleDetailAggregate.AnimalID = tempAnimalId.AnimalID;
                            StateContainer.AnimalSampleDetailAggregate.EIDSSAnimalID = tempAnimalId.EIDSSAnimalID;
                        }
                    }

                    if (StateContainer.AnimalSamples is not null && StateContainer.AnimalSamples.Any())
                    {
                        if (Animals is null)
                            Animals = new List<AnimalGetListViewModel>();

                        foreach (var animal in StateContainer.AnimalSamples)
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
                }
                else
                {
                    if (!IsNullOrEmpty(args.Filter))
                        Animals = Animals.Where(c => c.AnimalName != null && c.AnimalName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetAnimalAges(LoadDataArgs args)
        {
            try
            {
                SpeciesAnimalAgeGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsSpeciesType = StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID,
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

        protected async Task GetAnimalSexes(LoadDataArgs args)
        {
            try
            {
                AnimalSexes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AnimalSex, StateContainer.HACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    AnimalSexes = AnimalSexes.Where(c => c.Name != null && c.Name.Contains(args.Filter)).ToList();

                //await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Organizations

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

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnSaveClick()
        {
            if (!Form.EditContext.Validate()) return;
            switch (StateContainer.AnimalSampleDetailAggregate.MonitoringSessionSummaryID)
            {
                case 0:
                    if (StateContainer.AnimalSamplesAggregate != null) StateContainer.AnimalSampleDetailAggregate.MonitoringSessionSummaryID = (StateContainer.AnimalSamplesAggregate.Count + 1) * -1;
                    StateContainer.AnimalSampleDetailAggregate.MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault();
                    StateContainer.AnimalSampleDetailAggregate.RowAction = (int)RowActionTypeEnum.Insert;
                    StateContainer.AnimalSampleDetailAggregate.RowStatus = (int)RowStatusTypeEnum.Active;
                    StateContainer.AnimalSampleDetailAggregate.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    break;

                case > 0:
                    StateContainer.AnimalSampleDetailAggregate.RowAction = (int)RowActionTypeEnum.Update;
                    break;
            }

            if (StateContainer.FarmsAggregate.Any(x => x.FarmMasterID == StateContainer.AnimalSampleDetailAggregate.FarmMasterID))
                StateContainer.AnimalSampleDetailAggregate.EIDSSFarmID = StateContainer.FarmsAggregate.First(x => x.FarmMasterID == StateContainer.AnimalSampleDetailAggregate.FarmMasterID).EIDSSFarmID;

            if (SampleTypes.Any(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetailAggregate.SampleTypeID))
                StateContainer.AnimalSampleDetailAggregate.SampleTypeName = SampleTypes.First(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetailAggregate.SampleTypeID).Name;

            if (AnimalSexes.Any(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetailAggregate.AnimalGenderTypeID))
                StateContainer.AnimalSampleDetailAggregate.AnimalGenderTypeName = AnimalSexes.First(x => x.IdfsBaseReference == StateContainer.AnimalSampleDetailAggregate.AnimalGenderTypeID).Name;

            if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                if (Animals != null && Animals.Any(x => x.AnimalID == StateContainer.AnimalSampleDetailAggregate.AnimalID))
                    StateContainer.AnimalSampleDetailAggregate.AnimalName =
                        Animals.First(x => x.AnimalID == StateContainer.AnimalSampleDetailAggregate.AnimalID).AnimalName;

            if (SentToOrganizations.Any(x => x.idfOffice == StateContainer.AnimalSampleDetailAggregate.SentToOrganizationID))
                StateContainer.AnimalSampleDetailAggregate.SentToOrganizationName =
                    SentToOrganizations.First(x => x.idfOffice == StateContainer.AnimalSampleDetailAggregate.SentToOrganizationID).name;

            if (StateContainer.ReportTypeID == ASSpeciesType.Livestock)
            {
                if (StateContainer.AnimalSampleDetailAggregate.AnimalID is null)
                {
                    StateContainer.AnimalSampleDetailAggregate.EIDSSAnimalID = null;
                }
                else
                {
                    if (Animals != null)
                        StateContainer.AnimalSampleDetailAggregate.EIDSSAnimalID = Animals
                            .First(x => x.AnimalID == StateContainer.AnimalSampleDetailAggregate.AnimalID)
                            .EIDSSAnimalID;
                }
            }

            if (StateContainer.AnimalSampleDetailAggregate.SpeciesID is null)
            {
                StateContainer.AnimalSampleDetailAggregate.Species = null;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID = null;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeName = null;
            }
            else
            {
                StateContainer.AnimalSampleDetailAggregate.Species = Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetailAggregate.SpeciesID)?.Species;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeID = Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetailAggregate.SpeciesID)?.SpeciesTypeID;
                StateContainer.AnimalSampleDetailAggregate.SpeciesTypeName = Species.FirstOrDefault(x => x.SpeciesID == StateContainer.AnimalSampleDetailAggregate.SpeciesID)?.SpeciesTypeName;
            }

            if (StateContainer.AnimalSampleDetailAggregate.SelectedDiseases is not null && StateContainer.AnimalSampleDetailAggregate.SelectedDiseases.Any())
            {
                StateContainer.AnimalSampleDetailAggregate.DiseaseName = Empty;
                foreach (var diseaseId in StateContainer.AnimalSampleDetailAggregate.SelectedDiseases)
                {
                    var diseaseName = Diseases.First(x => x.DiseaseID == diseaseId).DiseaseName;
                    var separator = !IsNullOrEmpty(StateContainer.AnimalSampleDetailAggregate.DiseaseName) ? ", " : Empty;
                    StateContainer.AnimalSampleDetailAggregate.DiseaseName += $"{separator}{diseaseName}";
                }
            }

            DiagService.Close(Form.EditContext.Model);
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