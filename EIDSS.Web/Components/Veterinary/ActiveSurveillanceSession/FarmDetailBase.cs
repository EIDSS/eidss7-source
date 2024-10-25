using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;
using Radzen.Blazor;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class FarmDetailBase : SurveillanceSessionBaseComponent
    {
       
        protected RadzenTemplateForm<FarmMasterGetDetailViewModel> form;

        protected override void OnInitialized()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;
            StateContainer.FarmLocationModel.ShowAdminLevel0 = true;
            StateContainer.FarmLocationModel.ShowAdminLevel1 = true;
            StateContainer.FarmLocationModel.ShowAdminLevel2 = true;
            StateContainer.FarmLocationModel.ShowAdminLevel3 = true;
            StateContainer.FarmLocationModel.ShowAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModel.ShowAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModel.ShowAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false;
            StateContainer.FarmLocationModel.ShowElevation = false;
            StateContainer.FarmLocationModel.ShowHouse = true;
            StateContainer.FarmLocationModel.ShowApartment = true;
            StateContainer.FarmLocationModel.EnableAdminLevel0 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel1 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel2 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel3 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel4 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel5 = false;
            StateContainer.FarmLocationModel.EnableAdminLevel6 = false;
            StateContainer.FarmLocationModel.EnableApartment = false;
            StateContainer.FarmLocationModel.EnableBuilding = false;
            StateContainer.FarmLocationModel.EnabledElevation = false;
            StateContainer.FarmLocationModel.EnabledLatitude = true;
            StateContainer.FarmLocationModel.EnabledLongitude = true;
            StateContainer.FarmLocationModel.EnableHouse = false;
            StateContainer.FarmLocationModel.EnablePostalCode = false;
            StateContainer.FarmLocationModel.EnableStreet = false;
            StateContainer.FarmLocationModel.EnableSettlement = false;
            StateContainer.FarmLocationModel.EnableSettlementType = false;

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
