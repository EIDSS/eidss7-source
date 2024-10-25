using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels
{
    public class ResourceModel : BaseModel
    {
        [Key]
        public int ResourceID { get; set; }
        [Required]
        public int LanguageID { get; set; }
        [Required]
        [StringLength(255)]
        public string CultureName { get; set; }
        [Required]
        [StringLength(512)]
        public string ResourceKey { get; set; }
        [Required]
        public string ResourceValue { get; set; }
        [Required]
        public string ResourceType { get; set; }
    }
}
