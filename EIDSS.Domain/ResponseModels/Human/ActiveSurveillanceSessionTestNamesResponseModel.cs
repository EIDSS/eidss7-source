﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionTestNamesResponseModel
    {
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public string TestCategoryTypeName { get; set; }
        public long DiseaseID { get; set; }
    }
}