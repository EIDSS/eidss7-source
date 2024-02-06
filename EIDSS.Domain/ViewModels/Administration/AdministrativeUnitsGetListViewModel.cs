using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AdministrativeUnitsGetListViewModel:BaseModel
    {
        public string NationalName { get; set; }
        public string DefaultName { get; set; }
        public long? idfsCountry { get; set; }
        public string strCountryHASC { get; set; }
        public string strCountryCode { get; set; }
        public string NationalCountryName { get; set; }
        public string DefaultCountryName { get; set; }
        public long? idfsRegion { get; set; }
        public string strRegionHASC { get; set; }
        public string strRegionCode { get; set; }
        public string NationalRegionName { get; set; }
        public string DefaultRegionName { get; set; }
        public long? idfsRayon { get; set; }
        public string strRayonHASC { get; set; }
        public string strRayonCode { get; set; }
        public string NationalRayonName { get; set; }
        public string DefaultRayonName { get; set; }
        public string idfsSettlement { get; set; }
        public string strSettlementHASC { get; set; }
        public string strSettlementCode { get; set; }
        public string NationalSettlementName { get; set; }
        public string DefaultSettlementName { get; set; }
        public long? idfsSettlementType { get; set; }
        public string SettlementTypeDefaultName { get; set; }
        public string SettlementTypeNationalName { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double? Elevation { get; set; }
        public string AdministrativeLevelValue { get; set; }
        public long? AdministrativeLevelId { get; set; }


    }
}
