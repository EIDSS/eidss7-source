#region Usings

using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

#endregion

namespace EIDSS.Web.Components.Veterinary.AggregateDiseaseReport
{
    public class AggregateDiseaseReportSectionsBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private ILogger<AggregateDiseaseReportSectionsBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public AggregateReportDetailsViewModel Model { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (Model.Permissions.Read)
                {
                    var dotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("VeterinaryAggregateDiseaseReport.SetDotNetReference", _token,
                        dotNetReference);

                    var enableSaveButton = Model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase is null
                        ? Model.Permissions.Create
                        : Model.Permissions.Write;

                    await JsRuntime.InvokeAsync<string>("VeterinaryAggregateDiseaseReport.initializeSidebar", _token,
                        Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                            .ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage).ToString(),
                        Model.Permissions.Delete,
                        enableSaveButton,
                        Model.StartIndex);

                    if (Model.StartIndex == 2)
                        await JsRuntime.InvokeVoidAsync("VeterinaryAggregateDiseaseReport.navigateToReviewStep",
                            _token);
                }
                else
                    await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
            }
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }
    }
}