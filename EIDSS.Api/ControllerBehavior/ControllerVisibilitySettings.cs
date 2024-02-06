using System.Collections.Generic;

namespace EIDSS.Api.ControllerBehavior
{
    public class ControllerVisibilitySettings
    {
        public const string ControllerVisibilityBehaviorsSection = "ControllerVisibilityBehaviors";
        public bool HideAllControllers { get; set; }

        public List<string> ControllerVisibilityOverrides = new List<string>();
    }
}
