using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    public class VectorSurveillanceSessionSearchRequestModel : BaseGetRequestModel
    {
    
        public string SessionID{get;set;} 
        public string FieldSessionID{get;set;} 
        public long? StatusTypeID{get;set;} 
        public long? SelectedVectorTypeID {get;set;} 
        public string VectorTypeID { get; set; }
        public long? SpeciesTypeID{get;set;} 
        public long? DiseaseID{get;set;} 
        public string DiseaseGroupID{get;set;} 
        public long? AdministrativeLevelID{get;set;} 
        public DateTime? StartDateFrom{get;set;} 
        public DateTime? StartDateTo{get;set;} 
        public DateTime? EndDateFrom{get;set;} 
        public DateTime? EndDateTo{get;set;} 
        public long? OutbreakKey{get;set;} 
        public long? UserSiteID{get;set;} 
        public long? UserOrganizationID{get;set;} 
        public long? UserEmployeeID{get;set;} 
        public bool? ApplySiteFiltrationIndicator{get;set;} 
       
    }
}
