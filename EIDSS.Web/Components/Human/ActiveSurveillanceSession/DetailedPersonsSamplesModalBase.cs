#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.Human.Person;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

#endregion Usings

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class DetailedPersonsSamplesModalBase : ParentComponent
    {
        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        [Inject]
        private ITokenService TokenService { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        protected DialogService DialogService { get; set; }

        public bool IsLoading { get; set; }

        public EditContext EditContext { get; set; }
        private ILogger<DetailedInformationBase> Logger { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;

        public PersonSearchPageViewModel PersonSearchModel;
        public RadzenTemplateForm<ActiveSurveillanceSessionViewModel> _form { get; set; }

        private const string DIALOG_WIDTH = "700px";
        private const string DIALOG_HEIGHT = "775px";

        #endregion

        protected override void OnInitialized()
        {
            IsLoading = true;
            EditContext = new(model.DetailedInformation);

            if (model.DetailedInformation.List == null)
            {
                model.DetailedInformation.List = new List<ActiveSurveillanceSessionDetailedInformationResponseModel>();
            }

            string strNew = model.Summary.SessionID.ToString();

            bool bUniqueNewId = false;
            string strNewId = String.Empty;

            if (string.IsNullOrEmpty(model.DetailedInformation.FieldSampleID))
            {
                strNewId = strNew + "-" + (model.DetailedInformation.NewFieldSampleId++).ToString("D2");
            }
            else
            {
                strNewId = model.DetailedInformation.FieldSampleID;
                bUniqueNewId = true;
            }

            while (!bUniqueNewId)
            {
                bUniqueNewId = true;

                foreach (ActiveSurveillanceSessionDetailedInformationResponseModel detailInformation in model.DetailedInformation.List)
                {
                    if (detailInformation.FieldSampleID == strNewId)
                    {
                        bUniqueNewId = false;
                        strNewId = strNew + "-" + (model.DetailedInformation.NewFieldSampleId++).ToString("D2");
                        break;
                    }
                }
            }

            model.DetailedInformation.FieldSampleID = strNewId;
        }

        public async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                List<OrganizationAdvancedGetListViewModel> list;
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = (int?)AccessoryCodes.HumanHACode, //contains Human Acccessory Code
                    //AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
                    //AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Laboratory,
                };

                list = await OrganizationClient.GetOrganizationAdvancedList(request);
                if (args != null && args.Filter != null)
                {
                    List<OrganizationAdvancedGetListViewModel> toList = list.Where(c => c.FullName != null && c.FullName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }

                model.DetailedInformation.SentToOrganizations = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task PersonSearchClicked()
        {
            try
            {
                var result = await DiagService.OpenAsync<SearchPerson.SearchPerson>(
                    "Person Search",
                   new Dictionary<string, object>()
                   {
                         {"Mode", SearchModeEnum.SelectNoRedirect}
                   },
                   new DialogOptions
                   {
                       Width = DIALOG_WIDTH,
                       //Height = DIALOG_HEIGHT,
                       AutoFocusFirstElement = false,
                       CloseDialogOnOverlayClick = false,
                       Draggable = false,
                       Resizable = true
                   });

                switch (result)
                {
                    case PersonViewModel person:

                        model.DetailedInformation.PersonID = person.HumanMasterID;
                        model.DetailedInformation.EIDSSPersonID = person.EIDSSPersonID;
                        model.DetailedInformation.HumanMasterID = person.HumanMasterID;
                        model.DetailedInformation.PersonAddress = person.AddressString;

                        //if (Mode != SearchModeEnum.SelectNoRedirect)
                        //{
                        //    DiagService.Close();
                        //}

                        await InvokeAsync(StateHasChanged);
                        break;

                    case string when result == "Cancelled":
                        break;

                    case string when result == "Add":
                        source?.Cancel();
                        await AddPerson().ConfigureAwait(false);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Loads the Add Person in a dialog and
        /// captures the new person result.
        /// </summary>
        /// <returns></returns>
        protected async Task AddPerson()
        {
            //reset the cancellation token
            var source = new CancellationTokenSource();
            var token = source.Token;

            try
            {
                var result = await DiagService.OpenAsync<PersonSections>(
                    Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                    new Dictionary<string, object>()
                    {
                        { "ShowInDialog", true }
                    },
                    new DialogOptions
                    {
                        Style = EIDSSConstants.LaboratoryModuleCSSClassConstants.AddPersonDialog,
                        AutoFocusFirstElement = true,
                        //MJK - Height is set globally for dialogs
                        //Height = EIDSSConstants.CSSClassConstants.LargeDialogHeight,
                        Width = EIDSSConstants.CSSClassConstants.LargeDialogWidth,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                switch (result)
                {
                    case PersonViewModel person:

                        model.DetailedInformation.PersonID = person.HumanMasterID;
                        model.DetailedInformation.EIDSSPersonID = person.EIDSSPersonID;
                        model.DetailedInformation.HumanMasterID = person.HumanMasterID;
                        model.DetailedInformation.PersonAddress = person.AddressString;

                        await InvokeAsync(StateHasChanged);
                        break;

                    case string when result == "Cancelled":
                        source?.Cancel();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
            finally
            {
                source?.Cancel();
                source?.Dispose();
            }
        }

        protected async Task HandleValidEmployeeSubmit(ActiveSurveillanceSessionViewModel model)
        {
            try
            {
                if (!_form.EditContext.Validate()) return;

                if (_form.IsValid)
                {
                    ActiveSurveillanceSessionDetailedInformationResponseModel detailInformation = new ActiveSurveillanceSessionDetailedInformationResponseModel();
                    detailInformation.CollectionDate = model.DetailedInformation.CollectionDate;
                    detailInformation.FieldSampleID = model.DetailedInformation.FieldSampleID;
                    detailInformation.PersonID = model.DetailedInformation.PersonID;
                    detailInformation.EIDSSPersonID = model.DetailedInformation.EIDSSPersonID;
                    detailInformation.PersonAddress = model.DetailedInformation.PersonAddress;
                    detailInformation.Comment = model.DetailedInformation.Comments;
                    detailInformation.idfsSampleType = long.Parse(model.DetailedInformation.idfsSampleType.ToString());
                    detailInformation.SampleType = model.SessionInformation.MonitoringSessionToSampleTypes.Where(x => x.SampleTypeID == model.DetailedInformation.idfsSampleType).First().SampleTypeName;
                    detailInformation.idfSendToOffice = long.Parse(model.DetailedInformation.SentToOrganization.ToString());
                    detailInformation.SentToOrganization = model.DetailedInformation.SentToOrganizations.Where(x => x.idfOffice == model.DetailedInformation.SentToOrganization).First().FullName;
                    detailInformation.HumanMasterID = model.DetailedInformation.HumanMasterID;

                    foreach (long idfs in model.DetailedInformation.DiseaseIDs)
                    {
                        detailInformation.Disease += model.DetailedInformation.SampleTypeDiseases.Where(x => x.DiseaseID == idfs).First().DiseaseName + ", ";
                        detailInformation.DiseaseIDs += model.DetailedInformation.SampleTypeDiseases.Where(x => x.DiseaseID == idfs).First().DiseaseID + ", ";
                    }

                    detailInformation.Disease = (detailInformation.Disease + ".").Replace(", .", "");
                    detailInformation.DiseaseIDs = (detailInformation.DiseaseIDs + ".").Replace(", .", "");

                    if (model.DetailedInformation.List == null)
                    {
                        model.DetailedInformation.List = new List<ActiveSurveillanceSessionDetailedInformationResponseModel>();
                    }

                    if (model.DetailedInformation.ID == null)
                    {
                        detailInformation.ID = detailInformation.ID ?? model.DetailedInformation.NewRecordId--;
                        model.DetailedInformation.List.Add(detailInformation);
                        model.DetailedInformation.List = model.DetailedInformation.List.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                    }
                    else
                    {
                        int iIndex = model.DetailedInformation.List.FindIndex(x => x.ID == model.DetailedInformation.ID);
                        detailInformation.ID = model.DetailedInformation.ID;
                        if (detailInformation.EIDSSPersonID == model.DetailedInformation.List[iIndex].EIDSSPersonID)
                            detailInformation.HumanMasterID = model.DetailedInformation.List[iIndex].HumanMasterID;
                        model.DetailedInformation.List[iIndex] = detailInformation;
                    }

                    model.DetailedInformation.UnfilteredList = model.DetailedInformation.List;

                    StateContainer.SetActiveSurveillanceSessionViewModel(model);
                    await InvokeAsync(StateHasChanged);

                    DialogService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task HandleInvalidEmployeeSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
            }
            catch (Exception)
            {
                throw;
            }
        }

        //protected async Task SetCollectionDate(DateTime? dateTime)
        //{
        //    try
        //    {
        //        DateTime dt;

        //        if (DateTime.TryParse(dateTime.ToString(), out dt))
        //        {
        //            model.DetailedInformation.CollectionDate = dt;
        //        }
        //        else
        //        {
        //            model.DetailedInformation.CollectionDate = null;
        //        }
        //    }
        //    catch(Exception ex)
        //    {
        //        _logger.LogError(ex.Message, null);
        //        throw;
        //    }
        //}
    }
}