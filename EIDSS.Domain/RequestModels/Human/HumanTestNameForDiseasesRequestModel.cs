using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanTestNameForDiseasesRequestModel
    {
        public string langId { get; set; }
        public long? idfsDiagnosis { get; set; }

        public int? PaginationSet { get; set; }

        public int? PageSize { get; set; }

        public int? MaxPagesPerFetch { get; set; }
        
    }
   
}