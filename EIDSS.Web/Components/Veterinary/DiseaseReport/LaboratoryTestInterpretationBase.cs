#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class LaboratoryTestInterpretationBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<LaboratoryTestInterpretationBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public LaboratoryTestInterpretationGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<LaboratoryTestInterpretationGetListViewModel> Form { get; set; }

        public IEnumerable<BaseReferenceViewModel> InterpretedStatusTypes { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string AnimalIdFieldLabelResourceKey { get; set; }
        public string DiseaseFieldLabelResourceKey { get; set; }
        public string TestNameFieldLabelResourceKey { get; set; }
        public string TestCategoryFieldLabelResourceKey { get; set; }
        public string LabSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string FieldSampleIdFieldLabelResourceKey { get; set; }
        public string RuleOutRuleInFieldLabelResourceKey { get; set; }
        public string RuleOutRuleInCommentsFieldLabelResourceKey { get; set; }
        public string DateInterpretedFieldLabelResourceKey { get; set; }
        public string InterpretedByFieldLabelResourceKey { get; set; }
        public string ValidatedFieldLabelResourceKey { get; set; }
        public string ValidatedCommentsFieldLabelResourceKey { get; set; }
        public string DateValidatedFieldLabelResourceKey { get; set; }
        public string ValidatedByFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public LaboratoryTestInterpretationBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected LaboratoryTestInterpretationBase() : base(CancellationToken.None)
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

            _userPermissions = GetUserPermissions(PagePermission.CanInterpretVetDiseaseReportSessionTestResult);
            Model.CanInterpretTestResultPermissionIndicator = _userPermissions.Execute;
            _userPermissions =
                GetUserPermissions(PagePermission.CanValidateTestVetResultInterpretation);
            Model.CanValidateTestResultPermissionIndicator = _userPermissions.Execute;

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalSpeciesFieldLabel;
                DiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalDiseaseFieldLabel;
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalTestNameFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalTestCategoryFieldLabel;
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalSampleTypeFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalFieldSampleIDFieldLabel;
                RuleOutRuleInFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalRuleOutRuleInFieldLabel;
                RuleOutRuleInCommentsFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalCommentsRuleOutRuleInFieldLabel;
                DateInterpretedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalDateInterpretedFieldLabel;
                InterpretedByFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalInterpretedByFieldLabel;
                ValidatedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalValidatedFieldLabel;
                ValidatedCommentsFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalCommentsValidatedFieldLabel;
                DateValidatedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalDateValidatedFieldLabel;
                ValidatedByFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalValidatedByFieldLabel;
            }
            else
            {
                AnimalIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalAnimalIDFieldLabel;
                DiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalDiseaseFieldLabel;
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalTestNameFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalTestCategoryFieldLabel;
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalSampleTypeFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalFieldSampleIDFieldLabel;
                RuleOutRuleInFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalRuleOutRuleInFieldLabel;
                RuleOutRuleInCommentsFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalCommentsRuleOutRuleInFieldLabel;
                DateInterpretedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalDateInterpretedFieldLabel;
                InterpretedByFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalInterpretedByFieldLabel;
                ValidatedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalValidatedFieldLabel;
                ValidatedCommentsFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalCommentsValidatedFieldLabel;
                DateValidatedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalDateValidatedFieldLabel;
                ValidatedByFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalValidatedByFieldLabel;
            }

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

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~OutbreakInvestigationSectionBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await GetInterpretedStatusTypes();

                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetInterpretedStatusTypes()
        {
            try
            {
                if (InterpretedStatusTypes == null)
                {
                    if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                        InterpretedStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.RuleInRuleOut, HACodeList.AvianHACode);
                    else
                        InterpretedStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.RuleInRuleOut, HACodeList.LivestockHACode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Interpreted Status Radio Button List Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnInterpretedStatusTypeChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.InterpretedByOrganizationID = null;
                    Model.InterpretedByPersonID = null;
                    Model.InterpretedByPersonName = null;
                    Model.InterpretedComment = null;
                    Model.InterpretedDate = null;
                }
                else
                {
                    Model.InterpretedByOrganizationID = authenticatedUser.OfficeId;
                    Model.InterpretedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    Model.InterpretedByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName +
                                                    " " + authenticatedUser.SecondName;
                    Model.InterpretedDate = DateTime.Now;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validated Check Box Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnValidatedChange(bool? value)
        {
            try
            {
                if (value == null)
                {
                    Model.ValidatedByOrganizationID = null;
                    Model.ValidatedByPersonID = null;
                    Model.ValidatedByPersonName = null;
                    Model.ValidatedComment = null;
                    Model.ValidatedDate = null;
                }
                else
                {
                    Model.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                    Model.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    Model.ValidatedByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName +
                                                  " " + authenticatedUser.SecondName;
                    Model.ValidatedDate = DateTime.Now;
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
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.TestInterpretationID)
            {
                case 0:
                    Model.TestInterpretationID = (DiseaseReport.LaboratoryTestInterpretations.Count + 1) * -1;
                    var isTestResultIndicative = DiseaseReport.LaboratoryTests
                        .First(x => x.TestID == Model.TestID).IsTestResultIndicative;
                    if (isTestResultIndicative !=
                        null)
                        Model.IndicativeIndicator = (bool) isTestResultIndicative;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            if (Model.InterpretedStatusTypeID is not null)
                Model.InterpretedStatusTypeName = InterpretedStatusTypes
                    .First(x => x.IdfsBaseReference == Model.InterpretedStatusTypeID).Name;

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
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

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