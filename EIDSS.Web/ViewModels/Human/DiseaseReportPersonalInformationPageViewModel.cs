using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportPersonalInformationPageViewModel
    {
        public DiseaseReportPersonalInformationViewModel PersonInfo { get; set; }

        public UserPermissions PermissionsAccessToPersonalData { get; set; }

        // Custom Fields
        public Select2Configruation PersonalIdTypeDD { get; set; }

        public Select2Configruation SchoolAddressCountryDD { get; set; }

        public Select2Configruation OccupationDD { get; set; }

        public Select2Configruation AgeTypeDD { get; set; }

        public LocationViewModel CurrentAddress { get; set; }

        public LocationViewModel WorkAddress { get; set; }

        public LocationViewModel SchoolAddress { get; set; }


    }
}
