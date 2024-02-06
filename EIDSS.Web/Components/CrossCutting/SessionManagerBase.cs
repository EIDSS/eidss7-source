#region Usings

using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.CrossCutting
{
    public class SessionManagerBase : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SessionManagerBase> Logger { get; set; }
        [Inject] private ProtectedSessionStorage SessionStorage { get; set; }

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

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
                // lab search
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.SamplesSearchString);
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.TestingSearchString);
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.TransferredSearchString);
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.MyFavoritesSearchString);
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.BatchesSearchString);
                await SessionStorage.DeleteAsync(LaboratorySearchStorageConstants.ApprovalsSearchString);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratorySamplesAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratorySamplesAdvancedSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTestingAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTestingAdvancedSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey);

                // farm search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.FarmSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.FarmSearchPerformedIndicatorKey);

                // person search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.PersonSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey);

                // human disease report search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.HumanDiseaseReportSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.HumanDiseaseReportSearchPerformedIndicatorKey);

                // veterinary disease report search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.AvianVeterinaryDiseaseReportSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.AvianVeterinaryDiseaseReportSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LivestockVeterinaryDiseaseReportSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.LivestockVeterinaryDiseaseReportSearchPerformedIndicatorKey);

                // veterinary surveillance session search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey);

                // veterinary aggregate actions search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchPerformedIndicatorKey);

                // vector surveillance session search
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey);

                // Human active  surveillance Campaign
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchModelKey);

                // Vet active  surveillance Campaign
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceCampaignSearchPerformedIndicatorKey);
                await SessionStorage.DeleteAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceCampaignSearchModelKey);

                await InvokeAsync(StateHasChanged);
            }
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
        }

        #endregion

        #endregion
    }
}
