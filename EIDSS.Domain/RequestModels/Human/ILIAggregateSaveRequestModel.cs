using EIDSS.Domain.Attributes;
using EIDSS.Domain.ResponseModels;
using System;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ILIAggregateSaveRequestModel : APIPostResponseModel
    {
        public long? IdfAggregateHeader { get; set; }
        public long? IdfAggregateDetail { get; set; }

        public long IdfEnteredBy { get; set; }
        public long IdfsSite { get; set; }

        public int IntYear { get; set; }

        public int IntWeek { get; set; }

        public DateTime DatStartDate { get; set; }

        public DateTime DatFinishDate { get; set; }
        public long IdfHospital { get; set; }
        public int IntAge0_4 { get; set; }
        public int IntAge5_14 { get; set; }
        public int IntAge15_29 { get; set; }
        public int IntAge30_64 { get; set; }
        public int IntAge65 { get; set; }
        public int InTotalILI { get; set; }
        public int IntTotalAdmissions { get; set; }
        public int IntILISamples { get; set; }

        public string StrFormId { get; set; }
        public int RowStatus { get; set; }
        public string AuditUserName { get; set; }
        public string StrRowAction { get; set; }
        public string ILITables { get; set; }
        public string Events { get; set; }

        private DateTime DateLastSaved { get; set; }
    }
}
