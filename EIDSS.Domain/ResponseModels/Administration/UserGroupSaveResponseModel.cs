﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class UserGroupSaveResponseModel : APIPostResponseModel
    {
        public long? idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
    }
}
