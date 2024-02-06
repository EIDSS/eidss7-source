using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class ConfigurationMatrixViewModel : BaseModel
    {
        /// <summary>
        /// The Primary key identifier for the model and will be one of:
        /// idfSpeciesTypeToAnimalAge
        /// idfDerivativeForSampleType
        /// idfReportRows
        /// idfDiagnosisToDiagnosisGroup
        /// </summary>

        [Required]
        public long KeyId { get; set; }

        #region SpeciesAnimalAge

        public long idfsSpeciesType { get; set; }
        public string strSpeciesType { get; set; }
        public long idfsAnimalAge { get; set; }
        public string strAnimalType { get; set; }

        #endregion

        #region SampleTypeDerivativeMatrix

        public long idfsSampleType { get; set; }
        public string strSampleType { get; set; }
        public long idfsDerivativeType { get; set; }
        public string strDerivative { get; set; }

        #endregion

        #region CustomReportRowsMatrix

        public long idfsCustomReportType { get; set; }
        public string strCustomReportType { get; set; }
        public long idfsDiagnosisOrDiagnosisGroup { get; set; }
        public string strDiagnosisOrDiagnosisGroupName { get; set; }
        public string strDiseaseOrReportDiseaseGroup { get; set; }
        public long idfsUsingType { get; set; }
        public long idfsReportAdditionalText { get; set; }
        public string strAdditionalReportText { get; set; }
        public long idfsICDReportAdditionalText { get; set; }
        public string strICDReportAdditionalText { get; set; }
        public int intRowOrder { get; set; }

        #endregion

        #region DiseaseGroupDiseaseMatrix

        public long? idfsDiagnosisGroup { get; set; }
        public string strDefault { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDiseaseDefault { get; set; }
        public string strDiseaseName { get; set; }
        public string strHACodeNames { get; set; }
        public int? intOrder { get; set; }

        #endregion

        public string strUsingType { get; set; }
        public string KeyIdName { get; set; }


        #region VectorTypeFieldTestMatrix

        public string strVectorType { get; set; }
        public long idfsFieldTest { get; set; }
        public string strFieldTest { get; set; }

        public long idfPensideTestTypeForVectorType { get; set; }
        public long idfsVectorType { get; set; }
        public string strVectorTypeName { get; set; }
        public long idfsPensideTestName { get; set; }
        public string strPensideTestName { get; set; }

        #endregion
    }

}
