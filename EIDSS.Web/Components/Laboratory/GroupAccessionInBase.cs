#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
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
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class GroupAccessionInBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<GroupAccessionInBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        public IList<GroupAccessionInViewModel> GroupAccessionInIdentifiers { get; set; } =
            new List<GroupAccessionInViewModel>();

        public RadzenDataGrid<GroupAccessionInViewModel> GroupAccessionInGrid;
        public int Count;

        public GroupAccessionInGetRequestModel GroupAccessionIn { get; set; }
        public RadzenTemplateForm<GroupAccessionInGetRequestModel> Form { get; set; }

        public bool AllowAddIndicator { get; set; }
        public bool PrintBarcodesIndicator { get; set; }

        private List<SamplesGetListViewModel> SelectedSamples { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #region Constants

        private const string DialogWidth = "700px";
        private const string DialogHeight = "530px";
        private const string DefaultSortColumn = "PatientOrFarmOwnerName";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public GroupAccessionInBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected GroupAccessionInBase() : base(CancellationToken.None)
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

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            GroupAccessionIn = new GroupAccessionInGetRequestModel();

            base.OnInitialized();
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

        #region Local/Field SampleID Change Event

        /// <summary>
        /// </summary>
        protected void OnEIDSSLocalOrFieldSampleIDChange()
        {
            AllowAddIndicator = !IsNullOrEmpty(GroupAccessionIn.EIDSSLocalOrFieldSampleID);
        }

        #endregion

        #region Add Group Accession Identifier Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddGroupAccessionInIdentifier()
        {
            try
            {
                GroupAccessionInIdentifiers.Add(new GroupAccessionInViewModel
                    {EIDSSLocalOrFieldSampleID = GroupAccessionIn.EIDSSLocalOrFieldSampleID});

                GroupAccessionIn.EIDSSLocalOrFieldSampleID = Empty;

                await GroupAccessionInGrid.Reload();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Accession In Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAccessionInClick()
        {
            try
            {
                const string sortOrder = SortConstants.Ascending;
                var groupAccessionInIdentifiers = Empty;

                foreach (var identifier in GroupAccessionInIdentifiers)
                {
                    if (!IsNullOrEmpty(groupAccessionInIdentifiers))
                        groupAccessionInIdentifiers += ",";
                    groupAccessionInIdentifiers += identifier.EIDSSLocalOrFieldSampleID;
                }

                var request = new GroupAccessionInSearchGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = DefaultSortColumn,
                    SortOrder = sortOrder,
                    EIDSSLocalOrFieldSampleIDList = groupAccessionInIdentifiers,
                    SentToOrganizationID = authenticatedUser.OfficeId,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };

                SelectedSamples = await LaboratoryClient.GetSamplesGroupAccessionInSearchList(request, _token);

                Count = !SelectedSamples.Any() ? 0 : SelectedSamples.First().TotalRowCount;

                var showSampleSectionDialogIndicator = false;

                foreach (var identifier in GroupAccessionInIdentifiers)
                {
                    if (SelectedSamples.All(x => x.EIDSSLocalOrFieldSampleID != identifier.EIDSSLocalOrFieldSampleID))
                    {
                        await ShowErrorDialog(null, Format(Localizer.GetString(MessageResourceKeyConstants
                            .GroupAccessionInModalLocalOrFieldSampleIDDoesNotExistMessage), identifier.EIDSSLocalOrFieldSampleID));
                    } else if (SelectedSamples.Any(x => x.EIDSSLocalOrFieldSampleID == identifier.EIDSSLocalOrFieldSampleID && 
                               (x.AccessionConditionTypeID is not null || x.SampleStatusTypeID is not null)))
                    {
                        await ShowErrorDialog(null, Format(Localizer.GetString(MessageResourceKeyConstants
                            .GroupAccessionInModalLocalOrFieldSampleIDIsAlreadyAccessionedMessage), SelectedSamples.First(x =>
                            x.EIDSSLocalOrFieldSampleID == identifier.EIDSSLocalOrFieldSampleID).EIDSSLocalOrFieldSampleID));

                        if (SelectedSamples.Any(x =>
                                x.EIDSSLocalOrFieldSampleID == identifier.EIDSSLocalOrFieldSampleID &&
                                (x.AccessionConditionTypeID is not null || x.SampleStatusTypeID is not null)))
                        {
                            SelectedSamples.RemoveAll(x =>
                                x.EIDSSLocalOrFieldSampleID == identifier.EIDSSLocalOrFieldSampleID &&
                                (x.AccessionConditionTypeID is not null || x.SampleStatusTypeID is not null));
                        }
                    }

                    if (SelectedSamples.Count(x =>
                            x.EIDSSLocalOrFieldSampleID == identifier.EIDSSLocalOrFieldSampleID) > 1)
                    {
                        showSampleSectionDialogIndicator = true;
                    }
                }

                if (showSampleSectionDialogIndicator)
                {
                    await ShowSelectSamplesDialog();

                    DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Accession});
                }
                else
                {
                    if (SelectedSamples.Any())
                    {
                        IList<LaboratorySelectionViewModel> records = SelectedSamples
                            .Select(sample => new LaboratorySelectionViewModel {SampleID = sample.SampleID}).ToList();

                        var sampleIdentifiers = await AccessionIn(records,
                            (long) AccessionConditionTypeEnum.AcceptedInGoodCondition,
                            LaboratoryService.AccessionConditionTypes.First(x =>
                                x.IdfsBaseReference == (long) AccessionConditionTypeEnum.AcceptedInGoodCondition).Name);

                        if (PrintBarcodesIndicator)
                        {
                            LaboratoryService.PrintBarcodeSamples = sampleIdentifiers.Aggregate(Empty,
                                (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                            if (LaboratoryService.PrintBarcodeSamples != null)
                                LaboratoryService.PrintBarcodeSamples =
                                    LaboratoryService.PrintBarcodeSamples.Remove(
                                        LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                        }
                    }

                    DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Accession});
                }
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
                StateHasChanged();

                var result =
                    await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                        .ConfigureAwait(false);

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

        #region Show Accession Dialog

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task ShowSelectSamplesDialog()
        {
            var result = await DiagService.OpenAsync<SelectSamples>(
                Localizer.GetString(HeadingResourceKeyConstants.GroupAccessionInModalSelectSamplesHeading),
                new Dictionary<string, object> {{"Samples", SelectedSamples}},
                new DialogOptions {Width = DialogWidth, Height = DialogHeight, Resizable = true, Draggable = false});

            if (result == null)
                return;

            if (result is List<SampleIDsGetListViewModel> list)
            {
                if (list.Any())
                {
                    if (PrintBarcodesIndicator)
                    {
                        LaboratoryService.PrintBarcodeSamples = list.Aggregate(
                            Empty,
                            (current, s) => current + (s.EIDSSLaboratorySampleID + ','));

                        if (LaboratoryService.PrintBarcodeSamples != null)
                            LaboratoryService.PrintBarcodeSamples =
                                LaboratoryService.PrintBarcodeSamples.Remove(
                                    LaboratoryService.PrintBarcodeSamples.Length - 1, 1);
                    }
                }

                DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Accession});
            }
        }

        #endregion

        #endregion
    }
}