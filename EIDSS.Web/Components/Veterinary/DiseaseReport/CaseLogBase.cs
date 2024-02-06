#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class CaseLogBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseLogBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public CaseLogGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        public RadzenTemplateForm<CaseLogGetListViewModel> Form { get; set; }

        public IEnumerable<BaseReferenceViewModel> LogStatusTypes;
        public IList<EmployeeLookupGetListViewModel> EnteredByPersons;

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public CaseLogBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected CaseLogBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            await GetEnteredByPersons(new LoadDataArgs());

            if (Model.EnteredByPersonID is not null)
                if (EnteredByPersons.Any(x => x.idfPerson == (long) Model.EnteredByPersonID))
                {
                    EmployeeLookupGetListViewModel model = new()
                    {
                        idfPerson = (long) Model.EnteredByPersonID,
                        FullName = Model.EnteredByPersonName
                    };

                    EnteredByPersons.Add(model);
                }

            await base.OnInitializedAsync();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~AnimalBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetEnteredByPersons(LoadDataArgs args)
        {
            try
            {
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    OrganizationID = authenticatedUser.OfficeId,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                EnteredByPersons = await CrossCuttingClient.GetEmployeeLookupList(request);
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
        public async Task GetLogStatusTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.VetCaseLogStatus, HACodeList.NoneHACode);

                LogStatusTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    LogStatusTypes = LogStatusTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
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
        /// </summary>
        /// <returns></returns>
        protected void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.DiseaseReportLogID)
            {
                case 0:
                    Model.DiseaseReportLogID = (DiseaseReport.CaseLogs.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            if (Model.EnteredByPersonID is not null)
                if (EnteredByPersons.Any(x => x.idfPerson == Model.EnteredByPersonID))
                    Model.EnteredByPersonName =
                        EnteredByPersons.First(x => x.idfPerson == Model.EnteredByPersonID).FullName;

            if (Model.LogStatusTypeID is not null)
                Model.LogStatusTypeName = LogStatusTypes.First(x => x.IdfsBaseReference == Model.LogStatusTypeID).Name;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
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