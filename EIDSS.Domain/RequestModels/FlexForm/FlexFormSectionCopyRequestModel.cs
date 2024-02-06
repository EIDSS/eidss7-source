namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormSectionCopyRequestModel
    {
        public bool? IsDesigning { get; set; } = false;
        public long? idfsSectionSource { get; set; }
        public long? idfsSectionDestination { get; set; }
        public long? idfsFormTypeDestination { get; set; }
        public string User { get; set; } = "";
    }
}
