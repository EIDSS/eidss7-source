using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Administration
{

    public class BaseReferenceEditorsViewModel : BaseModel
    {
        /// <summary>
        /// The Primary key identifier for the model and will be one of:
        /// idfsAgeGroup
        /// idfsBaseReference
        /// idfsDiagnosis
        /// idfsReferenceType
        /// idfsReportDiagnosisGroup
        /// idfsSampleType
        /// idfsSpeciesType
        /// idfsStatisticDataType
        /// idfsVectorSubType
        /// </summary>
        [Required]
        public long KeyId { get; set; }
        public int IntLowerBoundary { get; init; }

        public int IntUpperBoundary { get; init; }

        public int idfsAgeType { get; init; }

        public string AgeTypeName { get; init; }



        #region AgeGroup

        #endregion

        #region BaseReference 
        public long IdfsReferenceType { get; set; }

        #endregion

        #region Case Classification

        public bool? blnInitialHumanCaseClassification { get; set; }
        public bool? blnFinalHumanCaseClassification { get; set; }

        #endregion

        #region Diseases

        public long IdfsUsingType { get; set; }
        public string StrIDC10 { get; set; }
        public string StrOIECode { get; set; }
        public string StrSampleType { get; set; }
        public string StrSampleTypeNames { get; set; }
        public string StrLabTest { get; set; }
        public string StrLabTestNames { get; set; }
        public string StrPensideTest { get; set; }
        public string StrPensideTestNames { get; set; }
        public string StrUsingType { get; set; }
        public bool BlnZoonotic { get; set; }
        public bool? BlnSyndrome { get; set; }
        public List<ActorGetListViewModel> Actors { get; set; }

        #endregion

        #region Measures

        public string StrReferenceTypeName { get; set; }
        public int IntStandard { get; set; }
        public long? IdfsCurrentReferenceType { get; set; }        
        public string StrActionCode { get; set; }

        #endregion

        #region SampleTypes 

        public string StrSampleCode { get; init; }
        public string StrParameterType { get; set; }
        public string LOINC_NUMBER { get; set; }

        #endregion

        #region Generic Statistical Types List
        public long IdfsStatisticDataType { get; init; }
        public bool blnStatisticalAgeGroup { get; set; }
        public long IdfsStatisticPeriodType { get; set; }
        public string StrStatisticPeriodType { get; set; }
        public long IdfsStatisticAreaType { get; set; }
        public string StrStatisticalAreaType { get; set; }
        #endregion

        #region VectorSpeciesTypes

        public long? IdfsVectorType { get; set; }
        public long? IdfsVectorSubTypeReferenceType { get; set; }
        public string VectorType { get; set; }

        #endregion

        #region VectorTypes
        public bool BitCollectionByPool { get; set; }

        public string StrCode { get; set; }

        #endregion

        [Required(ErrorMessage = "English Value is mandatory.")]
        public string StrDefault { get; set; }

        [Required(ErrorMessage = "Translated Value is mandatory.")]
        public string StrName { get; set; }

        public int IntHACode { get; set; }

        public string StrHACode { get; set; }

        public string StrHACodeNames { get; set; }
        public int IntRowStatus { get; set; }
        public int? IntOrder { get; set; }

        public string KeyIdName { get; set; }
        public string LOINC { get; set; }
        public long? EditorSettings { get; set; }
    }
}
