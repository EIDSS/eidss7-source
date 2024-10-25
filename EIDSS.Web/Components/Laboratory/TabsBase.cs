#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class TabsBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<TabsBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        public int SelectedIndex { get; set; }
        public string SamplesTabName { get; set; }
        public string TestingTabName { get; set; }
        public string TransferredTabName { get; set; }
        public string MyFavoritesTabName { get; set; }
        public string BatchesTabName { get; set; }
        public string ApprovalsTabName { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "SamplesTabCount";
        private const string ZeroTabCount = " (0)";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public TabsBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected TabsBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

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

            LaboratoryService.Samples = null;
            LaboratoryService.Testing = null;
            LaboratoryService.Transferred = null;
            LaboratoryService.MyFavorites = null;
            LaboratoryService.Batches = null;
            LaboratoryService.Approvals = null;
            LaboratoryService.TestCompletedIndicator = null;
            LaboratoryService.TestUnassignedIndicator = null;

            LaboratoryService.NewSamplesRegisteredCount = 0;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender) await LoadTabCounts();
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers.
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #region Common

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task LoadTabCounts()
        {
            try
            {
                var request = new TabCountsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 100,
                    SortColumn = DefaultSortColumn,
                    SortOrder = SortConstants.Ascending,
                    DaysFromAccessionDate =
                        Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };
                var tabCounts = await LaboratoryClient.GetTabCountsList(request, _token);

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
                if (_userPermissions.Read)
                {
                    SamplesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratorySamplesHeading) + " (" +
                                     tabCounts[0].SamplesTabCount + ")";
                    MyFavoritesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) +
                                         " (" + tabCounts[0].MyFavoritesTabCount + ")";
                }
                else
                {
                    SamplesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratorySamplesHeading) +
                                     ZeroTabCount;
                    MyFavoritesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) +
                                         ZeroTabCount;
                }

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);
                if (_userPermissions.Read)
                    TestingTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestingHeading) + " (" +
                                     tabCounts[0].TestingTabCount + ")";
                else
                    TestingTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestingHeading) +
                                     ZeroTabCount;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);
                if (_userPermissions.Read)
                    TransferredTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferredHeading) +
                                         " (" + tabCounts[0].TransferredTabCount + ")";
                else
                    TransferredTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferredHeading) +
                                         ZeroTabCount;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);
                if (_userPermissions.Read)
                    BatchesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryBatchesHeading) + " (" +
                                     tabCounts[0].BatchesTabCount + ")";
                else
                    BatchesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryBatchesHeading) +
                                     ZeroTabCount;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
                if (_userPermissions.Read)
                    ApprovalsTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryApprovalsHeading) +
                                       " (" + tabCounts[0].ApprovalsTabCount + ")";
                else
                    ApprovalsTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryApprovalsHeading) +
                                       ZeroTabCount;

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="index"></param>
        public void OnChange(int index)
        {
            switch (index)
            {
                case 0:
                    Tab = LaboratoryTabEnum.Samples;
                    break;
                case 1:
                    Tab = LaboratoryTabEnum.Testing;
                    break;
                case 2:
                    Tab = LaboratoryTabEnum.Transferred;
                    break;
                case 3:
                    Tab = LaboratoryTabEnum.MyFavorites;
                    break;
                case 4:
                    Tab = LaboratoryTabEnum.Batches;
                    break;
                case 5:
                    Tab = LaboratoryTabEnum.Approvals;
                    break;
            }

            LaboratoryService.TabChangeIndicator = true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadTabCounts()
        {
            await LoadTabCounts();
        }

        /// <summary>
        /// </summary>
        /// <param name="unaccessionedSampleCount"></param>
        protected void OnReloadSamplesTabCount(int unaccessionedSampleCount)
        {
            SamplesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratorySamplesHeading) + " (" +
                             unaccessionedSampleCount + ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="inProgressTestCount"></param>
        protected void OnReloadTestingTabCount(int inProgressTestCount)
        {
            TestingTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestingHeading) + " (" +
                             inProgressTestCount + ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="count"></param>
        protected void OnReloadTransferredTabCount(int count)
        {
            TransferredTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferredHeading) + " (" +
                                 count + ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="count"></param>
        protected void OnReloadMyFavoritesTabCountForSearch(int count)
        {
            MyFavoritesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) + " (" +
                                 count + ")";
        }

        /// <summary>
        /// </summary>
        protected void OnReloadMyFavoritesTabCount()
        {
            MyFavoritesTabName = LaboratoryService.MyFavorites is not null && LaboratoryService.MyFavorites.Any()
                ? Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) + " (" +
                    LaboratoryService.MyFavorites[0].FavoriteCount + ")"
                : Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) + " (" +
                    0 + ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="newRecordCount"></param>
        protected void OnReloadMyFavoritesTabCountForNewRecord(int newRecordCount)
        {
            MyFavoritesTabName = LaboratoryService.MyFavorites is not null && LaboratoryService.MyFavorites.Any()
                ? Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) + " (" +
                                 (LaboratoryService.MyFavorites[0].FavoriteCount + newRecordCount) + ")"
                : Localizer.GetString(HeadingResourceKeyConstants.LaboratoryMyFavoritesHeading) + " (" +
                 0 + ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="count"></param>
        protected void OnReloadBatchesTabCount(int count)
        {
            BatchesTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryBatchesHeading) + " (" + count +
                             ")";
        }

        /// <summary>
        /// </summary>
        /// <param name="count"></param>
        protected void OnReloadApprovalsTabCount(int count)
        {
            ApprovalsTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryApprovalsHeading) + " (" +
                               count + ")";
        }

        /// <summary>
        /// </summary>
        protected void OnUpdateTransferCount()
        {
            var transferredCount = 0;

            if (LaboratoryService.Transferred != null && LaboratoryService.Transferred.Any())
                transferredCount = LaboratoryService.Transferred.First().InProgressCount;

            TransferredTabName = Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferredHeading) + " (" +
                                 transferredCount + ")";
        }

        #endregion

        #endregion
    }
}