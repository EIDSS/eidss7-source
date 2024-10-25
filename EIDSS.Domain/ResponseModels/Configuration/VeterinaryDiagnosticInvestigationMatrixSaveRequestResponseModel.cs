using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class VeterinaryDiagnosticInvestigationMatrixSaveRequestResponseModel
    {
        public long? tidfVersion { get; set; }
        public long? tidfsDiagnosis { get; set; }
        public long? tidfsSpeciesType { get; set; }
        public long? tidfsDiagnosticAction { get; set; }
        public int? tintNumRow { get; set; }

    }
}
