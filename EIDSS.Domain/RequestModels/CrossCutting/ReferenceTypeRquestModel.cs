using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class ReferenceTypeRquestModel : BaseGetRequestModel
    {
        public string ?  advancedSearch { get; set; }
    }

    public class ReferenceTypeByIdRequestModel 
    {
        public string ReferenceTypeIds { get; set; }
        public string LanguageId { get; set; }
        public int ? IntHACode { get; set; }
        public int PaginationSet { get; set; }
        public int PageSize { get; set; }
        public int MaxPagesPerFetch { get; set; }
        public string Term { get; set; }

    }
}
