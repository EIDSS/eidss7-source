using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Laboratory;
using EIDSS.Web.ViewModels.CrossCutting;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportSampleReasonAddModalBase : BaseComponent
    {
        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IDiseaseClient DiseaseClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleReasonAddModal> Logger { get; set; }

        [Inject]
        private ProtectedSessionStorage ProtectedSessionStore { get; set; }

        //[Parameter]
        //public BaseReferenceViewModel Model { get; set; }

        public BaseReferenceViewModel baseReferenceViewModel { get; set; } = new BaseReferenceViewModel();

        protected IEnumerable<HACodesViewModel> HACodes;

        protected int HACodeCount { get; set; }

        protected EditContext EditContext { get; set; }

        protected override void OnInitialized()
        {
            // base.OnInitialized();

            _logger = Logger;
            // if (Model == null)
            //   Model = new BaseReferenceViewModel();
            //baseReferenceViewModel = Model;
            EditContext = new(baseReferenceViewModel);
            //var tsk=LoadSampleTypes(false);
            // sampleTypes = new List<BaseReferenceViewModel>();
        }

        public void Dispose()
        {
        }

        public async Task GetHACodes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetHACodeList(GetCurrentLanguage(), 226);
                var filterdlist = list.AsODataEnumerable();

                List<HACodesViewModel> model = new List<HACodesViewModel>();
                foreach (var item in filterdlist)
                {
                    HACodesViewModel haCode = new HACodesViewModel();
                    haCode.intHACode = Convert.ToInt32(item.intHACode);
                    haCode.CodeName = item.CodeName;
                    model.Add(haCode);
                }
                HACodes = model;
                // HACodesViewModel item = new HACodesViewModel();

                HACodeCount = HACodes.Count();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }
    }
}