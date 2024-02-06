#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Veterinary.SearchFarm;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case.Veterinary
{
    /// <summary>
    /// </summary>
    public class ContactPremiseBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ContactPremiseBase> Logger { get; set; }
        [Inject] protected IConfigurationClient ConfigurationClient { get; set; }
        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Case { get; set; }
        [Parameter] public ContactGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<ContactGetListViewModel> Form { get; set; }
        protected RadzenTextBox FarmOwnerLastNameTextBox { get; set; }
        protected RadzenTextBox FarmOwnerFirstNameTextBox { get; set; }
        protected RadzenTextBox FarmOwnerMiddleNameTextBox { get; set; }
        protected RadzenTextBox FarmNameTextBox { get; set; }
        protected RadzenTextBox PlaceOfLastContact { get; set; }
        protected RadzenTextArea ContactCommentsTextArea { get; set; }
        protected RadzenDropDown<long?> ContactStatusTypeDropDown { get; set; }

        protected IEnumerable<BaseReferenceViewModel> FarmTypes;
        public IEnumerable<BaseReferenceViewModel> ContactStatusTypes { get; set; }
        public bool IsLoading { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            _logger = Logger;

            IsLoading = true;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
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

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~CaseSummaryBase()
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
        /// <returns></returns>
        public async Task GetContactStatusTypes(LoadDataArgs args)
        {
            try
            {
                ContactStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakContactStatus, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    ContactStatusTypes = ContactStatusTypes.Where(c =>
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

        #region Search Contact Name Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchContactNameClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<SearchFarm>(
                    Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalSearchPersonHeading),
                    new Dictionary<string, object> {{"Mode", SearchModeEnum.Select}},
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result != null)
                    if (result is FarmViewModel record)
                    {
                        if (record.FarmOwnerID != null) Model.HumanMasterID = (long) record.FarmOwnerID;
                        Model.ContactName = record.FarmOwnerName;
                    }
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
        public void OnSaveClick()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.CaseContactID)
            {
                case 0:
                {
                    Model.CaseContactID = (Case.Contacts.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                }
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.ContactStatusID =
                (ContactStatusTypeDropDown.SelectedItem as BaseReferenceViewModel)?.IdfsBaseReference;

            Model.PlaceOfLastContact = PlaceOfLastContact.Value;
            Model.Comment = IsNullOrEmpty(ContactCommentsTextArea.Value) ? null : ContactCommentsTextArea.Value;

            DiagService.Close(Form.EditContext.Model);
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