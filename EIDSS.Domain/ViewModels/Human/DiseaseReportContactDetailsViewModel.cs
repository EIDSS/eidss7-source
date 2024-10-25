using System;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Domain.ViewModels.Human
{
    public class DiseaseReportContactDetailsViewModel
    {
        public int RowID { get; set; }
        public long idfContactedCasePerson { get; set; }
        public long? idfHumanCase { get; set; }
        public long idfHuman { get; set; }
        public long?  idfHumanActual { get; set; }
        public long? idfRootHuman { get; set; }
        public string strContactPersonFullName { get; set; }
        public long idfsPersonContactType { get; set; } = (long)PatientRelationshipTypeEnum.Other; 
        public string strPersonContactType { get; set; }
        public DateTime? datDateOfLastContact { get; set; }
        public string strPlaceInfo { get; set; }
        public string strComments { get; set; }
        public string strFirstName { get; set; }
        public string strSecondName { get; set; }
        public string strLastName { get; set; }
        public DateTime? datDateofBirth { get; set; }
        public long? idfsHumanGender { get; set; }
        public long? idfCitizenship { get; set; }
        public string strContactPhone { get; set; }
        public long? idfContactPhoneType { get; set; }
        public long? idfsCountry { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public string strStreetName { get; set; }
        public string strPostCode { get; set; }
        public string strBuilding { get; set; }
        public string strHouse { get; set; }
        public string strApartment { get; set; }
        public string strPatientInformation { get; set; }
        public string strPatientAddressString { get; set; }
        public byte? bitIsRootMain { get; set; }
        public Guid rowguid { get; set; }

        public long? idfContactPhoneTypeID { get; set; }

        public bool? blnForeignAddress { get; set; }
       // public bool? isForiegnAddress { get; set; } = false;
        public LocationViewModel LocationViewModel { get; set; }

       public int? Age { get; set; }

        public int RowAction { get; set; }

        public int RowStatus { get; set; } = 0;

        public long? AddressID { get; set; }
        
        //Outbreak
        public long TracingObservationID { get; set; }
    }
}
