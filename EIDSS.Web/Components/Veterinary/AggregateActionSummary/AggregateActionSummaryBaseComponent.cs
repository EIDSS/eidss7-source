using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;

namespace EIDSS.Web.Components.Veterinary.AggregateActionSummary
{
    public class AggregateActionSummaryBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected AggregateDiseaseReportSummarySessionStateContainerService AggregateActionSummaryService { get; set; }

        #endregion

        #endregion
    }
}