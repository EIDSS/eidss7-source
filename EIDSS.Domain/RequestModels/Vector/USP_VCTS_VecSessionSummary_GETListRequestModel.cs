﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
   public class USP_VCTS_VecSessionSummary_GETListRequestModel
    {
        public long? idfVectorSurveillanceSession { get; set; }
        public string LangID { get; set; }
    }
}