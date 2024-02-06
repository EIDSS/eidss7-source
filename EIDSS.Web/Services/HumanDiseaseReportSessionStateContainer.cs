using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{
    public class HumanDiseaseReportSessionStateContainer
    {



        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;


        public DiseaseReportSamplePageViewModel Model { get; set; }

        public DiseaseReportTestPageViewModel TestModel { get; set; }

        

        public void SetHumanDiseaseReportSampleSessionStateViewModel(DiseaseReportSamplePageViewModel model)
        {
            Model = model;
            NotifyStateChanged();
        }

        public void SetHumanDiseaseReportTestSessionStateViewModel(DiseaseReportTestPageViewModel model)
        {
            TestModel = model;
            NotifyStateChanged();
        }
        //public string Property
        //{
        //    get => savedString;
        //    set
        //    {
        //        savedString = value;
        //        NotifyStateChanged();
        //    }
        //}


        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
