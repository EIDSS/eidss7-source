#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class AccessionInDialogBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AccessionInDialogBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        public AccessionInViewModel AccessionInAction { get; set; }
        protected RadzenTemplateForm<AccessionInViewModel> Form { get; set; }

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AccessionInDialogBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AccessionInDialogBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            AccessionInAction = new AccessionInViewModel
            {
                AccessionConditionTypeID = (long)AccessionConditionTypeEnum.AcceptedInGoodCondition,
                DisablePrintBarcodeIndicator = false,
                PrintBarcodesIndicator = false
            };

            base.OnInitialized();

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion

        #region Accession Condition Type Drop Down Change Event

        /// <summary>
        /// </summary>
        protected void OnAccessionConditionTypeChange()
        {
            try
            {
                if (AccessionInAction.AccessionConditionTypeID == (long)AccessionConditionTypeEnum.Rejected)
                {
                    AccessionInAction.PrintBarcodesIndicator = false;
                    AccessionInAction.DisablePrintBarcodeIndicator = true;
                }
                else
                {
                    AccessionInAction.DisablePrintBarcodeIndicator = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Reject Sample Method

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private async Task Reject()
        {
            try
            {
                IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        foreach (var sample in LaboratoryService.SelectedSamples)
                            records.Add(new LaboratorySelectionViewModel { SampleID = sample.SampleID });

                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            records.Add(new LaboratorySelectionViewModel { SampleID = myFavorite.SampleID });

                        break;
                }

                var sampleIDs = new List<SampleIDsGetListViewModel>();

                if (AccessionInAction.AccessionConditionTypeID != null)
                {
                    if (LaboratoryService.AccessionConditionTypesWithoutUnaccessioned.All(x =>
                            x.IdfsBaseReference != (long)AccessionInAction.AccessionConditionTypeID))
                        sampleIDs = await AccessionIn(records, null, Empty);
                    else
                        sampleIDs = await AccessionIn(records, AccessionInAction.AccessionConditionTypeID,
                            LaboratoryService.AccessionConditionTypesWithoutUnaccessioned.First(x =>
                                x.IdfsBaseReference == AccessionInAction.AccessionConditionTypeID).Name);
                }

                if (AccessionInAction.PrintBarcodesIndicator && sampleIDs.Count > 0)
                {
                    LaboratoryService.PrintBarcodeSamples = sampleIDs.Aggregate(Empty,
                        (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                    if (LaboratoryService.PrintBarcodeSamples != null)
                        LaboratoryService.PrintBarcodeSamples =
                            LaboratoryService.PrintBarcodeSamples.Remove(
                                LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region OK Button Click Event

        /// <summary>
        /// </summary>
        protected async Task OnOKClick()
        {
            try
            {
                IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();

                if (AccessionInAction.AccessionConditionTypeID == (long) AccessionConditionTypeEnum.Rejected)
                {
                    await Reject();

                    DialogReturnResult returnResult = new()
                    {
                        ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.OKButton)
                    };
                    DiagService.Close(returnResult);
                }
                else
                {
                    switch (Tab)
                    {
                        case LaboratoryTabEnum.Samples:
                            foreach (var sample in LaboratoryService.SelectedSamples)
                                records.Add(new LaboratorySelectionViewModel {SampleID = sample.SampleID});

                            break;
                        case LaboratoryTabEnum.MyFavorites:
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                                records.Add(new LaboratorySelectionViewModel {SampleID = myFavorite.SampleID});

                            break;
                    }

                    var sampleIDs = new List<SampleIDsGetListViewModel>();

                    if (AccessionInAction.AccessionConditionTypeID != null)
                    {
                        if (LaboratoryService.AccessionConditionTypesWithoutUnaccessioned.All(x =>
                                x.IdfsBaseReference != (long) AccessionInAction.AccessionConditionTypeID))
                            sampleIDs = await AccessionIn(records, null, Empty);
                        else
                            sampleIDs = await AccessionIn(records, AccessionInAction.AccessionConditionTypeID,
                                LaboratoryService.AccessionConditionTypesWithoutUnaccessioned.First(x =>
                                    x.IdfsBaseReference == AccessionInAction.AccessionConditionTypeID).Name);

                        DialogReturnResult returnResult = new()
                        {
                            ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.OKButton)
                        };
                        DiagService.Close(returnResult);
                    }

                    if (AccessionInAction.PrintBarcodesIndicator && sampleIDs.Count > 0)
                    {
                        LaboratoryService.PrintBarcodeSamples = sampleIDs.Aggregate(Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
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
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

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