using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels
{
    /// <summary>
    /// Model returned for typical save operations
    /// </summary>
    public class APISaveResponseModel : APIPostResponseModel
    {
        /// <summary>
        /// The Primary key identifier for the model and will be one of:
        /// AddressID
        /// idfsBaseReference
        /// IdfsCaseClassification
        /// IdfsDiagnosis
        /// IdfsBaseReference
        /// IdfsReportDiagnosisGroup
        /// IdfsSampleType
        /// idfSpeciesType
        /// IdfsStatisticDataType
        /// OrganizationKey
        /// SystemPreferenceID
        /// IdfsVectorSubType
        /// idfsVectorType
        /// idfDerivativeForSampleType
        /// idfSpeciesTypeToAnimalAge
        /// </summary>
        [Required]
        public long KeyId { get; set; }

        public string KeyIdName { get; set; }

        public long? AdditionalKeyId { get; set; }

        public string AdditionalKeyName { get; set; }
        public string strClientPageMessage { get; set; }
        public PageActions PageAction { get; set; }
        public string StrDuplicatedField { get; set; }

    }
}
