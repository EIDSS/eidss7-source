using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Services;
using System.Threading;

namespace EIDSS.Web.Components.Human.HumanAggregateDiseaseReportSummary
{
    public class HumanAggregateDiseaseReportSummaryBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected AggregateDiseaseReportSummarySessionStateContainerService AggregateDiseaseReportSummaryService { get; set; }
        //[Inject]
        //protected ICrossCuttingClient CrossCuttingClient { get; set; }
        //[Inject]
        //protected ITestNameTestResultsMatrixClient TestNameTestResultsMatrixClient { get; set; }
        //[Inject]
        //protected ILaboratoryClient LaboratoryClient { get; set; }

        #endregion

        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion
        #endregion
    }
}
