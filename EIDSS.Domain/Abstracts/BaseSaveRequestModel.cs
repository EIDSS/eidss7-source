using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using System;

namespace EIDSS.Domain.Abstracts
{
    public abstract class BaseSaveRequestModel
    {
        /// <summary>
        /// An ISO 639-1/2 or a combination of ISO 639-1/2 and a valid Country Code, i.e., en or eng or en-US or eng-US
        /// </summary>
        [MapToParameter("langID")]
        public string LanguageId { get; set; }
        [MapToParameter("AuditUserName")]
        public string User { get; set; }
    }
}
