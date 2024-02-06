#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
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
using static System.Int32;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class SampleBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SampleBase> Logger { get; set; }
        [Inject] private IConfigurationClient ConfigurationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public SampleGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<SampleGetListViewModel> Form { get; set; }

        public IList<BaseReferenceViewModel> SampleTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> BirdStatusTypes { get; set; }
        public IEnumerable<OrganizationAdvancedGetListViewModel> CollectedByOrganizations { get; set; }
        public IEnumerable<EmployeeLookupGetListViewModel> CollectedByPersons { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> SentToOrganizations { get; set; }

        public bool FilterSamplesByDiseaseIndicator { get; set; }

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

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public SampleBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected SampleBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            DiseaseReport.Samples ??= new List<SampleGetListViewModel>();

            if (Model.SampleID <= 0)
                Model.EIDSSLocalOrFieldSampleID = "(" +
                                                  Localizer.GetString(FieldLabelResourceKeyConstants
                                                      .CommonLabelsNewFieldLabel) + " " +
                                                  (DiseaseReport.Samples.Count + 1) + ")";

            FilterSamplesByDiseaseFieldLabelResourceKey =
                Localizer.GetString(FieldLabelResourceKeyConstants.FilterSamplesByDiseaseLabel);

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
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
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSampleDetailsModalSpeciesFieldLabel;
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

            await GetCollectedByOrganizations(new LoadDataArgs()).ConfigureAwait(false);

            if (Model.CollectedByPersonID is not null)
                await GetCollectedByPersons(new LoadDataArgs()).ConfigureAwait(false);

            await GetSentToOrganizations(new LoadDataArgs()).ConfigureAwait(false);

            if (Model.SentToOrganizationID is not null)
                if (SentToOrganizations.All(x => x.idfOffice != (long) Model.SentToOrganizationID))
                {
                    OrganizationAdvancedGetListViewModel model = new()
                    {
                        idfOffice = (long) Model.SentToOrganizationID,
                        name = Model.SentToOrganizationName
                    };

                    SentToOrganizations.Add(model);
                }

            await base.OnInitializedAsync().ConfigureAwait(false);
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
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetSampleTypes(LoadDataArgs args)
        {
            try
            {
                if (FilterSamplesByDiseaseIndicator && DiseaseReport.DiseaseID is not null)
                {
                    DiseaseSampleTypeByDiseaseRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsDiagnosis = (long) DiseaseReport.DiseaseID,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "strSampleType",
                        SortOrder = SortConstants.Ascending
                    };
                    var diseaseSampleTypeMatrix = await ConfigurationClient.GetDiseaseSampleTypeByDiseasePaged(request);
                    BaseReferenceViewModel model = null;
                    SampleTypes = new List<BaseReferenceViewModel>();
                    foreach (var matrix in diseaseSampleTypeMatrix)
                    {
                        if (matrix.idfsSampleType != null)
                            model = new BaseReferenceViewModel
                            {
                                Name = matrix.strSampleType,
                                IdfsBaseReference = (long) matrix.idfsSampleType
                            };

                        SampleTypes?.Add(model);
                    }
                }
                else
                {
                    if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                        SampleTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.SampleType, HACodeList.AvianHACode).ConfigureAwait(false);
                    else
                        SampleTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.SampleType, HACodeList.LivestockHACode).ConfigureAwait(false);
                }

                if (!IsNullOrEmpty(args.Filter))
                {
                    SampleTypes = SampleTypes?.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter,
                                StringComparison.CurrentCultureIgnoreCase))
                        .ToList();
                }

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
        /// <returns></returns>
        public async Task GetBirdStatusTypes(LoadDataArgs args)
        {
            try
            {
                BirdStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AnimalBirdStatus, HACodeList.AvianHACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    BirdStatusTypes = BirdStatusTypes.Where(c =>
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
        /// <returns></returns>
        public async Task GetCollectedByOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian ? (int) AccessoryCodeEnum.Avian : (int) AccessoryCodeEnum.Livestock,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                CollectedByOrganizations = list.AsODataEnumerable();

                CollectedByOrganizations = CollectedByOrganizations.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();
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
        public async Task GetCollectedByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = Model.CollectedByOrganizationID,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                CollectedByPersons = await CrossCuttingClient.GetEmployeeLookupList(request);

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
        public async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian ? (int) AccessoryCodeEnum.Avian : (int) AccessoryCodeEnum.Livestock,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                SentToOrganizations =
                    await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                SentToOrganizations = SentToOrganizations.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Filter By Disease Check Box Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnFilterByDiseaseChange()
        {
            try
            {
                SampleTypes = null;

                await GetSampleTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Collected By Organization Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCollectedByOrganizationChange()
        {
            try
            {
                await GetCollectedByPersons(new LoadDataArgs()).ConfigureAwait(false);
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
        protected async Task OnAddCollectedByPersonClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object> {{"OrganizationID", Model.CollectedByOrganizationID}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
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

        #region Animal Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnAnimalChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.Species = null;
                    Model.SpeciesID = null;
                    Model.SpeciesTypeID = null;
                    Model.SpeciesTypeName = null;
                }
                else
                {
                    Model.Species = DiseaseReport.Animals.First(x => x.AnimalID == (long) value).Species;
                    Model.SpeciesID = DiseaseReport.Animals.First(x => x.AnimalID == (long) value).SpeciesID;
                    Model.SpeciesTypeID = DiseaseReport.Animals.First(x => x.AnimalID == (long) value).SpeciesTypeID;
                    Model.SpeciesTypeName =
                        DiseaseReport.Animals.First(x => x.AnimalID == (long) value).SpeciesTypeName;
                }
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
            switch (Model.SampleID)
            {
                case 0:
                    if (DiseaseReport.Samples != null) Model.SampleID = (DiseaseReport.Samples.Count + 1) * -1;
                    Model.VeterinaryDiseaseReportID = DiseaseReport.DiseaseReportID;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    Model.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            if (SampleTypes.Any(x => x.IdfsBaseReference == Model.SampleTypeID))
                Model.SampleTypeName = SampleTypes.First(x => x.IdfsBaseReference == Model.SampleTypeID).Name;

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                if (BirdStatusTypes.Any(x => x.IdfsBaseReference == Model.BirdStatusTypeID))
                    Model.BirdStatusTypeName =
                        BirdStatusTypes.First(x => x.IdfsBaseReference == Model.BirdStatusTypeID).Name;

            if (SentToOrganizations is not null && SentToOrganizations.Any(x => x.idfOffice == Model.SentToOrganizationID))
            {
                // Set the site ID to the sent to organization selected, assuming it has one; otherwise use the logged in user's site ID.
                Model.SiteID =
                    SentToOrganizations.First(x => x.idfOffice == Model.SentToOrganizationID).idfsSite == null
                        ? Model.SiteID
                        : Convert.ToInt64(SentToOrganizations.First(x => x.idfOffice == Model.SentToOrganizationID)
                            .idfsSite);
                Model.SentToOrganizationName =
                    SentToOrganizations.First(x => x.idfOffice == Model.SentToOrganizationID).name;
            }

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Livestock)
            {
                if (Model.AnimalID is null)
                {
                    Model.EIDSSAnimalID = null;
                    Model.SpeciesID = null;
                }
                else
                {
                    Model.EIDSSAnimalID = DiseaseReport.Animals.First(x => x.AnimalID == Model.AnimalID).EIDSSAnimalID;
                    Model.SpeciesID = DiseaseReport.Animals.First(x => x.AnimalID == Model.AnimalID).SpeciesID;
                }
            }

            if (Model.SpeciesID is null)
            {
                Model.Species = null;
                Model.SpeciesTypeID = null;
                Model.SpeciesTypeName = null;
            }
            else
            {
                Model.Species = DiseaseReport.Species.First(x => x.SpeciesID == Model.SpeciesID).Species;
                Model.SpeciesTypeID = DiseaseReport.Species.First(x => x.SpeciesID == Model.SpeciesID).SpeciesTypeID;
                Model.SpeciesTypeName =
                    DiseaseReport.Species.First(x => x.SpeciesID == Model.SpeciesID).SpeciesTypeName;
            }

            if (Model.CollectedByOrganizationID is null)
                Model.CollectedByOrganizationName = null;
            else if (CollectedByOrganizations.Any(x => x.idfOffice == Model.CollectedByOrganizationID))
                Model.CollectedByOrganizationName = CollectedByOrganizations
                    .First(x => x.idfOffice == Model.CollectedByOrganizationID).name;

            if (Model.CollectedByPersonID is null)
                Model.CollectedByPersonName = null;
            else if (CollectedByPersons.Any(x => x.idfPerson == Model.CollectedByPersonID))
                Model.CollectedByPersonName =
                    CollectedByPersons.First(x => x.idfPerson == Model.CollectedByPersonID).FullName;

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