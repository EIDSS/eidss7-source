using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FreezerBoxLocationAvailabilitySaveRequestModel
    {
        public long FreezerSubdivisionID { get; set; }
        public string BoxPlaceAvailability { get; set; }
        public string EIDSSFreezerSubdivisionID { get; set; }
    }
}