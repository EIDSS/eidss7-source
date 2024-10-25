using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Services;
using System.Threading;

namespace EIDSS.Web.Components.Veterinary.AggregateDiseasesReportSummary
{
    public class AggregateDiseaseReportSummaryBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected AggregateDiseaseReportSummarySessionStateContainerService AggregateDiseaseReportSummaryService { get; set; }

        #endregion Dependencies

        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion Private Member Variables

        #endregion Globals
    }
}