using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.Person
{
    public class PersonEmploymentSchoolViewModel
    {
        public DiseaseReportPersonalInformationViewModel PersonDetails { get; set; }
        //public Dictionary<string, string> IsThisPersonCurrentlyEmployed { get; set; }
        public List<BaseReferenceViewModel> OccupationTypeList { get; set; }
        public LocationViewModel WorkAddress { get; set; }
        //public Dictionary<string, string> IsThisPersonCurrentlyAttendSchool { get; set; }
        public LocationViewModel SchoolAddress { get; set; }
        public List<CountryModel> WorkCountryList { get; set; }
        public List<CountryModel> SchoolCountryList { get; set; }
        public DiseaseReportsViewModel DiseaseReports { get; set; }
        public OutbreakCaseReportsViewModel OutbreakCaseReports { get; set; }
        public long? EmployerForeignidfsCountry { get; set; }
        public long? SchoolForeignidfsCountry { get; set; }
        public bool ReportsVisibleIndicator { get; set; }
    }
}
