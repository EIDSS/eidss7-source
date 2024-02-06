using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Shared.ViewModels;
using Microsoft.AspNetCore.Components;

namespace EIDSS.Web.Components.Shared
{
    public class AggregateSummaryBase : BaseComponent
    {
        #region Globals

        #region Parameters

        [Parameter] public AggregateSummaryPageViewModel Model { get; set; }

        #endregion Parameters

        #region Properties

        protected static bool IsLoading { get; set; } = false;

        #endregion Properties

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override bool ShouldRender()
        {
            return IsLoading;
        }

        #endregion Lifecycle Methods

        #endregion Methods
    }
}