#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    /// <summary>
    ///
    /// </summary>
    public class TestInterpretationModalBase : SurveillanceSessionBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<TestInterpretationModalBase> Logger { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<LaboratoryTestInterpretationGetListViewModel> Form { get; set; }

        protected IEnumerable<BaseReferenceViewModel> InterpretedStatusTypes { get; set; }

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        ///
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            await GetInterpretedStatusTypes();

            await base.OnInitializedAsync();
        }

        #endregion

        #region Load Data Methods

        protected async Task GetInterpretedStatusTypes()
        {
            try
            {
                if (InterpretedStatusTypes == null)
                {
                    if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                        InterpretedStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.RuleInRuleOut, HACodeList.AvianHACode);
                    else
                        InterpretedStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.RuleInRuleOut, HACodeList.LivestockHACode);
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
        ///
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnInterpretedStatusTypeChange(object value)
        {
            try
            {
                if (value == null)
                {
                    StateContainer.InterpretationDetail.InterpretedByOrganizationID = null;
                    StateContainer.InterpretationDetail.InterpretedByPersonID = null;
                    StateContainer.InterpretationDetail.InterpretedByPersonName = null;
                    StateContainer.InterpretationDetail.InterpretedComment = null;
                    StateContainer.InterpretationDetail.InterpretedDate = null;
                }
                else
                {
                    StateContainer.InterpretationDetail.InterpretedByOrganizationID = authenticatedUser.OfficeId;
                    StateContainer.InterpretationDetail.InterpretedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    StateContainer.InterpretationDetail.InterpretedByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName;
                    StateContainer.InterpretationDetail.InterpretedDate = DateTime.Now;
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
        ///
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnValidatedChange(bool? value)
        {
            try
            {
                if (value is null or false)
                {
                    StateContainer.InterpretationDetail.ValidatedByOrganizationID = null;
                    StateContainer.InterpretationDetail.ValidatedByPersonID = null;
                    StateContainer.InterpretationDetail.ValidatedByPersonName = null;
                    StateContainer.InterpretationDetail.ValidatedComment = null;
                    StateContainer.InterpretationDetail.ValidatedDate = null;
                }
                else
                {
                    StateContainer.InterpretationDetail.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                    StateContainer.InterpretationDetail.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    StateContainer.InterpretationDetail.ValidatedByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName;
                    StateContainer.InterpretationDetail.ValidatedDate = DateTime.Now;
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
        ///
        /// </summary>
        /// <returns></returns>
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (StateContainer.InterpretationDetail.TestInterpretationID)
            {
                case 0:
                    StateContainer.InterpretationDetail.TestInterpretationID = (StateContainer.TestInterpretations.Count + 1) * -1;
                    StateContainer.InterpretationDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    StateContainer.InterpretationDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                    break;

                case > 0:
                    StateContainer.InterpretationDetail.RowAction = (int)RowActionTypeEnum.Update;
                    break;
            }

            if (StateContainer.InterpretationDetail.InterpretedStatusTypeID is not null)
                StateContainer.InterpretationDetail.InterpretedStatusTypeName = InterpretedStatusTypes.First(x => x.IdfsBaseReference == StateContainer.InterpretationDetail.InterpretedStatusTypeID).Name;

            // species just comes over from the original sample
            if (StateContainer.InterpretationDetail.SpeciesID is null)
            {
                StateContainer.InterpretationDetail.Species = null;
                StateContainer.InterpretationDetail.SpeciesTypeName = null;
            }
            else
            {
                StateContainer.InterpretationDetail.Species = StateContainer.InterpretationDetail.Species;
                StateContainer.InterpretationDetail.SpeciesTypeName =
                    StateContainer.InterpretationDetail.SpeciesTypeName;
            }

            var isTestResultIndicative = StateContainer.Tests
                .First(x => x.TestID == StateContainer.InterpretationDetail.TestID).IsTestResultIndicative;
            if (isTestResultIndicative != null)
                StateContainer.InterpretationDetail.IndicativeIndicator = (bool)isTestResultIndicative;

            // propagate the disease using type
            StateContainer.InterpretationDetail.DiseaseUsingType = StateContainer.DiseaseSpeciesSamples
                .First(x => x.DiseaseID == StateContainer.InterpretationDetail.DiseaseID).DiseaseUsingType;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                    DiagService.Close();
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