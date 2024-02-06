using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{
    public class ActiveSurveillanceSessionStateContainer
    {



        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;
        //public event Action<string> OnChange;


        public ActiveSurveillanceSessionViewModel Model { get; set; }


        

        public void SetActiveSurveillanceSessionViewModel(ActiveSurveillanceSessionViewModel model)
        {
            Model = model;
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

        private ActiveSurveillanceSessionTestsResponseModel testsDetails;

        public ActiveSurveillanceSessionTestsResponseModel TestsDetails
        {
            get => testsDetails;
            set
            {
                testsDetails = value;
                //NotifyStateChanged("TestsDetails");
                NotifyStateChanged();
            }
        }

        private void NotifyStateChanged() => OnChange?.Invoke();

        //private void NotifyStateChanged(string property) => OnChange?.Invoke(property);
    }
}
