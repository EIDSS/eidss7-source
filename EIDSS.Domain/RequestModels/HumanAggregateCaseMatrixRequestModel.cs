using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Threading;

namespace EIDSS.Domain.RequestModels
{
    public class HumanAggregateCaseMatrixRequestModel : BaseSaveRequestModel
    {
        [MapToParameter("idfVersion")]
        public Nullable<long> VersionId { get; set; }
        
        [MapToParameter("idfsMatrixType")]
        public Nullable<long> MatrixTypeId { get; set; }
        
        [MapToParameter("datStartDate")]
        public Nullable<DateTime> StartDate { get; set; } 
        
        public string MatrixName { get; set; }

        [MapToParameter("blnIsActive")]
        public Nullable<bool> IsActive { get; set; }

        [MapToParameter("blnIsDefault")] 
        public Nullable<bool> IsDefault { get; set; }

        public long? EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }

        public CancellationToken cancellationToken { get; set; } = default;
    }
}
