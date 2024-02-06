using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class GroupAccessionInGetRequestModel : BaseGetRequestModel
    {
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
    }
}
