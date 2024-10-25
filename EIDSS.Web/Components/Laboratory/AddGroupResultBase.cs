#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class AddGroupResultBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AddGroupResultBase> Logger { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter] public BatchesGetListViewModel Batch { get; set; }

        #endregion

        #region Properties

        public TestingGetListViewModel Test { get; set; }
        public long? TestResultTypeId { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AddGroupResultBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AddGroupResultBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async void OnInitialized()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                authenticatedUser = _tokenService.GetAuthenticatedUser();
                await base.OnInitializedAsync();
                _logger = Logger;

                Test = new TestingGetListViewModel();

                if (LaboratoryService.TestResultTypes is null || !LaboratoryService.TestResultTypes.Any())
                {
                    await GetTestResultTypes();
                    await InvokeAsync(StateHasChanged);
                }

                if (Batch != null)
                    await GetTestsByBatchTestId();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
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
        /// <returns></returns>
        private async Task GetTestsByBatchTestId()
        {
            var request = new TestingGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = MaxValue - 1,
                SortColumn = "EIDSSLaboratorySampleID",
                SortOrder = SortConstants.Descending,
                BatchTestID = Batch.BatchTestID,
                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                UserOrganizationID = authenticatedUser.OfficeId,
                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
            };
            Batch.Tests = await LaboratoryClient.GetTestingList(request, _token);

            if (Batch.Tests.Any())
                Test = Batch.Tests.FirstOrDefault();
            if (Test != null) TestResultTypeId = Test.TestResultTypeID;
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected Task OnSaveClick()
        {
            try
            {
                foreach (var test in Batch.Tests)
                {
                    test.TestResultTypeID = TestResultTypeId;

                    if (test.TestResultTypeID is not null)
                    {
                        test.TestResultTypeName = LaboratoryService.TestResultTypes
                            .First(x => x.idfsTestResult == TestResultTypeId).strTestResultName;
                        test.ResultDate = DateTime.Now;
                        test.TestStatusTypeID = (long) TestStatusTypeEnum.Preliminary;
                    }
                    else
                    {
                        test.ResultDate = null;
                        test.TestStatusTypeID = (long) TestStatusTypeEnum.InProgress;
                    }
                    test.RowAction = (int) RowActionTypeEnum.Update;
                    test.ActionPerformedIndicator = true;
                    TogglePendingSaveTesting(test);
                }

                Batch.RowAction = (int) RowActionTypeEnum.Update;

                TogglePendingSaveBatches(Batch);
                DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.OK});
                return Task.CompletedTask;
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
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
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