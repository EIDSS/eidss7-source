using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Abstracts
{
    /// <summary>
    /// Base model for data requests that return result sets
    /// </summary>
    public abstract class BaseGetRequestModel
    {
        /// <summary>
        /// An ISO 639-1/2 or a combination of ISO 639-1/2 and a valid Country Code, i.e., en or eng or en-US or eng-US
        /// </summary>
        //[Required]
        [MapToParameter(new string[] { "langID", "languageId", "LanguageID", "LangID" })]
        public string LanguageId { get; set; }

        /// <summary>
        /// Gets or sets the current page
        /// </summary>}
        [Required]
        [MapToParameter(new string[] { "PageNo", "PageNumber" })]
        public int Page { get; set; } = 1;

        /// <summary>
        /// Gets or sets the page size (Total number of rows per page)
        /// </summary>
        [Required]
        public int PageSize { get; set; } = 10;

        /// <summary>
        /// A string representing a column in the associated ReponseModel to sort by
        /// </summary>
        [Required]
        public string SortColumn { get; set; }

        /// <summary>
        /// A string that indicates how the data should be sorted.  Possible options are "ASC,DESC"
        /// </summary>
        [Required]
        public string SortOrder { get; set;}

    }
}
