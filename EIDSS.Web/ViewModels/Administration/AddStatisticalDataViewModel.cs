using System;

namespace EIDSS.Web.ViewModels.Administration
{
    public class AddStatisticalDataViewModel
    {
        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;

        public long? idfStatistic { get; set; }
        public long? selectedStatisticalDataItem { get; set; }
        public long? selectedParameter { get; set; }
        public long? selectedAgeGroup { get; set; }
        public long? selectedPeriodType { get; set; }
        public long? selectedAreaType { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public string StatisticalPeriodType { get; set; }
        public string StatisticalAreaType{ get; set; }
        public long? varValue { get; set; }
        public string ParameterType { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }


        public AddStatisticalDataViewModel()
        {
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
        }
    }
}
