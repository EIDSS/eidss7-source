using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Microsoft.AspNetCore.Components;

namespace EIDSS.Web.Components.Administration.InterfaceEditor
{
    public class InterfaceEditorBase : BaseComponent
    {
        [Parameter] public InterfaceEditorPageViewModel Model { get; set; }
    }
}