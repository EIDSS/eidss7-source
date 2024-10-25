#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class SamplesModalBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SamplesModalBase> Logger { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private IVectorTypeSampleTypeMatrixClient VectorTypeSampleTypeMatrixClient { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<VectorSampleGetListViewModel> Form { get; set; }
        public IList<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public IList<VectorTypeSampleTypeMatrixViewModel> SampleTypes { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> SentToOrganizations { get; set; }

        #endregion

        #region Member Variables

        protected bool SpeciesIsDisabled;
        protected bool HasAssociatedFieldTest;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (VectorSessionStateContainer.SampleDetail.SampleID <= 0 && IsNullOrEmpty(VectorSessionStateContainer.SampleDetail.EIDSSLocalOrFieldSampleID))
            {
                VectorSessionStateContainer.SampleDetail.EIDSSLocalOrFieldSampleID = "(" +
                    Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                    + " " + (VectorSessionStateContainer.DetailedCollectionsSamplesList.Count + 1) + ")";
            }

            if (VectorSessionStateContainer.SampleDetail != null
                && VectorSessionStateContainer.DetailedCollectionsFieldTestsList != null
                && VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any(x => x.SampleID == VectorSessionStateContainer.SampleDetail.SampleID))
                HasAssociatedFieldTest = true;

            await base.OnInitializedAsync();
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        ///
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                Diseases ??= new List<FilteredDiseaseGetListViewModel>();

                var request = new FilteredDiseaseRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.VectorHACode,
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                    UsingType = null,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                };
                Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);

                // filter by filter criteria
                if (!IsNullOrEmpty(args.Filter))
                    Diseases = Diseases.Where(d => d.DiseaseName != null && d.DiseaseName.Contains(args.Filter)).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.VectorHACode,
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long?)OrganizationTypes.Laboratory
                };
                if (args is {Filter: { }})
                    request.AdvancedSearch = args.Filter;
                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                // filter by filter criteria
                if (!IsNullOrEmpty(args.Filter))
                    list = list.Where(d => d.name != null && d.name.Contains(args.Filter)).ToList();

                SentToOrganizations = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task GetSampleTypes(LoadDataArgs args)
        {
            try
            {
                var request = new VectorTypeSampleTypeMatrixGetRequestModel();
                if (VectorSessionStateContainer.DetailVectorTypeID != null)
                {
                    request.idfsVectorType = VectorSessionStateContainer.DetailVectorTypeID;
                    request.LanguageId = GetCurrentLanguage();
                    request.Page = 1;
                    request.PageSize = int.MaxValue - 1;
                    request.SortColumn = "strSampleTypeName";
                    request.SortOrder = SortConstants.Ascending;
                    var list = await VectorTypeSampleTypeMatrixClient.GetVectorTypeSampleTypeMatrixList(request);

                    // filter by filter criteria
                    if (!IsNullOrEmpty(args.Filter))
                        list = list.Where(x => x.strSampleTypeName != null && x.strSampleTypeName.Contains(args.Filter)).ToList();

                    SampleTypes = list.ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnSaveClick()
        {
            if (!Form.EditContext.Validate()) return;
            switch (VectorSessionStateContainer.SampleDetail.SampleID)
            {
                case 0:
                    if (VectorSessionStateContainer.DetailedCollectionsSamplesList != null) VectorSessionStateContainer.SampleDetail.SampleID = (VectorSessionStateContainer.DetailedCollectionsSamplesList.Count + 1) * -1;
                    VectorSessionStateContainer.SampleDetail.VectorSessionID = VectorSessionStateContainer.VectorSessionKey;
                    VectorSessionStateContainer.SampleDetail.VectorID = VectorSessionStateContainer.VectorDetailedCollectionKey;
                    VectorSessionStateContainer.SampleDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    VectorSessionStateContainer.SampleDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                    VectorSessionStateContainer.SampleDetail.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    break;

                case > 0:
                    VectorSessionStateContainer.SampleDetail.RowAction = (int)RowActionTypeEnum.Update;
                    VectorSessionStateContainer.SampleDetail.SiteID = Convert.ToInt64(authenticatedUser.SiteId);
                    break;
            }

            if (SampleTypes.Any(x => x.idfsSampleType == VectorSessionStateContainer.SampleDetail.SampleTypeID))
                VectorSessionStateContainer.SampleDetail.SampleTypeName = SampleTypes.First(x => x.idfsSampleType == VectorSessionStateContainer.SampleDetail.SampleTypeID).strSampleTypeName;

            if (SentToOrganizations.Any(x => x.idfOffice == VectorSessionStateContainer.SampleDetail.SentToOrganizationID))
                VectorSessionStateContainer.SampleDetail.SentToOrganizationName =
                    SentToOrganizations.First(x => x.idfOffice == VectorSessionStateContainer.SampleDetail.SentToOrganizationID).name;

            if (Diseases.Any(x => x.DiseaseID == VectorSessionStateContainer.SampleDetail.DiseaseID))
                VectorSessionStateContainer.SampleDetail.TestDiseaseName =
                    Diseases.First(x => x.DiseaseID == VectorSessionStateContainer.SampleDetail.DiseaseID).DiseaseName;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                            .ConfigureAwait(false);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}