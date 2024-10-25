using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class AggregateDiseaseReportViewModel
    {


        public string SearchCaseID { get; set; }

        public long SearchTimeInterval { get; set; }

        public long SearchAdministrativeUnitTypeID { get; set; }

        public DateTime SearchStartDate { get; set; }

        public DateTime SearchEndDate { get; set; }

        public long SearchOrganizationId  { get; set; }

        public LocationViewModel SearchLocationViewModel { get; set; }

        public LocationViewModel FormLocationViewModel { get; set; }

        public List<BaseReferenceViewModel> SearchTimeIntervalList { get; set; }

        public List<BaseReferenceViewModel> SearchAdministrativeUnitTypeList { get; set; }

        public List<GisLocationCurrentLevelModel> SearchOrganizationList { get; set; }

        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public long? AdminLevel2Value { get; set; }
        public long? HiddenAdminLevel3 { get; set; }
        public long? HiddenAdminLevel4 { get; set; }
        public long? HiddenAdminLevel5 { get; set; }
        public long? HiddenAdminLevel6 { get; set; }



    }
}
