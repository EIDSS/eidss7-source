#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Shared;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class FarmDetailsSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmDetailsSectionBase> Logger { get; set; }
        [Inject] protected new ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<DiseaseReportGetDetailViewModel> Form { get; set; }
        protected LocationView FarmLocation { get; set; }
        public string FarmIdFieldLabelResourceKey { get; set; }
        public string FarmNameFieldLabelResourceKey { get; set; }
        public string FarmOwnerIdFieldLabelResourceKey { get; set; }
        public string FarmOwnerLastNameFieldLabelResourceKey { get; set; }
        public string FarmOwnerFirstNameFieldLabelResourceKey { get; set; }
        public string FarmOwnerSecondNameFieldLabelResourceKey { get; set; }
        public string PhoneFieldLabelResourceKey { get; set; }
        public string EmailFieldLabelResourceKey { get; set; }

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
        public FarmDetailsSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected FarmDetailsSectionBase() : base(CancellationToken.None)
        {
        }

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

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                FarmIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsFarmIDFieldLabel;
                FarmNameFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsFarmNameFieldLabel;
                FarmOwnerIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsFarmOwnerIDFieldLabel;
                FarmOwnerLastNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportFarmDetailsFarmOwnerLastNameFieldLabel;
                FarmOwnerFirstNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportFarmDetailsFarmOwnerFirstNameFieldLabel;
                FarmOwnerSecondNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel;
                PhoneFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsPhoneFieldLabel;
                EmailFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportFarmDetailsEmailFieldLabel;
            }
            else
            {
                FarmIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportFarmDetailsFarmIDFieldLabel;
                FarmNameFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportFarmDetailsFarmNameFieldLabel;
                FarmOwnerIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmDetailsFarmOwnerIDFieldLabel;
                FarmOwnerLastNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmDetailsFarmOwnerLastNameFieldLabel;
                FarmOwnerFirstNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmDetailsFarmOwnerFirstNameFieldLabel;
                FarmOwnerSecondNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel;
                PhoneFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportFarmDetailsPhoneFieldLabel;
                EmailFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportFarmDetailsEmailFieldLabel;
            }

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
                await JsRuntime.InvokeVoidAsync("FarmDetailsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));

                SetFarmLocation(Model);

                await InvokeAsync(StateHasChanged);
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

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            Model.FarmDetailsSectionValidIndicator = Form.EditContext.Validate();
            Model.FarmDetailsSectionModifiedIndicator = Form.EditContext.IsModified();

            return Model.FarmDetailsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        [JSInvokable]
        public async Task ReloadSection(bool isReview)
        {
            await InvokeAsync(StateHasChanged);

            Model.ReportDisabledIndicator = Model.ReportStatusTypeID == (long)DiseaseReportStatusTypeEnum.Closed && Model.ReportCurrentlyClosedIndicator || isReview || (Model.OutbreakID != null && !Model.OutbreakCaseIndicator);
            if (isReview)
            {
                Model.FarmLocation.EnabledLatitude = false;
                Model.FarmLocation.EnabledLongitude = false;
            }
            else
            {
                Model.FarmAddressLatitude =  FarmLocation.LocationViewModel.Latitude;
                Model.FarmAddressLongitude = FarmLocation.LocationViewModel.Longitude;
                SetFarmLocation(Model);
            }
        }

        #endregion

        #endregion
    }
}