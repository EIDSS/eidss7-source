using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class MatrixViewModel : BaseSaveRequestModel
    {
        public long? IdfAggrDiagnosticActionMTX { get; set; }
        public long? IdfAggrVetCaseMTX { get; set; }
        public long? IdfAggrHumanCaseMTX { get; set; }
        public long? IdfAggrProphylacticActionMTX { get; set; }
        public long? idfAggrSanitaryActionMTX { get; set; }
        public long? IdfVersion { get; set; }
        public string InJsonString { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
