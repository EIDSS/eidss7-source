
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Laboratory;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human
{
    public class ILIAggregateAddModalBase : BaseComponent, IDisposable
    {

        #region Dependencies
        [Inject] IStringLocalizer Localizer { get; set; }

        [Inject] private IOrganizationClient OrganizationClient { get; set; }

        [Inject] ITokenService TokenService { get; set; }

        [Inject] ProtectedSessionStorage ProtectedSessionStore { get; set; }

        [Inject] private ILogger<ILIAggregateAddModalBase> Logger { get; set; }

        #endregion

        #region Parameters
        [Parameter] public ILIAggregatePageViewModel Header { get; set; }
        #endregion

        #region Properties
        protected RadzenTemplateForm<ILIAggregateDetailViewModel> Form { get; set; }                      
        public IEnumerable<OrganizationGetListViewModel> Hospitals;        
        public ILIAggregateDetailViewModel ILIAggregateDetail { get; set; }
        #endregion


        #region Methods

        protected override void OnInitialized()
        {            
            ILIAggregateDetail = new ILIAggregateDetailViewModel();
            base.OnInitialized();
            _logger = Logger;
        }

        public async Task GetHospitals(LoadDataArgs args)
        {
            try
            {

                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = Convert.ToInt32(AccessoryCodeEnum.Human),
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Hospital
                };

                List<OrganizationAdvancedGetListViewModel> lstOrganizationsAdv = await OrganizationClient.GetOrganizationAdvancedList(request);

                var hospitalList = new List<OrganizationGetListViewModel>();
                foreach (var orgAdv in lstOrganizationsAdv)
                {
                    OrganizationGetListViewModel org = new OrganizationGetListViewModel();
                    org.OrganizationKey = orgAdv.idfOffice;
                    org.FullName = orgAdv.FullName;
                    hospitalList.Add(org);
                }

                Hospitals = hospitalList;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void CalculateTotalILI()
        {
            ILIAggregateDetail.InTotalILI = (ILIAggregateDetail.IntAge0_4 ?? 0) 
                + (ILIAggregateDetail.IntAge5_14 ?? 0) 
                + (ILIAggregateDetail.IntAge15_29 ?? 0) 
                + (ILIAggregateDetail.IntAge30_64 ?? 0)
                + (ILIAggregateDetail.IntAge65 ?? 0);
        }
        

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnSubmitClick()
        {
            if (!Form.EditContext.Validate()) return;            
            DiagService.Close(Form.EditContext);
        }

        public void Dispose()
        {
            //throw new NotImplementedException();
        }
    }

    #endregion
}
