namespace EIDSS.Domain.RequestModels.Vector
{
    public class USP_VCTS_DetailedCollections_CopyRequestModel
    {
        public long? idfVector { get; set; }
        public bool? VectorData { get; set; }
        public bool? Samples { get; set; }
        public bool? Tests { get; set; }
    }
}
