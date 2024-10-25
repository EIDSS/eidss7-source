#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
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

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class TransferOutBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<TransferOutBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IUserConfigurationService UserConfigurationService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        public TransferredGetListViewModel Transfer { get; set; }
        public RadzenTemplateForm<TransferredGetListViewModel> Form { get; set; }
        public IEnumerable<OrganizationAdvancedGetListViewModel> TransferredToOrganizations;

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
        public TransferOutBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected TransferOutBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            Transfer = new TransferredGetListViewModel
            {
                AllowDatesInThePast = UserConfigurationService.SystemPreferences.AllowPastDates,
                TransferDate = DateTime.Now,
                PrintBarcodeIndicator = true,
                SentByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                SentByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName,
                TransferredFromOrganizationID = authenticatedUser.OfficeId,
                TransferredFromOrganizationName = authenticatedUser.Organization,
                TransferredFromOrganizationSiteID = Convert.ToInt64(authenticatedUser.SiteId)
            };

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

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetTransferredToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                TransferredToOrganizations = list.AsODataEnumerable();

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
        public async Task OnSubmit()
        {
            try
            {
                if (Form.EditContext.Validate())
                {
                    IList<LaboratorySelectionViewModel> records = new List<LaboratorySelectionViewModel>();
                    LaboratoryService.SelectedSamples ??= new List<SamplesGetListViewModel>();
                    LaboratoryService.SelectedMyFavorites ??= new List<MyFavoritesGetListViewModel>();

                    // Does the organization use the EIDSS application?  If not, then set the external organization indicator to true.
                    // When this indicator is true, then a transferred out sample will not be created.
                    Transfer.ExternalOrganizationIndicator = TransferredToOrganizations
                        .First(x => x.idfOffice == Transfer.TransferredToOrganizationID).idfsSite == null;

                    Transfer.TransferredToOrganizationSiteID = TransferredToOrganizations
                        .First(x => x.idfOffice == Transfer.TransferredToOrganizationID).idfsSite;


                    switch (Tab)
                    {
                        case LaboratoryTabEnum.Samples:
                            foreach (var sample in LaboratoryService.SelectedSamples)
                            {
                                records.Add(new LaboratorySelectionViewModel
                                {
                                    SampleID = sample.SampleID, EIDSSLaboratorySampleID = sample.EIDSSLaboratorySampleID
                                });
                                Transfer.DiseaseID = sample.DiseaseID;
                            }
                            break;
                        case LaboratoryTabEnum.MyFavorites:
                            foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                            {
                                records.Add(new LaboratorySelectionViewModel
                                {
                                    SampleID = myFavorite.SampleID,
                                    EIDSSLaboratorySampleID = myFavorite.EIDSSLaboratorySampleID
                                });
                                Transfer.DiseaseID = myFavorite.DiseaseID;
                            }
                            break;
                    }

                    var transferList = await TransferOut(records, Transfer);

                    if (Transfer.PrintBarcodeIndicator)
                    {
                        await GenerateBarcodeReport(transferList);
                    }

                    DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Transfer});
                }
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
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form is null)
                    DiagService.Close();
                else if (Form.EditContext.IsModified())
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                            .ConfigureAwait(false);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                    DiagService.Close();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}