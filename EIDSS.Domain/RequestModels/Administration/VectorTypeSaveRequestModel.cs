﻿using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VectorTypeSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("idfsVectorType")]
        public long? VectorTypeId { get; set; }
        public bool DeleteAnyway { get; set; }
        //[MapToParameter("strDefault")]
        //public string Default { get; set; }
        
       // [MapToParameter("strName")]
        //public string Name { get; set; }
        
        [MapToParameter("strCode")]
        public string Code { get; set; }
        
        [MapToParameter("bitCollectionByPool")]
        public bool? CollectionByPool { get; set; }
        
      //  [MapToParameter("intOrder")]
       // public int? Order { get; set; }        
        
       // [MapToParameter("LangID")]
        //public string LanguageId { get; set; }

    }
}
