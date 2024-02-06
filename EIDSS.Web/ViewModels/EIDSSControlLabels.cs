using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class EIDSSControlLabels
    {
        public string ModalMessage { get; set; }
        public string ConfirmationMessage { get; set; }
        public string EditModalMessage { get; set; }
        public string DeleteModalMessage { get; set; }
        public string UpdateModalMessage { get; set; }
        public string SuccessMessage { get; set; }
        public string ErrorMessage { get; set; }
        public string SaveButtonLabel { get; set; }
        public string YesButtonLabel { get; set; }
        public string NoButtonLabel { get; set; }
        public string OkButtonLabel { get; set; }
        public string CancelButtonLabel { get; set; }
        public string DeleteButtonLabel { get; set; } 
        public string CloseButtonLabel { get; set; } 
        public string ModalId { get; set; }
        public string ModalTitle { get; set; }
        public string EditModalTitle { get; set; }
        public string DeleteModalTitle { get; set; }
        public string SaveModalTitle { get; set; }
        /// <summary>
        /// Title For Cancel Modal Displayed when inline editing
        /// </summary>
        public string CancelInlineEditTitle { get; set; }
        /// <summary>
        /// Cancel message displayed in Modal when inline editing
        /// </summary>
        public string CanclInlineEditMessage { get; set; }
        /// <summary>
        /// Save message displayed in Modal when inline editing
        /// </summary>
        public string SaveInlineEditTitle { get; set; }
        /// <summary>
        /// Edit message displayed in Modal when inline editing
        /// </summary>
        public string SaveInlineEditMessage { get; set; }

        /// <summary>
        ///  Modal title for success label
        /// </summary>
        public string SuccessModalTitle { get; set; }

        public string DeleteExceptionMessage { get; set; }

        public string DeleteExceptionTitle { get; set; }


    }
}
