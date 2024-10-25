using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class DiseaseHumanGenderMatrixViewModel : BaseModel
    {
        public long DisgnosisGroupToGenderUID { get; set; }
        public long? DisgnosisGroupID { get; set; }
        public string strDiseaseGroupName { get; set; }
        public string GenderID { get; set; }
        public string strGender { get; set; }
    }
}
