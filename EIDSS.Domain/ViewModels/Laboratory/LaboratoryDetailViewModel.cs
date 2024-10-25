using EIDSS.Domain.Abstracts;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class LaboratoryDetailViewModel : BaseModel
    {
        public long SampleID { get; set; }
        public long? TestID { get; set; }
        public long? TransferID { get; set; }
        public int AccordionIndex { get; set; }
        public bool ShowTransferDetails { get; set; }

        public long? DiseaseID { get; set; }

        public bool SamplesWritePermission { get; set; }
        public bool TestingWritePermission { get; set; }
        public bool TransferredWritePermission { get; set; }

        public SamplesGetListViewModel Sample { get; set; }
        public List<TestingGetListViewModel> Tests { get; set; }
        public TestingGetListViewModel Test { get; set; }
        public TransferredGetListViewModel Transfer { get; set; }
    }
}