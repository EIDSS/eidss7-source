﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
	public class USP_VCTS_VSSESSION_GetDetailResponseModel
	{
        public long idfVectorSurveillanceSession { get; set; }
        public string strSessionID { get; set; }
        public string strVectors { get; set; }
        public string strVectorTypeIds { get; set; }
        public string strDiagnoses { get; set; }
        public string strDescription { get; set; }
        public string strFieldSessionID { get; set; }
        public string strVSStatus { get; set; }
        public long idfsVectorSurveillanceStatus { get; set; }
        public int? intCollectionEffort { get; set; }
        public long? idfsGeoLocationType { get; set; }
        public string strCountry { get; set; }
        public long? idfsCountry { get; set; }
        public string strRegion { get; set; }
        public long? idfsRegion { get; set; }
        public string strRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public string strSettlement { get; set; }
        public long? idfsRayon { get; set; }
        public double? dblLatitude { get; set; }
        public double? dblLongitude { get; set; }
        public DateTime datStartDate { get; set; }
        public DateTime? datCloseDate { get; set; }
        public long idfOutbreak { get; set; }
        public long? idfLocation { get; set; }
        public long? idfsSite { get; set; }
        public string strForeignAddress { get; set; }
        public long? idfsGroundType { get; set; }
        public double? dblDistance { get; set; }
        public string LocationDescription { get; set; }
        public string strOutbreakID { get; set; }
        public DateTime OutbreakStartDate { get; set; }
        public double? dblDirection { get; set; }
        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
    }
}