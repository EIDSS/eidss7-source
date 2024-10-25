using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class FarmDetailAggregateBase : SurveillanceSessionBaseComponent
    {
       
        protected RadzenTemplateForm<FarmMasterGetDetailViewModel> form;

        protected override void OnInitialized()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel0 = true;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel1 = true;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel2 = true;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel3 = true;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModelAggregate.ShowAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModelAggregate.ShowElevation = false;
            StateContainer.FarmLocationModelAggregate.ShowHouse = true;
            StateContainer.FarmLocationModelAggregate.ShowApartment = true;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel0 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel1 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel2 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel3 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel4 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel5 = false;
            StateContainer.FarmLocationModelAggregate.EnableAdminLevel6 = false;
            StateContainer.FarmLocationModelAggregate.EnableApartment = false;
            StateContainer.FarmLocationModelAggregate.EnableBuilding = false;
            StateContainer.FarmLocationModelAggregate.EnabledElevation = false;
            StateContainer.FarmLocationModelAggregate.EnabledLatitude = true;
            StateContainer.FarmLocationModelAggregate.EnabledLongitude = true;
            StateContainer.FarmLocationModelAggregate.EnableHouse = false;
            StateContainer.FarmLocationModelAggregate.EnablePostalCode = false;
            StateContainer.FarmLocationModelAggregate.EnableStreet = false;
            StateContainer.FarmLocationModelAggregate.EnableSettlement = false;
            StateContainer.FarmLocationModelAggregate.EnableSettlementType = false;

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }


        private async Task OnStateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        public void Dispose()
        {
            StateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        public async Task StateContainerChanged()
        {
            await InvokeAsync(StateHasChanged);
        }


    }
}
