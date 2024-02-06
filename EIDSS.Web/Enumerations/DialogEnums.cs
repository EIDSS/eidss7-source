using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Enumerations
{
    public enum DialogButtonType
    {
        Yes,
        No,
        OK,
        Cancel,
        Close,
        Submit,
        Save
    }

    public class DialogButton
    {
        public string ButtonText { get; set; }
        public DialogButtonType ButtonType { get; set; }
    }

    public enum EIDSSDialogType
    {
        Information,
        Warning,
        Error,
        Success
    }

    public class DialogReturnResult
    {
        public Type CallingComponent { get; set; }
        public string ButtonResultText { get; set; }
        public string DialogName { get; set; }
    }


}
