#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
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

#endregion

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class DetailedCollectionCopyBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DetailedCollectionCopyBase> Logger { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<VectorSessionStateContainer> Form { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        private const string DIALOG_WIDTH = "700px";
        private const string DIALOG_HEIGHT = "775px";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        ///
        /// </summary>
        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            //reset the cancellation token
            _source = new();
            _token = _source.Token;

            base.OnInitialized();
        }

        /// <summary>
        ///
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            base.Dispose(disposing);
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected async Task OnSubmit()
        {
            if (Form.EditContext.Validate())
            {
                var request = new USP_VCTS_DetailedCollections_CopyRequestModel
                {
                    idfVector = VectorSessionStateContainer.DetailedCollectionIdfVector,
                    Samples = VectorSessionStateContainer.CopySamples,
                    Tests = VectorSessionStateContainer.CopyFieldTests
                };

                var response = await VectorClient.CopyDetailedCollectionAsync(request, _token);
                DiagService.Close(response);
            }
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                if (result is DialogReturnResult)
                {
                    if (result is DialogReturnResult)
                        if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                    DiagService.Close(null);
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