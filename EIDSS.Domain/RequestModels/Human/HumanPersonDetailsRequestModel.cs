using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanPersonDetailsRequestModel 
    {
        public string LangID { get; set; }
        public  long? HumanMasterID { get; set; }


    }
    public class HumanPersonDetailsFromHumanIDRequestModel
    {
        public string LanguageId { get; set; }
        public long? HumanID { get; set; }


    }

    public class GetPersonForOfficeRequestModel
    {

        public string LangID { get; set; }
        public long? OfficeID { get; set; }

        public long? ID { get; set; } = null;

        public bool? ShowUsersOnly { get; set; } = false;

        public int? intHACode { get; set; }

        public string? AdvancedSearch { get; set; } = null;

    }
}