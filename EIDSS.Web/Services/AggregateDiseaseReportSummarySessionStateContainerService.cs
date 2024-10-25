using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Services
{
    public class AggregateDiseaseReportSummarySessionStateContainerService
    {
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;

        public IList<AggregateReportGetListViewModel> Reports { get; set; }
        public IList<AggregateReportGetListViewModel> SelectedReports { get; set; }
        public IList<AggregateReportGetListViewModel> SearchReports { get; set; }

        #endregion

        #region Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged() => OnChange?.Invoke();

        #endregion
    }
}
