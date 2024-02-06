#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class AmendTestResultBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AmendTestResultBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public TestingGetListViewModel Test { get; set; }

        #endregion

        #region Properties

        public RadzenTemplateForm<TestingGetListViewModel> Form { get; set; }
        public List<EmployeeLookupGetListViewModel> EmployeeList { get; set; }
        public string ReasonForAmendment { get; set; }
        public long? OldTestResultTypeId { get; set; }
        public string OldNote { get; set; }

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
        public AmendTestResultBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AmendTestResultBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            OldTestResultTypeId = Test.TestResultTypeID;
            OldNote = Test.Note;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            base.OnInitialized();
            _logger = Logger;
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

        #endregion

        #region Save Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSubmit()
        {
            try
            {
                Test.ActionPerformedIndicator = true;
                Test.TestStatusTypeID = (long) TestStatusTypes.Amended;
                Test.ResultDate = DateTime.Now;
                await UpdateTest(Test);

                var amendment = new TestAmendmentsSaveRequestModel
                {
                    TestAmendmentID = -1,
                    TestID = Test.TestID,
                    AmendedByOrganizationID = authenticatedUser.OfficeId,
                    AmendedByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                    AmendmentDate = DateTime.Now,
                    OldTestResultTypeID = OldTestResultTypeId,
                    ChangedTestResultTypeID = Test.TestResultTypeID,
                    OldNote = OldNote,
                    ChangedNote = null,
                    ReasonForAmendment = ReasonForAmendment,
                    RowStatus = 0,
                    RowAction = (int) RowActionTypeEnum.Insert,
                    EIDSSLaboratorySampleID = Test.EIDSSLaboratorySampleID
                };

                TogglePendingSaveTestAmendments(amendment);

                DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.OK});
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Click Event

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

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
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