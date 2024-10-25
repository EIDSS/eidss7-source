using EIDSS.Web.ViewModels.Human;
using System;

namespace EIDSS.Web.Services
{
    public class HumanDiseaseReportSessionStateContainer
    {
        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;

        public DiseaseReportSamplePageViewModel SampleModel { get; set; }

        public DiseaseReportTestPageViewModel TestModel { get; set; }

        public DiseaseReportNotificationPageViewModel NotificationModel { get; set; }


        public void SetHumanDiseaseReportSampleSessionStateViewModel(DiseaseReportSamplePageViewModel model)
        {
            SampleModel = model;
            NotifyStateChanged();
        }

        public void SetHumanDiseaseReportTestSessionStateViewModel(DiseaseReportTestPageViewModel model)
        {
            TestModel = model;
            NotifyStateChanged();
        }

        public void SetDiseaseReportNotificationPageViewModel(DiseaseReportNotificationPageViewModel model)
        {
            NotificationModel = model;
            NotifyStateChanged();
        }

        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
