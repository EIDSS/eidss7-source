using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class DiseasesGetRequestModel : BaseGetRequestModel
    {
        public Nullable<long> AccessoryCode { get; set; }

        [MapToParameter("search")]
        public string SimpleSearch { get; set; }
        public string AdvancedSearch { get; set; }
        public long UserEmployeeID { get; set; }
    }
}
