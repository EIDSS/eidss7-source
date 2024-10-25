using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using static System.String;

namespace EIDSS.Web.Components.HelpFiles
{

    public class HelpFileComponentBase : BaseComponent
    {
        #region Dependencies

        [Inject] public ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        [Inject] private IMenuClient MenuClient { get; set; }

        [Inject] private ILogger<HelpFileComponentBase> Logger { get; set; }

        [Inject] private IHttpContextAccessor HttpContextAccessor { get; set; }


        #endregion

        #region Properties

        #endregion

        #region Member Variables

        protected RadzenTemplateForm<HelpFileComponentViewModel> Form;

        protected HelpFileComponentViewModel Model;
        
        #endregion

        #region Private Members

        private string _langId = Empty;

        private CancellationTokenSource _source;
        public CancellationToken Token { get; private set; }

        private string XSiteUrl { get; set; }

        #endregion

        #region Parameters

        [Parameter] 
        public long? SessionId { get; set; }
        [Parameter] 
        public bool IsReadOnly { get; set; }
        [Parameter] 
        public long MenuItem { get; set; }
        [Parameter]
        public bool IsLoading { get; set; } = true;
        [Parameter]
        public bool IsDisabled { get; set; } = true;
        [Parameter]
        public string HttpProtocol { get; set; }

        #endregion

        protected override async Task OnInitializedAsync()
        {
            try
            {
                IsLoading = true;

                _logger = Logger;

                var uri = NavManager.Uri;
                XSiteUrl = XSiteBaseUrl;

                InitializeModel();

                // reset the cancellation token
                _source = new CancellationTokenSource();
                Token = _source.Token;

                if (Model != null)
                {
                    Model.HelpFileUserPermissions =
                        GetUserPermissions(PagePermission.AccessToAdministrativeStandardReports);

                    Model.IsReadonly = IsReadOnly;

                    // Note: SessionID parameter is passed in on edit,
                    // otherwise it is null for add
                    if (SessionId != null)
                    {
                        Model.SessionKey = SessionId.Value;
                    }

                    _langId = Model.GetCurrentLanguage();

                    // save off this for processing
                    Model.URL = uri;
                    //Model.BaseURL = baseUri;
                    Model.BaseURL = XSiteUrl;

                    // get the protocol
                    //int idx = xSiteUrl.IndexOf(':');
                    //HttpProtocol = xSiteUrl[..(idx + 1)];
                    if (HttpContextAccessor.HttpContext != null)
                        HttpProtocol = $"{HttpContextAccessor.HttpContext.Request.Scheme}:";

                    // get the current menuId
                    if (ParseUrl(Model.URL))
                    {
                        await GetMenuId();
                    }

                    // load the files
                    if (MenuItem != 0)
                    {
                        await LoadData();
                    }
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {

                await base.OnInitializedAsync();
                //StateHasChanged();
            }
        }
        
        protected override Task OnAfterRenderAsync(bool firstRender)
        {
            base.OnAfterRender(firstRender);
            if (firstRender)
            {
            }

            return Task.CompletedTask;
        }

        private void InitializeModel()
        {
            try
            {
                // get the default admin levels
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

                long? eidssUserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                long? userEmployeeId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                long? userOrganizationId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                long? userSiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                Model = new HelpFileComponentViewModel
                {
                    UserEmployeeID = userEmployeeId,
                    UserOrganizationID = userOrganizationId,
                    UserSiteID = userSiteId,
                    EIDSSUserID = eidssUserId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        // this get's all the doc's and videos for a given EIDSS Menu ID
        private async Task<List<XSiteDocumentListViewModel>> GetXSitePageDocuments(string langId)
        {
            try
            {
                if (Model.URL.Contains("Veterinary/VeterinaryDiseaseReport/Details"))
                    Model.EIDSSMenuId = Model.URL.Contains("?reportTypeID=" + (long)CaseTypeEnum.Avian) ? (long)MenuIdentifiersEnum.AvianDiseaseReport : (long)MenuIdentifiersEnum.LivestockDiseaseReport;

                var menuId = Convert.ToInt64(Model.EIDSSMenuId);

                var docs = await CrossCuttingClient.GetPageDocuments(menuId, langId);

                return docs;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected bool ParseUrl(string url)
        {
            try
            {
                // get a substring that does not include the base url
                // use a "range indexer" and range operator ".." to get the value
                //url = url[(baseUrl.Length + 2)..];
                var localUrl = url.Replace(NavManager.BaseUri, "");

                var index = localUrl.IndexOf("?", StringComparison.Ordinal);
                if (index >= 0)
                {
                    index -= 1;
                    localUrl = localUrl[..index];
                    if (localUrl.EndsWith("/"))
                    {
                        localUrl= localUrl[^1..];
                    }
                }

                var urlParts = localUrl.Split('/');
                // get the count of elements
                var nUrlPartsCnt = urlParts.Length;

                // There are no help files here...
                //if (urlParts.LastOrDefault() == "Dashboard")
                //{
                //   // return false;
                //}

                // get the Area/Controller/StrAction
                // if the count is 2 we have just Area and Controller
                //Model.Area = urlParts[0];
                //Model.Controller = urlParts[1];
                //Model.StrAction = String.Empty;
                //Model.UrlPartCount = urlParts.Length;

                switch (nUrlPartsCnt)
                {
                    case 2:
                        Model.Area = urlParts[0];
                        Model.Controller = urlParts[1];
                        Model.SubArea = Empty;
                        Model.StrAction = Empty;
                        break;
                    case 3:
                        Model.Area = urlParts[0];
                        Model.Controller = urlParts[1];
                        Model.SubArea = Empty;
                        Model.StrAction = urlParts[2];
                        break;
                    case 4:
                        Model.Area = urlParts[0];
                        Model.SubArea = urlParts[1];
                        Model.Controller = urlParts[2];
                        Model.StrAction = urlParts[3];
                        break;
                }

                if (nUrlPartsCnt == 3)
                {
                    var subAreaExists = EIDSSConstants.SubAreas.Any(s => localUrl.ToUpper().Contains(s.ToUpper()));
                    if (subAreaExists)
                    {
                        Model.Area = urlParts[0];
                        Model.SubArea = urlParts[1];
                        Model.Controller = urlParts[2];
                        Model.StrAction = Empty;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            return true;
        }

        protected async Task GetMenuId()
        {
            try
            {
                if (Model.EIDSSUserID != null)
                {
                    if (Model.Controller.ToUpper() == EIDSSConstants.PageNames.Dashboard)
                    {
                        MenuItem = (long) MenuEnum.DashBoard;
                    }
                    else
                    {
                        var userId = Convert.ToInt64(Model.EIDSSUserID);
                        var result = await MenuClient.GetMenuByUserListAsync(userId, _langId,
                            _tokenService.GetAuthenticatedUser().IsInArchiveMode);

                        var menuResult = result.Where(a => a.Area == Model.Area && 
                                                           a.SubArea == Model.SubArea &&
                                                           a.Controller == Model.Controller && 
                                                           a.strAction == Model.StrAction).ToList();
                        if (menuResult.Any())
                        {
                            MenuItem = menuResult.FirstOrDefault()!.EIDSSMenuId;
                            return;
                        }

                        menuResult = result.Where(a => a.Area == Model.Area &&
                                                       a.SubArea == Model.SubArea &&
                                                       a.Controller == Model.Controller )
                            .ToList();
                        if (menuResult.Any())
                        {
                            MenuItem = menuResult.FirstOrDefault()!.EIDSSMenuId;
                            return;
                        }

                        menuResult = result.Where(a => a.Area == Model.Area &&
                                                       a.Controller == Model.Controller &&
                                                       a.strAction == Model.StrAction)
                            .ToList();
                        if (menuResult.Any())
                        {
                            MenuItem = menuResult.FirstOrDefault()!.EIDSSMenuId;
                            return;
                        }

                        menuResult = result.Where(a => a.Area == Model.Area &&
                                                       a.Controller == Model.Controller )
                            .ToList();
                        if (menuResult.Any())
                        {
                            MenuItem = menuResult.FirstOrDefault()!.EIDSSMenuId;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
        
        // the dropdown will fly-down automatically if we have a menu id
        protected async Task LoadData()
        {
            try
            {
                // add the page code here to populate the help file dropdown
                var langId = Model.GetCurrentLanguage();

                Model.EIDSSMenuId = MenuItem;

                if (Model.EIDSSMenuId != 0)
                {
                    // there is are two (2) file names returned for the same page e.g.(Search for a Person Record)
                    // the difference is that one is for Human, and the other for Veterinary 
                    var docs = await GetXSitePageDocuments(langId);
                    // we have to sort the names so the .pdf and .mp4 are together
                    docs = docs.OrderBy(x => x.FileName).ToList();

                    // clear our menu list
                    Model.XSiteDocumentList.Clear();
                    foreach (var item in docs)
                    {
                        Model.XSiteDocumentList.Add(item);
                    }
                }
                
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}