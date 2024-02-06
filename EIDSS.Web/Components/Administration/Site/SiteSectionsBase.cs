#region Usings

using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.Site
{
    public class SiteSectionsBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SiteSectionsBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject] private ISiteClient SiteClient { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public SiteDetailsViewModel Model { get; set; }

        #endregion

        #region Member Variables

        private UserPermissions _userPermissions;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                authenticatedUser = _tokenService.GetAuthenticatedUser();

                _userPermissions = GetUserPermissions(PagePermission.AccessToEIDSSSitesList_ManagingDataAccessFromOtherSites);

                await JsRuntime.InvokeAsync<string>("initializeSidebar", _token, Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(), _userPermissions.Delete,
                    Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                        .ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                await JsRuntime.InvokeVoidAsync("Site.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        /// <summary>
        ///
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Save Methods

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnSubmit")]
        public async Task<SiteDetailsViewModel> OnSubmit()
        {
            try
            {
                if (Model.SiteInformationSectionValidIndicator && Model.OrganizationsSectionValidIndicator && Model.PermissionsSectionValidIndicator)
                {
                    Model.SiteInformationSection.SiteDetails.RowStatus = Model.SiteInformationSection.SiteDetails.ActiveStatusIndicator ? 0 : 1;

                    var request = new SiteSaveRequestModel()
                    {
                        LanguageID = GetCurrentLanguage(),
                        SiteDetails = Model.SiteInformationSection.SiteDetails,
                        AuditUserName = authenticatedUser.UserName,
                        Organizations = JsonConvert.SerializeObject(BuildOrganizationParameters(Model.OrganizationsSection.PendingSaveOrganizations)),
                        Permissions = JsonConvert.SerializeObject(BuildActorPermissionParameters(Model.PermissionsSection.PendingSaveActorPermissions))
                    };

                    var response = await SiteClient.SaveSite(request);

                    if (response.ReturnCode != null)
                    {
                        switch (response.ReturnCode)
                        {
                            // Success
                            case 0:
                                if (Model.SiteInformationSection.SiteDetails.SiteID == null)
                                {
                                    Model.SiteInformationSection.SiteDetails.SiteID = response.KeyId;
                                    Model.SiteInformationSection.SiteDetails.CustomizationPackageID = response.AdditionalKeyId;
                                }
                                Model.InformationalMessage = Localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage);

                                Model.OrganizationsSection.PendingSaveOrganizations =
                                    new List<OrganizationGetListViewModel>();
                                Model.PermissionsSection.PendingSaveActors =
                                    new List<SiteActorGetListViewModel>();
                                Model.PermissionsSection.PendingSaveActorPermissions =
                                    new List<ObjectAccessGetListViewModel>();

                                Model.SiteInformationSection.SiteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), response.KeyId, Convert.ToInt64(authenticatedUser.EIDSSUserId));

                                await JsRuntime.InvokeAsync<string>("reloadSiteSections", _token)
                                    .ConfigureAwait(false);

                                await ShowSuccessDialog(Model.InformationalMessage, null,
                                ButtonResourceKeyConstants.OKButton, null, null);

                                DiagService.Close();

                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Administration/Security/Site/List";

                                NavManager.NavigateTo(uri, true);

                                break;
                            // Duplicate EIDSS site ID found
                            case 1:
                                Model.ErrorMessage = Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateUniqueOrganizationIDMessage), Model.SiteInformationSection.SiteDetails.EIDSSSiteID);

                                await JsRuntime.InvokeAsync<string>("reloadSiteSections", _token)
                                    .ConfigureAwait(false);

                                await ShowErrorDialog(Model.ErrorMessage, null);
                                break;
                            // Duplicate HASC site ID found
                            case 2:
                                Model.ErrorMessage = Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateOrganizationAbbreviatedNameFullNameMessage), Model.SiteInformationSection.SiteDetails.HASCSiteID);

                                await JsRuntime.InvokeAsync<string>("reloadSiteSections", _token)
                                    .ConfigureAwait(false);

                                await ShowErrorDialog(Model.ErrorMessage, null);
                                break;

                            default:
                                throw new ApplicationException("Unable to save site.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save site.");
                    }

                    return Model;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideProcessingIndicator", _token).ConfigureAwait(false);
            }

            return new SiteDetailsViewModel();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="organizations"></param>
        /// <returns></returns>
        private static List<SiteOrganizationSaveRequestModel> BuildOrganizationParameters(IList<OrganizationGetListViewModel> organizations)
        {
            List<SiteOrganizationSaveRequestModel> requests = new();

            if (organizations is null)
                return new List<SiteOrganizationSaveRequestModel>();

            foreach (var siteOrganizationModel in organizations)
            {
                var request = new SiteOrganizationSaveRequestModel();
                {
                    request.OrganizationID = siteOrganizationModel.OrganizationKey;
                    if (siteOrganizationModel.RowAction != null)
                        request.RowAction = (int)siteOrganizationModel.RowAction;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="siteActorPermissions"></param>
        /// <returns></returns>
        private static List<ObjectAccessSaveRequestModel> BuildActorPermissionParameters(IList<ObjectAccessGetListViewModel> siteActorPermissions)
        {
            List<ObjectAccessSaveRequestModel> requests = new();

            if (siteActorPermissions is null)
                return new List<ObjectAccessSaveRequestModel>();

            foreach (var siteActorPermissionModel in siteActorPermissions)
            {
                var request = new ObjectAccessSaveRequestModel();
                {
                    request.ObjectAccessID = siteActorPermissionModel.ObjectAccessID;
                    if (siteActorPermissionModel.ObjectOperationTypeID != null)
                        request.ObjectOperationTypeID = (long) siteActorPermissionModel.ObjectOperationTypeID;
                    if (siteActorPermissionModel.ObjectTypeID != null)
                        request.ObjectTypeID = (long) siteActorPermissionModel.ObjectTypeID;
                    if (siteActorPermissionModel.ObjectID != null)
                        request.ObjectID = (long) siteActorPermissionModel.ObjectID;
                    request.ActorID = siteActorPermissionModel.ActorID;
                    request.DefaultEmployeeGroupIndicator = siteActorPermissionModel.DefaultEmployeeGroupIndicator;
                    if (siteActorPermissionModel.SiteID != null)
                        request.SiteID = (long) siteActorPermissionModel.SiteID;
                    request.PermissionTypeID = siteActorPermissionModel.PermissionTypeID;
                    request.RowStatus = siteActorPermissionModel.RowStatus;
                    request.RowAction = siteActorPermissionModel.RowAction;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Delete Method

        /// <summary>
        /// </summary>
        [JSInvokable("OnDelete")]
        public async Task OnDelete()
        {
            try
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
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        if (Model.SiteInformationSection.SiteDetails.SiteID != null)
                        {
                            var response = await SiteClient.DeleteSite((long)Model.SiteInformationSection.SiteDetails.SiteID, authenticatedUser.UserName);

                            if (response.ReturnCode == 0)
                            {
                                await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                    null);

                                DiagService.Close();

                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Administration/Security/Site/List?DeletionIndicator=true";

                                NavManager.NavigateTo(uri, true);
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

        #endregion
    }
}