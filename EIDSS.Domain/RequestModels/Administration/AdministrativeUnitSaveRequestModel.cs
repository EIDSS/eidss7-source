using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class AdministrativeUnitSaveRequestModel : BaseSaveRequestModel
    {
        public long IdfsParent { get; set; }
        public string StrHASC { get; set; }
        public string StrCode { get; set; }
        public long? IdfsLocation { get; set; }
        public string StrDefaultName { get; set; }
        public string StrNationalName { get; set; }
        public long? IdfsType { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public int? Elevation { get; set; }
        public int IntOrder { get; set; }
        

    }

}
