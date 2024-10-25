using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SettlementTypeSaveRequestModel //: BaseReferenceEditorRequestModel    
    {        
        public long? IdfsGISBaseReference { get; set; }        
        public string LangID { get; set; }        
        public string StrDefault { get; set; }        
        public string StrNationalName { get; set; }        
        public int? IntOrder { get; set; }
        public int RowStatus { get; set; }
        public string UserID { get; set; }    
    }
}
