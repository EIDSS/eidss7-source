using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Administration
{
    public class SearchStatisticalDataViewModel
    {
        private EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel _locationViewModel;
       
        public long ? selectedStatisticalDataItem { get; set; }

        public SearchDetails SearchDetails { get; set; }

        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel LocationViewModel { get { return _locationViewModel; } set { _locationViewModel = value; } }

        public List<StatisticalDataResponseModel> StatisticalDataResults { get; set; }
        public SearchStatisticalDataViewModel()
        {
            _locationViewModel = new Domain.ViewModels.CrossCutting.LocationViewModel();
        }
    }

    public class SearchDetails
    {


    }
}
