using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.Abstracts
{
    public abstract class BaseReferenceEditorRequestModel
    {
        [MapToParameter("LangID")]
        public string LanguageId { get; set; }

        [MapToParameter("strName")]
        public string Name { get; set; }

        [MapToParameter("strDefault")]
        public string Default { get; set; }

        [MapToParameter("HACode")]
        public int? intHACode { get; set; } 

        [MapToParameter("Order")]
        public int? intOrder { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }

        public string RecordAction { get; set; }
        public string LOINC { get; set; }
    }
}
