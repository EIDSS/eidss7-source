using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    public class WHOExportRequestModel
    {
        public string LangID { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanExporttoCISIDDateFromFieldLabel))]
        public DateTime? DateFrom { get; set; }
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanExporttoCISIDDateToFieldLabel))]
        public DateTime? DateTo { get; set; }
        [LocalizedRequired]
        public long DiseaseID { get; set; }
    }
}
