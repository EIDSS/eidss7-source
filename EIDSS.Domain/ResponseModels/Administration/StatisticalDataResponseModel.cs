using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class StatisticalDataResponseModel
    {
        public int? TotalRowCount { get; set; }
     
        public long idfStatistic { get; set; }
        public long idfsStatisticDataType { get; set; }
        public long? idfsStatisticAreaType { get; set; }
        public long? idfsStatisticalAgeGroup { get; set; }
        public string strStatisticalAgeGroup { get; set; }
        public string defDataTypeName { get; set; }
        public double? varValue { get; set; }
        public long? idfsMainBASeReference { get; set; }
        public long? idfsStatisticPeriodType { get; set; }
        public long idfsArea { get; set; }
        public string datStatisticStartDate { get; set; }
        public string setnDataTypeName { get; set; }
        public string ParameterType { get; set; }
        public long? idfsParameterType { get; set; }
        public string defParameterName { get; set; }
        public string setnParameterName { get; set; }
        public long? idfsParameterName { get; set; }
        public string defAreaTypeName { get; set; }
        public string setnAreaTypeName { get; set; }
        public string defPeriodTypeName { get; set; }
        public string setnPeriodTypeName { get; set; }
        public long? idfsCountry { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public string setnArea { get; set; }
        public DateTime? AuditCreateDTM { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
        public long? AdminLevel0Value { get; set; }
        public string AdminLevel0Text { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
        public long? AdminLevel4Value { get; set; }
        public string AdminLevel4Text { get; set; }
        public long? AdminLevel5Value { get; set; }
        public string AdminLevel5Text { get; set; }
        public long? AdminLevel6Value { get; set; }
        public string AdminLevel6Text { get; set; }
    }
}
