using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Vector
{
    public class VectorSampleGetListViewModel : BaseModel
    {
        public VectorSampleGetListViewModel ShallowCopy()
        {
            return (VectorSampleGetListViewModel)MemberwiseClone();
        }

        public long? VectorID { get; set; }
        public long? VectorTypeID { get; set; }
        public long? VectorSubTypeID { get; set; }
        public long SampleID { get; set; }
        public long? RootSampleID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public DateTime? FieldCollectionDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganizationName { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public string CollectedByOrganizationName { get; set; }
        public DateTime? SentDate { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string Comments { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public string AccessionConditionTypeName { get; set; }
        public string AccessionComment { get; set; }
        public long? CaseID { get; set; }
        public long? VectorSessionKey { get; set; }
        public string VectorTypeName { get; set; }
        public string VectorSubTypeName { get; set; }
        public int? Quantity { get; set; }
        public DateTime? CollectionDate { get; set; }
        public string SessionID { get; set; }
        public long SiteID { get; set; }
        public long? CurrentSiteID { get; set; }
        public bool AccessionedIndicator { get; set; }
        public string RecordAction { get; set; }
        public long? DiseaseID { get; set; }
        public string TestDiseaseName { get; set; }
        public long? ParentSampleID { get; set; }
        public DateTime? ResultDate { get; set; }
        public string TestResult { get; set; }
        public long? HumanID { get; set; }
        public long? HumanMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public string HumanName { get; set; }
        public string PersonAddress { get; set; }
        public long? SpeciesID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? CollectedByPersonID { get; set; }

        public long? MainTestID { get; set; }
        public string TestNameTypeName { get; set; }

        public string PatientOrFarmOwnerName { get; set; }
        public long? VectorSessionID { get; set; }
        public long? FreezerID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string SampleStatusTypeName { get; set; }

        public DateTime? DestructionDate { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? AccessionByPersonID { get; set; }

        public DateTime? SampleStatusDate { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}