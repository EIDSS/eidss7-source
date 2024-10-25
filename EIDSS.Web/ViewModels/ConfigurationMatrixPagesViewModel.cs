using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels
{
    public class ConfigurationMatrixPagesViewModel : ConfigurationMatrixViewModel
    {
        public ConfigurationMatrixPagesViewModel()
        {
            RadioButton2Configurations = new Dictionary<string, string>();
        }

        /// <summary>
        /// Displays Name of Page in Header
        /// </summary>
        public string PageName { get; set; }
        public ConfigurationMatrixViewModel[] configurationListViewModel { get; set; }

        /// <summary>
        /// Defines DropDowns For the Model
        /// </summary>
        public List<Select2Configruation> Select2Configurations { get; set; }

        public Dictionary<string,string> RadioButton2Configurations { get; set; }

        public string InformationMessage { get; set; }

        private EIDSSGridConfiguration _gridViewComponentBuilder;

        /// <summary>
        /// Defines The Grid for the Model
        /// </summary>
        public EIDSSGridConfiguration eidssGridConfiguration { get => _gridViewComponentBuilder;
            set => _gridViewComponentBuilder = value;
        }

        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        /// <summary>
        /// Modal Id to Launch from Page Level Button
        /// </summary>
        public string PageLevelAddButtonModal { get; set; }

        /// <summary>
        /// Page button Text that Launches Modal
        /// </summary>
        public string PageLevelAddButtonModalText { get; set; }

        /// <summary>
        /// ID of Add Button On Page
        /// </summary>
        public string PageLevelAddButtonID { get; set; }
    }
}
