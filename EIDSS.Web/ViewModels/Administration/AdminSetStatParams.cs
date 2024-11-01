﻿using System;

namespace EIDSS.Web.ViewModels.Administration
{
    public class AdminSetStatParams
    {
        public long? idfStatistic { get; set; }
        public long? idfsStatisticDataType { get; set; }
        public long? idfsMainBaseReference { get; set; }
        public long? idfsStatisticAreaType { get; set; }
        public long? idfsStatisticPeriodType { get; set; }
        public long? locationUserControlidfsCountry { get; set; }
        public long? locationUserControlidfsRegion { get; set; }
        public long? idfsUserControlidfsRayon { get; set; }
        public long? idfsUserControlidfsSettlement { get; set; }
        public DateTime datStatisticStartDate { get; set; }
        public DateTime? datStatisticFinishDate { get; set; }
        public string varValue { get; set; }
        public long? idfsStatisticalAgeGroup { get; set; }
        public long? idfsParameterName { get; set; }
    }
}
