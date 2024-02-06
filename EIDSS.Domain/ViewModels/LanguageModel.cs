using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels
{
    public class LanguageModel : BaseModel
    {
        [Key]
        public int LanguageID { get; set; }
        [Required]
        [StringLength(255)]
        public string Country { get; set; }
        [Required]
        [StringLength(255)]
        public string CultureName { get; set; }
        [Required]
        [StringLength(255)]
        public string DisplayName { get; set; }
        [Required]
        [StringLength(255)]
        public bool IsDefaultLanguage { get; set; }
    }
}
