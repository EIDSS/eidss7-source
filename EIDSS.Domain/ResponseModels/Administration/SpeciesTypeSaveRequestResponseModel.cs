using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class SpeciesTypeSaveRequestResponseModel : APIPostResponseModel
    {
        public long idfSpeciesType { get; set; }
    }
}
