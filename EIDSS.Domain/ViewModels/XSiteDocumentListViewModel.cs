using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class XSiteDocumentListViewModel : BaseModel
    {
        /// <summary>
        /// The container where the document is stored.
        /// </summary>
        public string DefaultDocumentContainer { get; set; } = string.Empty;

        /// <summary>
        /// The overall functional container where the document is stored.  Functional containers are
        /// Human, Vector, Laboratory, etc.  
        /// </summary>
        public string ParentDocumentContainer { get; set; } = string.Empty;

        /// <summary>
        /// An integer that uniquely identifies a document.
        /// </summary>
        public int? DocumentID { get; set; }

        /// <summary>
        /// A string fitler used to categorize documents into various groups.
        /// </summary>
        public string DocumentGroupName { get; set; }

        /// <summary>
        /// Plaing text document name.
        /// </summary>
        public string DocumentName { get; set; }

        /// <summary>
        /// Fully qualified name of the help file document.
        /// </summary>
        public string FileName { get; set; }

        /// <summary>
        /// A Globally Unique Identifier that identifies the document.  Please note that a document can have both a
        /// PDF, Word, MP4 etc representation, in which case the GUID will be identitical for all of these.
        /// </summary>
        public Guid? GUID { get; set; }

        /// <summary>
        /// Indicated by its ISO language code, Specifies the country for which this repository applies
        /// </summary>
        public string CountryISOCode { get; set; }

        /// <summary>
        /// Represents the assocated EIDSS web page ID for which this help document will display.
        /// </summary>
        public long? EIDSSMenuID { get; set; }

        /// <summary>
        /// Represents the assocated EIDSS web page name for which this help document will display.
        /// </summary>
        private string _pageLink;

        public string EIDSSMenuPageLink
        {
            get => _pageLink;
            set => _pageLink = _setPage(value);
        }

        /// <summary>
        /// Indicates the value of the "ShowMePath" and is used to create a video document entry in the returned document list.
        /// </summary>
        [IgnoreDataMember]
        public string VideoName { get; set; }

        private string _setPage(string value)
        {
            string result = string.Empty;

            if (value == null) return null;
            var match = Regex.Match(value, @"([A-Za-z0-9\-]+)\.aspx$", RegexOptions.IgnoreCase,TimeSpan.FromMilliseconds(5));

            if (match.Success)
                result = match.Value;

            return result;

        }
    }
}

