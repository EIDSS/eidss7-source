#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
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
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class TestDetailsBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<TestDetailsBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IEmployeeClient EmployeeClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public TestingGetListViewModel Test { get; set; }
        [Parameter] public SamplesGetListViewModel Sample { get; set; }
        [Parameter] public TransferredGetListViewModel Transfer { get; set; }

        #endregion

        #region Properties

        public RadzenTemplateForm<TestingGetListViewModel> Form { get; set; }
        public List<EmployeeLookupGetListViewModel> EmployeeList { get; set; }
        public bool WritePermissionIndicator { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public TestDetailsBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected TestDetailsBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);
            WritePermissionIndicator = _userPermissions.Write;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            if (LaboratoryService.TestStatusTypes is null)
                await GetTestStatusTypes();

            if (LaboratoryService.TestResultTypes is null)
                await GetTestResultTypes();

            if (LaboratoryService.TestCategoryTypes is null)
                await GetTestCategoryTypes();

            if (Test is null)
            {
                Test = new TestingGetListViewModel
                {
                    TestStatusTypeID = (long) TestStatusTypeEnum.NotStarted
                };
            }
            else
            {
                if (Test.TestStatusTypeID == 0)
                    Test.TestStatusTypeID = (long) TestStatusTypeEnum.NotStarted;

                if (Test.ResultEnteredByPersonID is not null && Test.ResultEnteredByPersonName is null)
                {
                    EmployeeGetListRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        EmployeeID = Test.ResultEnteredByPersonID,
                        SortColumn = "EmployeeID",
                        SortOrder = SortConstants.Ascending,
                        Page = 1,
                        PageSize = MaxValue - 1
                    };
                    var employees = await EmployeeClient.GetEmployeeList(request);
                    if (employees != null)
                        Test.ResultEnteredByPersonName = employees.FirstOrDefault()?.EmployeeFullName;
                }

                if (Test.ValidatedByPersonID is not null && Test.ValidatedByPersonName is null)
                {
                    EmployeeGetListRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        EmployeeID = Test.ValidatedByPersonID,
                        SortColumn = "EmployeeID",
                        SortOrder = SortConstants.Ascending,
                        Page = 1,
                        PageSize = MaxValue - 1
                    };
                    var employees = await EmployeeClient.GetEmployeeList(request);
                    if (employees != null)
                        Test.ValidatedByPersonName = employees.FirstOrDefault()?.EmployeeFullName;
                }

                if (Test.ExternalTestIndicator)
                {
                    if (Test.PerformedByOrganizationID != null)
                    {
                        OrganizationGetRequestModel request = new()
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = "Order",
                            SortOrder = SortConstants.Ascending,
                            OrganizationTypeID = Convert.ToInt64(OrganizationTypes.Laboratory)
                        };

                        var allSites = await OrganizationClient.GetOrganizationList(request);
                        var site = allSites.FirstOrDefault(x => x.OrganizationKey == Test.PerformedByOrganizationID);
                        if (site != null) Test.PerformedByOrganizationName = site.AbbreviatedName;
                    }

                    if (Transfer is not null && Transfer.TransferID > 0)
                    {
                        Transfer.ActionPerformedIndicator = true;
                        Transfer.ResultDate = Test.ResultDate;
                        Transfer.RowAction = (int) RowActionTypeEnum.Update;
                        Transfer.StartedDate = Test.StartedDate;
                        Transfer.TestCategoryTypeID = Test.TestCategoryTypeID;
                        Transfer.TestNameTypeID = Test.TestNameTypeID;
                        Transfer.TestNameTypeName = Test.TestNameTypeName;
                        Transfer.TestResultTypeID = Test.TestResultTypeID;
                        Transfer.TestResultTypeName = Test.TestResultTypeName;
                        Transfer.TestStatusTypeID = Test.TestStatusTypeID;
                        Transfer.TestStatusTypeName = Test.TestStatusTypeName;
                    }
                }
            }

            if (Sample is null)
            {
                SamplesGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "Query",
                    SortOrder = SortConstants.Ascending,
                    DaysFromAccessionDate = 0,
                    SampleID = Test.SampleID,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                var samples = await LaboratoryClient.GetSamplesList(request, _token);
                Sample = samples.Any() ? samples.First() : new SamplesGetListViewModel();
            }

            if (Transfer is not null && Transfer.TransferID > 0)
            {
                if (Transfer.DiseaseID is not null && Transfer.DiseaseID.Contains("|") == false)
                {
                    Test.DiseaseID = Convert.ToInt64(Transfer.DiseaseID);
                    Test.DiseaseName = Transfer.DiseaseName;
                }
            }

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await GetTestedByEmployees();
                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
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

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task GetTestedByEmployees()
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.NoneHACode,
                    AdvancedSearch = null,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending,
                    OrganizationID = Transfer is not null && Transfer.TransferID != 0 ? Transfer.TransferredToOrganizationID : authenticatedUser.OfficeId
                };

                var list = await CrossCuttingClient.GetEmployeeLookupList(request);
                EmployeeList = list;
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
        protected async Task OpenEmployeeAddModal()
        {
            try
            {
                var dialogParams = new Dictionary<string, object> {{"OrganizationID", Test.TestedByOrganizationID}};

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        //Height = CSSClassConstants.DefaultDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                // re-fetch for dropdown
                await GetTestedByEmployees();

                if (result == null)
                {
                    return;
                }
                    
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnTestedByDropDownChange(object value)
        {
            if (value == null)
            {
                Test.TestedByOrganizationID = null;
            }
            else
            {
                if (EmployeeList is not null && EmployeeList.Any(x => x.idfPerson == (long) value))
                    Test.TestedByOrganizationID = EmployeeList.First(x => x.idfPerson == (long) value).idfOffice;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnTestNameDropDownChange(object value)
        {
            if (value == null)
            {
                Test.TestStatusTypeID = (long) TestStatusTypeEnum.NotStarted;
                Test.StartedDate = null;
                Test.ResultDate = null;
                Test.ResultEnteredByOrganizationID = null;
                Test.ResultEnteredByPersonID = null;
                Test.ResultEnteredByPersonName = null;
                Test.ValidatedByOrganizationID = null;
                Test.ValidatedByPersonID = null;
                Test.ValidatedByPersonName = null;
            }
            else
            {
                Test.StartedDate = DateTime.Now;
                Test.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnTestResultDropDownChange(object value)
        {
            Test.ActionPerformedIndicator = true;

            if (value == null)
            {
                Test.ResultDate = null;
                Test.ResultEnteredByOrganizationID = null;
                Test.ResultEnteredByPersonID = null;
                Test.ResultEnteredByPersonName = null;
            }
            else
            {
                Test.StartedDate ??= DateTime.Now;
                Test.ResultDate = DateTime.Now;
                Test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                Test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                Test.ResultEnteredByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;

                // Test results entered for an external laboratory (does not use EIDSS) by the transferring laboratory.
                if (Test.ExternalTestIndicator)
                {
                    Test.TestStatusTypeID = ((long) TestStatusTypeEnum.Final);
                    Test.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                    Test.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    Test.ValidatedByPersonName = authenticatedUser.LastName +
                                                 (IsNullOrEmpty(authenticatedUser.FirstName)
                                                     ? ""
                                                     : ", " + authenticatedUser.FirstName);
                }
                else
                {
                    if (Test.TestStatusTypeID != (long) TestStatusTypeEnum.Final) Test.TestStatusTypeID = (long) TestStatusTypeEnum.Preliminary;
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnTestStatusDropDownChange(object value)
        {
            try
            {
                Test.TestStatusTypeID = (long) value;

                switch (Test.TestStatusTypeID)
                {
                    case (long) TestStatusTypeEnum.Final:
                        Test.ResultDate ??= DateTime.Now;
                        Test.ResultEnteredByOrganizationID ??= authenticatedUser.OfficeId;
                        Test.ResultEnteredByPersonID ??= Convert.ToInt64(authenticatedUser.PersonId);
                        Test.ResultEnteredByPersonName ??= authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);

                        Test.ValidatedByOrganizationID = authenticatedUser.OfficeId;
                        Test.ValidatedByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        Test.ValidatedByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);

                        if (Test.TestResultTypeID is null)
                            Test.TestResultTypeDisabledIndicator = false;
                        break;
                    case (long) TestStatusTypeEnum.InProgress:
                        Test.ResultDate = null;
                        Test.ResultEnteredByOrganizationID = null;
                        Test.ResultEnteredByPersonID = null;
                        Test.ResultEnteredByPersonName = null;
                        Test.TestResultTypeID = null;
                        Test.ValidatedByOrganizationID = null;
                        Test.ValidatedByPersonID = null;
                        Test.ValidatedByPersonName = null;
                        break;
                    case (long) TestStatusTypeEnum.Preliminary:
                        Test.ResultDate ??= DateTime.Now;
                        Test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        Test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        Test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                        break;
                }

                Test.ActionPerformedIndicator = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnResultsReceivedFromTextBoxChange(object value)
        {
            Test.PerformedByOrganizationID = value is null ? null : Transfer.TransferredToOrganizationID;
        }

        #endregion
    }
}