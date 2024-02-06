namespace EIDSS.Domain.ResponseModels.CrossCutting
{
    public class BaseReferenceAdvancedListResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? idfsBaseReference { get; set; }
        public string strName { get; set; }
        public int? intOrder { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
