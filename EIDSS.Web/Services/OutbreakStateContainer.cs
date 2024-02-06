using EIDSS.Web.Areas.Outbreak.ViewModels;
using System;

namespace EIDSS.Web.Services
{
    public class OutbreakStateContainer
    {
        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action OnChange;

        public HumanCaseViewModel Model { get; set; }

        public void SetActiveSurveillanceSessionViewModel(HumanCaseViewModel model)
        {
            Model = model;
            NotifyStateChanged();
        }

        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
