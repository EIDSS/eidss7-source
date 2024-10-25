using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class EmployeeLookupGetListViewModel : BaseModel
    {
        public long idfPerson { get; set; }
        public string FullName { get; set; }
        public string strFamilyName { get; set; }
        public string strFirstName { get; set; }
        public string Organization { get; set; }
        public long? idfOffice { get; set; }
        public string Position { get; set; }
        public int intRowStatus { get; set; }
        public int? intHACode { get; set; }
        public bool? blnHuman { get; set; }
        public bool? blnVet { get; set; }
        public bool? blnLivestock { get; set; }
        public bool? blnAvian { get; set; }
        public bool? blnVector { get; set; }
        public bool? blnSyndromic { get; set; }
    }
}