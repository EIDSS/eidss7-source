using EIDSS.Domain.Attributes;
using EIDSS.Localization.Helpers;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Human
{
    public class DiseaseReportTestDetailForDiseasesViewModel
    {
        public int RowID { get; set; }
        // public int ID { get; set; }

        public int RowAction { get; set; }

        public long NewRecordId { get; set; }
        public long? idfHumanCase { get; set; }
        public long idfMaterial { get; set; }
        public string strBarcode { get; set; }
        [Required]
        public string strFieldBarcode { get; set; }
        public long idfsSampleType { get; set; }
        public string strSampleTypeName { get; set; }

        [IsValidDate]
        public DateTime? datFieldCollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public long? idfFieldCollectedByOffice { get; set; }

        [IsValidDate]
        public DateTime? datFieldSentDate { get; set; }
        public long? idfsSampleStatus { get; set; }
        public string SampleStatusTypeName { get; set; }
        public long? idfFieldCollectedByPerson { get; set; }

        [IsValidDate]
        public DateTime? datSampleStatusDate { get; set; }
        public Guid sampleGuid { get; set; }
        public long? idfTesting { get; set; }
        public long? idfsTestName { get; set; }
        public long? idfsTestCategory { get; set; }
        public string strTestCategory { get; set; }
        public long? idfsTestResult { get; set; }
        public long? OriginalTestResultTypeId { get; set; }
        public long? idfsTestStatus { get; set; } = 10001001;
        public long? idfsDiagnosis { get; set; }
        public string strDiagnosis { get; set; }
        public string strTestStatus { get; set; } = "Final";
        public string strTestResult { get; set; }
        public DateTime? dtTestResultDate { get; set; }
        public string name { get; set; }

        [IsValidDate]
        public DateTime? datReceivedDate { get; set; }

        [IsValidDate]
        public DateTime? datConcludedDate { get; set; }
        public long? idfTestedByPerson { get; set; }
        public long? idfTestedByOffice { get; set; }

        [IsValidDate]
        public DateTime? datInterpretedDate { get; set; }
        public long? idfsInterpretedStatus { get; set; }

        public string strInterpretedStatus { get; set; }

        public string strInterpretedComment { get; set; }
        public string strInterpretedBy { get; set; }

        [IsValidDate]
        public DateTime? datValidationDate { get; set; }
        public bool blnValidateStatus { get; set; }
        public string strValidateComment { get; set; }
        public string strValidatedBy { get; set; }
        public Guid? testGuid { get; set; }
        public int? intRowStatus { get; set; }
        public string strTestedByPerson { get; set; }
        public string strTestedByOffice { get; set; }
        public bool blnNonLaboratoryTest { get; set; }
        public long? idfInterpretedByPerson { get; set; }
        public long? idfValidatedByPerson { get; set; }

        public bool? filterTestByDisease { get; set; } = false;

        public long? idfsYNTestsConducted { get; set; }

        public long? idfTestValidation { get; set; }


    }
}
