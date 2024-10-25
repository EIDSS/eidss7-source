using System;
using System.Collections.Generic;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionDetailedInformationResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? ID { get; set; }
        public long? HumanMasterID { get; set; }
        public long? PersonID { get; set; }
        public string EIDSSPersonID { get; set; }
        public string PersonName { get; set; }
        public string PersonAddress { get; set; }
        public string FieldSampleID { get; set; }
        public string DiseaseIDs { get; set; }
        public string Disease { get; set; }
        public List<SampleToDiseaseGetListViewModel> SampleToDiseasesList { get; set; }
        public long? SampleID { get; set; }
        public long? idfsSampleType { get; set; }
        public string SampleType { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public string SentToOrganization { get; set; }
        public string Comment { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
        public int? RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; } = "I";
    }
}
