using System.Collections.Generic;

namespace EIDSS.Web.Areas.Laboratory.ViewModels
{
    public class StorageLocationViewModel
    {
        public int StorageLocationId { get; set; }
        public long FreezerId { get; set; }
        public long? SubdivisionId { get; set; }
        public string StorageLocationName { get; set; }
        public long? StorageTypeId { get; set; }
        public List<StorageLocationViewModel> Children { get; set; }
    }
}
