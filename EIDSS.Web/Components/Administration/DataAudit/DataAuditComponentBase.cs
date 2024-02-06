using System;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.DataAudit;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.CodeAnalysis;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Administration.DataAudit
{
    public class DataAuditComponentBase : BaseComponent, IDisposable
    {
        #region Globals

        [Inject] private IDataAuditClient DataAuditClient { get; set; }

        [Inject] private ILogger<DataAuditComponentBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DataAuditTransactionLogGetListViewModel SelectedAuditRecord { get; set; }

        [Parameter] public TransactionLogDetailPageViewModel Model { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<DataAuditTransactionLogGetDetailViewModel> Grid;

        protected RadzenTemplateForm<TransactionLogDetailPageViewModel> Form;

        //protected TransactionLogDetailPageViewModel model;
        protected CancellationTokenSource Source;
        protected CancellationToken Token;
        protected bool IsLoading;
        protected int Count;

        #endregion

        #region Methods

        protected override void OnInitialized()
        {
            _logger = Logger;

            InitializeModel();

            //SetButtonStates();

            base.OnInitialized();
        }

        private void InitializeModel()
        {
            IsLoading = true;
            //var searchResults =await DataAuditClient.GetTransactionDetailRecords(SelectedAuditRecord.auditEventId, GetCurrentLanguage(), token);

            Model = new TransactionLogDetailPageViewModel
            {
                SelectedRecord = SelectedAuditRecord,
                Permissions = GetUserPermissions(PagePermission.CanRestoreDeletedRecords)
            };
            Model.SelectedRecord.StrSiteId = Model.SelectedRecord.siteId.ToString();
            Model.SelectedRecord.StrTransDate = Model.SelectedRecord.TransactionDate.ToString();
            Model.SelectedRecord.UserName =
                $"{Model.SelectedRecord.userFirstName} {Model.SelectedRecord.userFamilyName}";

            IsLoading = false;


            // count = model.SearchResults.Count;
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                IsLoading = true;
                Model.SearchResults =
                    await DataAuditClient.GetTransactionDetailRecords(SelectedAuditRecord.auditEventId,
                        GetCurrentLanguage(), Token);
                Count = Model.SearchResults.Count;
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
            finally
            {
                IsLoading = false;
                await InvokeAsync(StateHasChanged);
            }
        }

        protected bool DisableRestore()
        {
            var result = true;
            var canRestorePermission = GetUserPermissions(PagePermission.CanRestoreDeletedRecords);
            if (!canRestorePermission.Execute)
                return true;
            if (SelectedAuditRecord.actionTypeId != (long) DataUpdateTypeEnum.Delete)
                return true;
            //need to add base reference 
            switch (SelectedAuditRecord.ObjectTypeId)
            {
                case (long) DataAuditObjectTypeEnum.HumanActiveSurveillanceCampaign:
                case (long) DataAuditObjectTypeEnum.HumanActiveSurveillanceSession:
                case (long) DataAuditObjectTypeEnum.VetActiveSurveillanceCampaign:
                case (long) DataAuditObjectTypeEnum.VetActiveSurveillanceSessiion:
                case (long) DataAuditObjectTypeEnum.VectorSurveillanceSession:
                case (long) DataAuditObjectTypeEnum.AggregateHumanCase:
                case (long) DataAuditObjectTypeEnum.HumanCase:
                case (long) DataAuditObjectTypeEnum.ILIAggregateForm:
                case (long) DataAuditObjectTypeEnum.Outbreak:
                case (long) DataAuditObjectTypeEnum.VetAggregateCase:
                case (long) DataAuditObjectTypeEnum.VetAggregateAction:
                case (long) DataAuditObjectTypeEnum.VeterinaryCase:
                case (long) DataAuditObjectTypeEnum.WeeklyReportingForm:
                case (long) DataAuditObjectTypeEnum.Farm:
                case (long) DataAuditObjectTypeEnum.Organization:
                case (long) DataAuditObjectTypeEnum.DerivativesForSampleTypeMatrix:
                case (long) DataAuditObjectTypeEnum.Diagnosis:
                    
                    result = false;
                    break;
            }

            return result;
        }

        public async Task Restore(long dataAuditEventId)
        {
            var auditRestoreRequestModel = new AuditRestoreRequestModel
            {
                IdfDataAuditEvent = SelectedAuditRecord.auditEventId,
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                SiteId = Convert.ToInt64(authenticatedUser.SiteId)
            };
            var response = await DataAuditClient.Restore(auditRestoreRequestModel);

            if (response.ReturnCode is 0)
            {
                dynamic result;
                if (response.RecordStatus == 1)
                    result = await ShowSuccessDialog(
                        Localizer.GetString(MessageResourceKeyConstants
                            .DataAuditLogDetailsObjectsAreSuccessfullyRestoredMessage),
                        null, ButtonResourceKeyConstants.OKButton, null, null);
                else
                    result = await ShowSuccessDialog(
                        Localizer.GetString(MessageResourceKeyConstants
                            .DataAuditLogDetailsThisObjectCantBeRestoredMessage),
                        null, ButtonResourceKeyConstants.OKButton, null, null);
                if (result is DialogReturnResult) DiagService.Close();
            }
            else
            {
                throw new ApplicationException("Unable to save site alert subscription.");
            }
        }

        protected void Close()
        {
            DiagService.Close();
        }

        protected string GetTransDate(DateTime? transDate)
        {
            var culture = new CultureInfo(GetCurrentLanguage());
            if (transDate != null)
                return transDate.Value.ToString("g", culture);
            return transDate.Value.ToString(CultureInfo.InvariantCulture);
        }

        #endregion

        public void Dispose()
        {
        }
    }
}