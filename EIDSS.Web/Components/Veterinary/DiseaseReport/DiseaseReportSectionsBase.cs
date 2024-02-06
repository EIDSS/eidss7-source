#region Usings

using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.JSInterop;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class DiseaseReportSectionsBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public CaseGetDetailViewModel Case { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

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
                authenticatedUser = _tokenService.GetAuthenticatedUser();

                _userPermissions = GetUserPermissions(Model.OutbreakCaseIndicator
                    ? PagePermission.AccessToOutbreakVeterinaryCaseData
                    : PagePermission.AccessToVeterinaryDiseaseReportsData);

                if (Model.OutbreakCaseIndicator)
                {
                    var deletePermissionIndicator = _userPermissions.Delete && Model.DiseaseReportID > 0;

                    await JsRuntime.InvokeAsync<string>("initializeCaseSidebar", _token,
                            Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                            Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                            Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                            Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                            Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                            Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                            deletePermissionIndicator,
                            Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                                .ToString(),
                            Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString())
                        .ConfigureAwait(false);

                    if (Model.ReportCategoryTypeID == 0 && Case.Session.txtAvianCaseMonitoringDuration is null &&
                        Case.Session.txtLivestockCaseMonitoringDuration is null)
                    {
                        const int caseMonitoringStep = 6;
                        await JsRuntime.InvokeAsync<string>("hideCaseDiseaseReportStep", _token, caseMonitoringStep)
                            .ConfigureAwait(false);

                        if (Model.ReportViewModeIndicator || Model.ShowReviewSectionIndicator)
                        {
                            const int reviewStep = 10;
                            await JsRuntime.InvokeAsync<string>("navigateToCaseReviewStep", _token, reviewStep)
                                .ConfigureAwait(false);
                        }
                    }
                    else
                    {
                        if (Model.ReportViewModeIndicator || Model.ShowReviewSectionIndicator)
                        {
                            const int reviewStep = 11;
                            await JsRuntime.InvokeAsync<string>("navigateToCaseReviewStep", _token, reviewStep)
                                .ConfigureAwait(false);
                        }
                    }
                }
                else
                {
                    var deletePermissionIndicator = Model.DeletePermissionIndicator && Model.DiseaseReportID > 0;
                    var enableFinishButtonIndicator = _userPermissions.Create && Model.DiseaseReportID <= 0 ||
                                                      Model.WritePermissionIndicator && Model.DiseaseReportID > 0;

                    await JsRuntime.InvokeAsync<string>("initializeReportSidebar", _token,
                        Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                        enableFinishButtonIndicator,
                        deletePermissionIndicator,
                        Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                            .ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                    if (Model.ReportViewModeIndicator || Model.ShowReviewSectionIndicator)
                    {
                        var reviewStep = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian ? 10 : 12;
                        await JsRuntime.InvokeAsync<string>("navigateToReviewStep", _token, reviewStep)
                            .ConfigureAwait(false);
                    }
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~DiseaseReportSectionBase()
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

        #endregion
    }
}