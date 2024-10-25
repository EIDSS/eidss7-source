#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
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
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class VaccinationBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<VaccinationBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public VaccinationGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<VaccinationGetListViewModel> Form { get; set; }

        public IEnumerable<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public IEnumerable<FarmInventoryGetListViewModel> Species { get; set; }
        public IEnumerable<BaseReferenceViewModel> VaccinationTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> VaccinationRouteTypes { get; set; }

        public string DiseaseFieldLabelResourceKey { get; set; }
        public string VaccinationDateFieldLabelResourceKey { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string NumberVaccinatedFieldLabelResourceKey { get; set; }
        public string TypeFieldLabelResourceKey { get; set; }
        public string RouteFieldLabelResourceKey { get; set; }
        public string LotNumberFieldLabelResourceKey { get; set; }
        public string ManufacturerFieldLabelResourceKey { get; set; }
        public string CommentsFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public VaccinationBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected VaccinationBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (DiseaseReport.ReportTypeID == (long) CaseTypeEnum.Avian)
            {
                DiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalDiseaseFieldLabel;
                VaccinationDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalDateFieldLabel;
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalSpeciesFieldLabel;
                NumberVaccinatedFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalVaccinatedNumberFieldLabel;
                TypeFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalTypeFieldLabel;
                RouteFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalRouteFieldLabel;
                LotNumberFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalLotNumberFieldLabel;
                ManufacturerFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalManufacturerFieldLabel;
                CommentsFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalCommentsFieldLabel;
            }
            else
            {
                DiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalDiseaseFieldLabel;
                VaccinationDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalDateFieldLabel;
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalSpeciesFieldLabel;
                NumberVaccinatedFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalVaccinatedNumberFieldLabel;
                TypeFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalTypeFieldLabel;
                RouteFieldLabelResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalRouteFieldLabel;
                LotNumberFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalLotNumberFieldLabel;
                ManufacturerFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalManufacturerFieldLabel;
                CommentsFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.VaccinationDetailsModalCommentsFieldLabel;
            }

            Species = DiseaseReport.FarmInventory.Where(x =>
                x.RecordType == RecordTypeConstants.Species && x.RowStatus == (int) RowStatusTypeEnum.Active);

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
        public async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                        ? HACodeList.AvianHACode
                        : HACodeList.LivestockHACode,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    UsingType = (long) DiseaseUsingTypes.Standard,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    Diseases = Diseases.Where(c =>
                        c.DiseaseName != null &&
                        c.DiseaseName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

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
        public async Task GetSpecies(LoadDataArgs args)
        {
            Species = DiseaseReport.FarmInventory.Where(x =>
                x.RecordType == RecordTypeConstants.Species && x.RowStatus == (int) RowStatusTypeEnum.Active);

            if (!IsNullOrEmpty(args.Filter))
                Species =
                    DiseaseReport.FarmInventory.Where(c =>
                        c.Species is not null &&
                        c.Species.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetVaccinationTypes(LoadDataArgs args)
        {
            try
            {
                if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    VaccinationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.VaccinationType, HACodeList.AvianHACode).ConfigureAwait(false);
                else
                    VaccinationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.VaccinationType, HACodeList.LivestockHACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    VaccinationTypes = VaccinationTypes.Where(c =>
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
        /// <returns></returns>
        public async Task GetVaccinationRouteTypes(LoadDataArgs args)
        {
            try
            {
                if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    VaccinationRouteTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.VaccinationRouteList, HACodeList.AvianHACode).ConfigureAwait(false);
                else
                    VaccinationRouteTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.VaccinationRouteList, HACodeList.LivestockHACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    VaccinationRouteTypes =
                        VaccinationRouteTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Disease Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnDiseaseChange(object value)
        {
            try
            {
                if (value == null)
                    Model.DiseaseID = null;
                else
                    Model.VaccinationDate = DateTime.Today;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Vaccination Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddVaccinationTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long) BaseReferenceTypeEnum.Vaccination},
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.VeterinaryDiseaseReportVaccinationsTypeFieldLabel
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    });

                if (result is BaseReferenceSaveRequestResponseModel)
                    await GetVaccinationTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Add Route Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddRouteTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long) BaseReferenceTypeEnum.VaccinationRoute},
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.VeterinaryDiseaseReportVaccinationsRouteFieldLabel
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    });

                if (result is BaseReferenceSaveRequestResponseModel)
                    await GetVaccinationRouteTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.VaccinationID)
            {
                case 0:
                    Model.VaccinationID = (DiseaseReport.Vaccinations.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.DiseaseName = Model.DiseaseID is null
                ? null
                : Diseases.First(x => x.DiseaseID == Model.DiseaseID).DiseaseName;

            Model.RouteTypeName = Model.RouteTypeID is null
                ? null
                : VaccinationRouteTypes.First(x => x.IdfsBaseReference == Model.RouteTypeID).Name;

            Model.SpeciesTypeName = Model.SpeciesID is null
                ? null
                : DiseaseReport.FarmInventory.First(x => x.SpeciesID == Model.SpeciesID).SpeciesTypeName;
            Model.Species = Model.SpeciesID is null
                ? null
                : DiseaseReport.FarmInventory.First(x => x.SpeciesID == Model.SpeciesID).Species;

            Model.VaccinationTypeName = Model.VaccinationTypeID is null
                ? null
                : VaccinationTypes.First(x => x.IdfsBaseReference == Model.VaccinationTypeID).Name;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                            .ConfigureAwait(false);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton)) DiagService.Close(result);
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