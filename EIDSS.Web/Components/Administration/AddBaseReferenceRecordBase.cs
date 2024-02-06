#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Administration
{
    public class AddBaseReferenceRecordBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AddBaseReferenceRecord> Logger { get; set; }
        [Inject] private IAdminClient AdministrationClient {  get; set; }
        [Inject] private ISpeciesTypeClient SpeciesTypeClient { get; set; }
        [Inject] private ISampleTypesClient SampleTypeClient { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public int? AccessoryCode { get; set; }
        [Parameter]
        public long BaseReferenceTypeID { get; set; }
        [Parameter]
        public string BaseReferenceTypeName { get; set; }
        [Parameter]
        public BaseReferenceSaveRequestModel Model { get; set; }

        #endregion

        #region Properties

        public RadzenTemplateForm<BaseReferenceSaveRequestModel> Form { get; set; }

        #endregion

        #region Member Variables

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task OnSubmit()
        {
            try
            {
                if (Form.EditContext.Validate())
                {
                    Model.LanguageId = GetCurrentLanguage();
                    Model.ReferenceTypeId = BaseReferenceTypeID;
                    Model.intOrder ??= 0;
                    Model.intHACode = AccessoryCode;
                    dynamic result;

                    switch (Model.ReferenceTypeId)
                    {
                        case (long)ReferenceTypes.SampleType:
                            SampleTypeSaveRequestModel sampleTypeRequest = new()
                            {
                                LanguageId = GetCurrentLanguage(),
                                intOrder = Model.intOrder ?? 0,
                                intHACode = AccessoryCode,
                                Default = Model.Default,
                                Name = Model.Name,
                                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                                AuditUserName = authenticatedUser.UserName,
                                LocationId = authenticatedUser.RayonId,
                                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                            };

                            var sampleTypeResponse = await SampleTypeClient.SaveSampleType(sampleTypeRequest);

                            switch (sampleTypeResponse.ReturnMessage)
                            {
                                case EIDSSConstants.DatabaseResponses.Success:
                                    result = await ShowInformationalDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage, null);

                                    if (result is DialogReturnResult)
                                        DiagService.Close(sampleTypeResponse);
                                    break;
                                case EIDSSConstants.DatabaseResponses.DoesExist:
                                    sampleTypeResponse.StrDuplicateField = Model.Default;
                                    var duplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), sampleTypeResponse.StrDuplicateField);

                                    result = await ShowWarningDialog(null, duplicateMessage);

                                    if (result is DialogReturnResult returnResult)
                                    {
                                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                                            DiagService.Close(result);
                                    }
                                    break;
                            }
                            break;
                        case (long)ReferenceTypes.SpeciesList:
                            SpeciesTypeSaveRequestModel speciesTypeRequest = new()
                            {
                                LanguageId = GetCurrentLanguage(),
                                intOrder = Model.intOrder ?? 0,
                                intHACode = AccessoryCode,
                                Default = Model.Default,
                                Name = Model.Name,
                                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                                AuditUserName = authenticatedUser.UserName,
                                LocationId = authenticatedUser.RayonId,
                                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                            };

                            var speciesTypeResponse = await SpeciesTypeClient.SaveSpeciesType(speciesTypeRequest);

                            switch (speciesTypeResponse.ReturnMessage)
                            {
                                case EIDSSConstants.DatabaseResponses.Success:
                                    result = await ShowInformationalDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage, null);

                                    if (result is DialogReturnResult)
                                        DiagService.Close(speciesTypeResponse);
                                    break;
                                case EIDSSConstants.DatabaseResponses.DoesExist:
                                    speciesTypeResponse.StrDuplicateField = Model.Default;
                                    var duplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), speciesTypeResponse.StrDuplicateField);

                                    result = await ShowWarningDialog(null, duplicateMessage);

                                    if (result is DialogReturnResult returnResult)
                                    {
                                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                                            DiagService.Close(result);
                                    }
                                    break;
                            }
                            break;
                        default:
                            var defaultResponse = await AdministrationClient.SaveBaseReference(Model);

                            switch (defaultResponse.ReturnMessage)
                            {
                                case EIDSSConstants.DatabaseResponses.Success:
                                    result = await ShowInformationalDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage, null);

                                    if (result is DialogReturnResult)
                                        DiagService.Close(defaultResponse);
                                    break;
                                case EIDSSConstants.DatabaseResponses.DoesExist:
                                    defaultResponse.strDuplicatedField = Model.Default;
                                    defaultResponse.strClientPageMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), defaultResponse.strDuplicatedField);

                                    result = await ShowWarningDialog(null, defaultResponse.strClientPageMessage);

                                    if (result is DialogReturnResult returnResult)
                                    {
                                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                                            DiagService.Close(result);
                                    }
                                    break;
                            }
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

        #region Cancel Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
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
