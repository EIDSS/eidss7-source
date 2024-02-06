using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class FilteredDiseaseRequestModel 
    {
        public string LanguageId { get; set; }

        public int? AccessoryCode { get; set; }

        public long? UsingType { get; set; }

        public string AdvancedSearchTerm { get; set; }

        public long UserEmployeeID { get; set; }
    }
}