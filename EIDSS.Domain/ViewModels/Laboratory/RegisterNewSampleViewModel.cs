using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using System;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class RegisterNewSampleViewModel : BaseModel
    {
        private long? sampleCategoryTypeID;
        public long? SampleCategoryTypeID
        {
            get
            {
                if (sampleCategoryTypeID is null)
                {
                    ReportOrSessionTypeIDDisabledIndicator = true;
                    EIDSSReportOrSessionIDDisabledIndicator = true;
                    PatientFarmOrFarmOwnerNameDisabledIndicator = true;
                    PatientFarmOrFarmOwnerName = string.Empty;
                    SpeciesTypeIDDisabledIndicator = true;
                    SampleTypeIDDisabledIndicator = true;
                    DiseaseIDDisabledIndicator = true;
                }
                else
                {
                    PatientFarmOrFarmOwnerNameDisabledIndicator = false;
                    PatientFarmOrFarmOwnerNameRequiredIndicator = true;
                    ReportOrSessionTypeIDDisabledIndicator = false;

                    if (ReportOrSessionTypeID is null)
                        EIDSSReportOrSessionIDRequiredIndicator = false;

                    SampleTypeIDDisabledIndicator = false;
                    switch (sampleCategoryTypeID)
                    {
                        case (long)CaseTypeEnum.Human:
                            SpeciesTypeIDDisabledIndicator = true;
                            SpeciesTypeRequiredIndicator = false;
                            SpeciesTypeID = null;
                            break;
                        case (long)CaseTypeEnum.Avian:
                        case (long)CaseTypeEnum.Livestock:
                            SpeciesTypeIDDisabledIndicator = false;
                            SpeciesTypeRequiredIndicator = true;
                            break;
                        case (long)CaseTypeEnum.Vector:
                            ReportOrSessionTypeID = (long)ReportOrSessionTypeEnum.VectorSurveillanceSession;
                            EIDSSReportOrSessionIDRequiredIndicator = true;
                            PatientFarmOrFarmOwnerID = null;
                            PatientFarmOrFarmOwnerName = null;
                            PatientFarmOrFarmOwnerNameDisabledIndicator = true;
                            PatientFarmOrFarmOwnerNameRequiredIndicator = false;
                            SpeciesTypeIDDisabledIndicator = false;
                            SpeciesTypeRequiredIndicator = true;
                            break;
                        default:
                            EIDSSReportOrSessionID = null;
                            EIDSSReportOrSessionIDDisabledIndicator = true;
                            EIDSSReportOrSessionIDRequiredIndicator = false;
                            break;
                    }
                }

                return sampleCategoryTypeID;
            }
            set
            {
                sampleCategoryTypeID = value;

                if (sampleCategoryTypeID is null)
                {
                    ReportOrSessionTypeIDDisabledIndicator = true;
                    EIDSSReportOrSessionIDDisabledIndicator = true;
                    PatientFarmOrFarmOwnerNameDisabledIndicator = true;
                    PatientFarmOrFarmOwnerName = string.Empty;
                    SpeciesTypeIDDisabledIndicator = true;
                    SpeciesTypeRequiredIndicator = false;
                    SampleTypeIDDisabledIndicator = true;
                    DiseaseIDDisabledIndicator = true;
                }
                else
                {
                    PatientFarmOrFarmOwnerNameDisabledIndicator = false;
                    PatientFarmOrFarmOwnerNameRequiredIndicator = true;
                    ReportOrSessionTypeIDDisabledIndicator = false;

                    if (ReportOrSessionTypeID is null)
                        EIDSSReportOrSessionIDRequiredIndicator = false;

                    switch (sampleCategoryTypeID)
                    {
                        case (long)CaseTypeEnum.Human:
                            SpeciesTypeIDDisabledIndicator = true;
                            SpeciesTypeRequiredIndicator = false;
                            SpeciesTypeID = null;
                            break;
                        case (long)CaseTypeEnum.Avian:
                        case (long)CaseTypeEnum.Livestock:
                            SpeciesTypeIDDisabledIndicator = false;
                            SpeciesTypeRequiredIndicator = true;
                            break;
                        case (long)CaseTypeEnum.Vector:
                            ReportOrSessionTypeID = (long)ReportOrSessionTypeEnum.VectorSurveillanceSession;
                            EIDSSReportOrSessionIDRequiredIndicator = true;
                            PatientFarmOrFarmOwnerID = null;
                            PatientFarmOrFarmOwnerName = null;
                            PatientFarmOrFarmOwnerNameDisabledIndicator = true;
                            PatientFarmOrFarmOwnerNameRequiredIndicator = false;
                            SpeciesTypeRequiredIndicator = true;
                            break;
                        default:
                            EIDSSReportOrSessionID = null;
                            EIDSSReportOrSessionIDDisabledIndicator = true;
                            EIDSSReportOrSessionIDRequiredIndicator = false;
                            break;
                    }
                }
            }
        }

        private long? reportOrSessionTypeID;
        public long? ReportOrSessionTypeID 
        {
            get
            {
                EIDSSReportOrSessionIDDisabledIndicator = reportOrSessionTypeID is null;

                return reportOrSessionTypeID;
            }
            set
            {
                reportOrSessionTypeID = value;

                EIDSSReportOrSessionIDDisabledIndicator = ReportOrSessionTypeID is null;
            }
        }

        public string ReportOrSessionTypeName { get; set; }
        public long? ActiveSurveillanceSessionID { get; set; }
        public long? VectorSurveillanceSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public string EIDSSReportOrSessionID { get; set; }
        public long? HumanMasterID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FarmID { get; set; }
        public long? PatientFarmOrFarmOwnerID { get; set; }
        public string PatientFarmOrFarmOwnerName { get; set; }

        private string patientSpeciesVectorInformation;
        public string PatientSpeciesVectorInformation 
        {
            get
            {
                DiseaseIDDisabledIndicator = patientSpeciesVectorInformation is null;

                return patientSpeciesVectorInformation;
            }
            set
            {
                patientSpeciesVectorInformation = value;

                DiseaseIDDisabledIndicator = patientSpeciesVectorInformation is null;
            }
        }

        public DateTime CollectionDate { get; set; }
        public long? SpeciesTypeID { get; set; }
        public long? SpeciesID { get; set; }
        public long? VectorTypeID { get; set; }
        public long? VectorID { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public int? NumberOfSamples { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public bool FavoriteIndicator { get; set; }
        public bool ReportOrSessionTypeIDDisabledIndicator { get; set; }
        public bool EIDSSReportOrSessionIDDisabledIndicator { get; set; }
        public bool EIDSSReportOrSessionIDRequiredIndicator { get; set; }
        public bool PatientFarmOrFarmOwnerNameDisabledIndicator { get; set; }
        public bool PatientFarmOrFarmOwnerNameRequiredIndicator { get; set; }
        public bool SpeciesTypeIDDisabledIndicator { get; set; }
        public bool SpeciesTypeRequiredIndicator { get; set; }
        public bool SampleTypeIDDisabledIndicator { get; set; }
        public bool DiseaseIDDisabledIndicator { get; set; }
        public bool NewRecordAddedIndicator { get; set; }
    }
}
