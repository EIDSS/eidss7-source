#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.Site
{
    /// <summary>
    /// </summary>
    public class SiteInformationSectionBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SiteInformationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private ISiteClient SiteClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SiteDetailsViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<SiteDetailsViewModel> Form { get; set; }
        protected RadzenTextBox EIDSSSiteID { get; set; }
        protected RadzenDropDown<long?> SiteType { get; set; }
        protected RadzenDropDown<long?> ParentSite { get; set; }
        protected RadzenTextBox SiteName { get; set; }
        protected RadzenTextBox HASCSiteID { get; set; }
        protected RadzenDropDown<long?> Organization { get; set; }

        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public IList<SiteGetListViewModel> ParentSites { get; set; }
        public IEnumerable<BaseReferenceViewModel> SiteTypes;

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
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);

            Form = new RadzenTemplateForm<SiteDetailsViewModel> { EditContext = new EditContext(Model) };

            MessageStore = new List<EIDSSValidationMessageStore>();

            await base.OnInitializedAsync().ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await JsRuntime
                    .InvokeVoidAsync("SiteInformationSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this)).ConfigureAwait(false);

                await GetOrganizations(new LoadDataArgs()).ConfigureAwait(false);
            }

            Form.EditContext.OnFieldChanged += OnFormFieldChanged;
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            if (Form.EditContext is not null)
                Form.EditContext.OnFieldChanged -= OnFormFieldChanged;

            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Form Events

        /// <summary>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnFormFieldChanged(object sender, FieldChangedEventArgs e)
        {
            var errorMessages = Form.EditContext.GetValidationMessages(e.FieldIdentifier);

            var tabIndex = e.FieldIdentifier.FieldName switch
            {
                nameof(Model.SiteInformationSection.SiteDetails.EIDSSSiteID) => EIDSSSiteID.TabIndex,
                nameof(Model.SiteInformationSection.SiteDetails.ParentSiteID) => ParentSite.TabIndex,
                nameof(Model.SiteInformationSection.SiteDetails.SiteName) => SiteName.TabIndex,
                nameof(Model.SiteInformationSection.SiteDetails.SiteTypeID) => SiteType.TabIndex,
                nameof(Model.SiteInformationSection.SiteDetails.HASCSiteID) => HASCSiteID.TabIndex,
                nameof(Model.SiteInformationSection.SiteDetails.SiteOrganizationID) => Organization.TabIndex,
                _ => 0
            };

            var temp = MessageStore.Where(x => x.FieldName == e.FieldIdentifier.FieldName).ToList();
            foreach (var error in temp) MessageStore.Remove(error);

            var enumerable = errorMessages.ToList();
            if (!enumerable.Any()) return;
            foreach (var message in enumerable)
                MessageStore.Add(new EIDSSValidationMessageStore
                { FieldName = e.FieldIdentifier.FieldName, Message = message, TabIndex = tabIndex });
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSites(LoadDataArgs args)
        {
            try
            {
                SiteGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    SiteName = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SortColumn = "SiteName",
                    SortOrder = SortConstants.Ascending,
                    PageSize = int.MaxValue - 1,
                    Page = 1
                };

                ParentSites = await SiteClient.GetSiteList(request).ConfigureAwait(false);

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
        public async Task GetOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    RowStatus = (int)RowStatusTypeEnum.Active
                };

                Organizations = await OrganizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                Organizations = Organizations.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="organizationID"></param>
        [JSInvokable]
        public async Task OnOrganizationSelected(object organizationID)
        {
            await GetOrganizations(new LoadDataArgs());

            Model.SiteInformationSection.SiteDetails.SiteOrganizationID = Convert.ToInt64(organizationID.ToString());

            ValidateSectionForSidebar();

            await JsRuntime.InvokeAsync<string>("showSidebarStepIncompleteIcon", _token, "siteWizard", "0")
                            .ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetSiteTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.SiteType, HACodeList.NoneHACode);

                SiteTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    SiteTypes = SiteTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Site Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddSiteTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    { nameof(AddBaseReferenceRecord.AccessoryCode), (int)AccessoryCodeEnum.None },
                    { nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long)BaseReferenceTypeEnum.SiteType },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.SiteDetailsSiteTypeFieldLabel
                    },
                    { nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel() }
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        //Height = CSSClassConstants.DefaultDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                if (result is BaseReferenceSaveRequestResponseModel)
                {
                    await GetSiteTypes(new LoadDataArgs()).ConfigureAwait(false);
                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnCancel")]
        public async Task OnCancel()
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
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        var uri = $"{NavManager.BaseUri}Administration/Security/Site/List";

                        NavManager.NavigateTo(uri, true);
                    }
                }
                else
                {
                    DiagService.Close();

                    _source?.Cancel();

                    var uri = $"{NavManager.BaseUri}Administration/Security/Site/List";

                    NavManager.NavigateTo(uri, true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSubmit()
        {
            Model.SiteInformationSectionValidIndicator = Form.EditContext.Validate();

            if (Model.SiteInformationSectionValidIndicator) return Model.SiteInformationSectionValidIndicator;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count <= 0) return Model.SiteInformationSectionValidIndicator;
            switch (MessageStore.First().FieldName)
            {
                case nameof(Model.SiteInformationSection.SiteDetails.EIDSSSiteID):
                    await EIDSSSiteID.Element.FocusAsync();
                    break;

                case nameof(Model.SiteInformationSection.SiteDetails.ParentSiteID):
                    await ParentSite.Element.FocusAsync();
                    break;

                case nameof(Model.SiteInformationSection.SiteDetails.SiteName):
                    await SiteName.Element.FocusAsync();
                    break;

                case nameof(Model.SiteInformationSection.SiteDetails.SiteTypeID):
                    await SiteType.Element.FocusAsync();
                    break;

                case nameof(Model.SiteInformationSection.SiteDetails.HASCSiteID):
                    await HASCSiteID.Element.FocusAsync();
                    break;

                case nameof(Model.SiteInformationSection.SiteDetails.SiteOrganizationID):
                    await Organization.Element.FocusAsync();
                    break;
            }

            return Model.SiteInformationSectionValidIndicator;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            await InvokeAsync(StateHasChanged);

            Model.SiteInformationSectionValidIndicator = Form.EditContext.Validate();

            return Model.SiteInformationSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion
    }
}