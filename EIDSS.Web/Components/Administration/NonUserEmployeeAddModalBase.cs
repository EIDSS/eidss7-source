
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration
{
    public class NonUserEmployeeAddModalBase : BaseComponent
    {

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }


        [Inject]
        ILogger<NonUserEmployeeAddModalBase> Logger { get; set; }

        [Inject]
        IPersonalIdentificationTypeMatrixClient personalIdentificationTypeMatrixClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Parameter]
        public long? OrganizationID { get; set; }
        
        [Parameter]
        public bool DisableOrganizationField { get; set; }
        
        public EmployeePersonalInfoPageViewModel Model { get; set; }

        protected IEnumerable<BaseReferenceEditorsViewModel> lstPersonalIDType;
        protected IEnumerable<DepartmentGetListViewModel> lstDepartment;
        protected IEnumerable<BaseReferenceEditorsViewModel> lstPositions;
        protected RadzenTemplateForm<EmployeePersonalInfoPageViewModel> _form;

        protected int personalIDTypeCount { get; set; }

        protected int departmentCount { get; set; }

        protected int positionsCount { get; set; }


        protected EditContext EditContext { get; set; }

        protected bool EnableDepartment { get; set; } = true;

        private UserPermissions userPermissions;

        protected bool canAddEmployee { get; set; }

        protected bool DisablePersonalID { get; set; } = true;

        protected bool IsPersonalIDRequired { get; set; }

        protected bool IsPersonalIDValid { get; set; } = false;

        protected bool IsPersonalIDInValid { get; set; } = false;


        protected async override Task OnInitializedAsync()
        {

            _logger = Logger;
            userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            canAddEmployee = userPermissions.Create;

            Model = new EmployeePersonalInfoPageViewModel();

            if (OrganizationID > 0)
            {
                var organizationDetail = await OrganizationClient.GetOrganizationDetail(Thread.CurrentThread.Name, OrganizationID.Value);
                Model.OrganizationID = OrganizationID;
                Model.AbbreviatedName = organizationDetail.AbbreviatedNameNationalValue;
                await GetSiteNameAndDepartments();
            }

            await LoadPersonalTypeIDs(null);
            await LoadPositions(null);
        }

        public async Task LoadPersonalTypeIDs(LoadDataArgs args)
        {
            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = BaseReferenceTypeIds.PersonalIdTypes,
                Page = 1,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = null,
                SortColumn = "intorder",
                SortOrder = "asc"
            };

            if (args != null)
                baseReferenceGetRequestModel.AdvancedSearch = args.Filter;

            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);
                lstPersonalIDType = list.AsODataEnumerable();
                personalIDTypeCount = lstPersonalIDType.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task SelectedOrganizationIdChanged(long? organizationId)
        {
            Model.OrganizationID = OrganizationID;
            await GetSiteNameAndDepartments();
        }

        private async Task GetSiteDetails()
        {
            List<EmployeeSiteFromOrgViewModel> response = new List<EmployeeSiteFromOrgViewModel>();
            try
            {
                response = await EmployeeClient.GetEmployeeSiteFromOrg(Model.OrganizationID);
                if (response != null && response.Count > 0)
                {
                    Model.SiteID = response.FirstOrDefault().idfsSite;
                    Model.SiteName = response.FirstOrDefault().strSiteID;
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task GetSiteNameAndDepartments()
        {
            if (Model.OrganizationID > 0)
            {
                DepartmentGetRequestModel model = new DepartmentGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    SortColumn = "intOrder",
                    SortOrder = "asc",
                    PageSize = 10000,
                    Page = 1,
                    OrganizationID = Model.OrganizationID
                };
                var list = await CrossCuttingClient.GetDepartmentList(model);
                lstDepartment = list.AsODataEnumerable();
                departmentCount = lstDepartment.Count();
                EnableDepartment = false;

                await GetSiteDetails();

                await InvokeAsync(StateHasChanged);
            }
            else
            {
                EnableDepartment = true;
                lstDepartment = new List<DepartmentGetListViewModel>();
            }
        }

        public async Task LoadPositions(LoadDataArgs args)
        {
            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = (long)ReferenceTypes.Position,
                Page = 1,
                LanguageId = GetCurrentLanguage(),
                PageSize = 99999,
                AdvancedSearch = null,
                SortColumn = "intorder",
                SortOrder = "asc"
            };

            if (args != null && args.Filter != null && args.Filter != "")
                baseReferenceGetRequestModel.AdvancedSearch = args.Filter;
            else
                baseReferenceGetRequestModel.AdvancedSearch = null;
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);
                lstPositions = list.AsODataEnumerable();
                positionsCount = lstPositions.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task ClearPersonalID(object value)
        {
            // if personal id type is 'Unknown'
            if (value is not null && ((long)value == (long)PersonalIDTypeEnum.Unknown))
            {
                Model.PersonalID = String.Empty;
                IsPersonalIDRequired = false;
                DisablePersonalID = true;                
            }
            // if person id type is cleared out
            else if(value is null || (long)value < 1)
            {
                Model.PersonalID = String.Empty;
                IsPersonalIDRequired = false;
                DisablePersonalID = true;

            }
            // person id type has a real value
            else
            {
                IsPersonalIDRequired = true;
                DisablePersonalID = false;                
            }
            
            //IsPersonalIDInValid = false;
            
            await InvokeAsync(StateHasChanged);
        }


        public async Task ValidatePersonalID(object value)
        {

            //JObject jsonObject = JObject.Parse(data);
            var personalID = "";
            long? personalIDType = 0;
           

            try
            {
                if(value!=null)
                    personalID = value.ToString();

                personalIDType = Model.PersonalIDType;
                if (personalIDType != null && personalIDType != 0)
                {

                    var request = new PersonalIdentificationTypeMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SortOrder = "asc",
                        SortColumn = "IntOrder"
                    };


                    List<PersonalIdentificationTypeMatrixViewModel> response = await personalIdentificationTypeMatrixClient.GetPersonalIdentificationTypeMatrixList(request);

                    if (response != null)
                    {
                        var item = response.Where(a => a.IdfPersonalIDType == personalIDType).FirstOrDefault();
                        if (item != null && item.StrFieldType == "Numeric")
                        {
                            var result = 0;
                            if (personalID.Length == item.Length && Int32.TryParse(personalID, out result))
                            {
                                IsPersonalIDValid = true;
                                IsPersonalIDInValid = false;
                            }
                            else
                            {
                                IsPersonalIDInValid = true;
                            }
                        }
                        else if (item != null && item.StrFieldType == "AlphaNumeric")
                        {
                            Regex rg = new Regex(@"^[a-zA-Z0-9\s,]*$",RegexOptions.None,TimeSpan.FromMilliseconds(5));
                            IsPersonalIDValid = rg.IsMatch(personalID);
                            if (IsPersonalIDValid)
                                IsPersonalIDInValid = false;
                            else
                                IsPersonalIDInValid = true;
                        }

                    }
                    await InvokeAsync(StateHasChanged);
                }
                else
                    IsPersonalIDInValid = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        void KeyUp(KeyboardEventArgs e, string memberName)
        {
            var property = Model.GetType().GetProperty(memberName);
            var value = property.GetValue(Model);
            property.SetValue(Model, value + e.Key);

            var id = EditContext.Field(memberName);

            EditContext.NotifyFieldChanged(id);
        }

        protected async Task HandleValidEmployeeSubmit(EmployeePersonalInfoPageViewModel model)
        {

            if (_form.IsValid)
            {

                if (_form.EditContext.IsModified())
                {

                    var newEmployee = _form.EditContext;
                    EmployeeSaveRequestResponseModel response = await SaveNonUserEmployee(newEmployee);

                    if (response.RetunMessage == "Success")
                    {
                        await ShowSuccessMessage();
                        ((EmployeePersonalInfoPageViewModel)_form.EditContext.Model).EmployeeID = response.idfPerson.GetValueOrDefault();
                        DiagService.Close(newEmployee.Model);
                    }
                    else if (response.RetunMessage == "DOES EXIST")
                    {
                        await ShowDuplicateMessage(response.DuplicateMessage);
                    }
                    await InvokeAsync(StateHasChanged);
                    

                }
            }
        }

        public async Task<EmployeeSaveRequestResponseModel> SaveNonUserEmployee(EditContext result)
        {
            EmployeeSaveRequestResponseModel response = new EmployeeSaveRequestResponseModel();
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            EmployeePersonalInfoPageViewModel obj = (EmployeePersonalInfoPageViewModel)result.Model;
            EmployeePersonalInfoSaveRequest.strPersonalID = obj.PersonalID;
            EmployeePersonalInfoSaveRequest.idfPersonalIDType = obj.PersonalIDType.ToString();
            EmployeePersonalInfoSaveRequest.strFirstName = obj.FirstOrGivenName;
            EmployeePersonalInfoSaveRequest.strSecondName = obj.SecondName;
            EmployeePersonalInfoSaveRequest.strFamilyName = obj.LastOrSurName;
            EmployeePersonalInfoSaveRequest.strContactPhone = obj.ContactPhone;
            EmployeePersonalInfoSaveRequest.idfInstitution = obj.OrganizationID;
            if (obj.SiteID==0)
                obj.SiteID = 1;
            EmployeePersonalInfoSaveRequest.idfsSite = obj.SiteID;
            EmployeePersonalInfoSaveRequest.idfsStaffPosition = obj.PositionTypeID;
            EmployeePersonalInfoSaveRequest.idfDepartment = obj.DepartmentID;
          

           
            EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;

            EmployeeGetListRequestModel DuplicateCheckRequest = new EmployeeGetListRequestModel();

            DuplicateCheckRequest.FirstOrGivenName = EmployeePersonalInfoSaveRequest.strFirstName;
            DuplicateCheckRequest.LanguageId = GetCurrentLanguage();
            DuplicateCheckRequest.LastOrSurName = EmployeePersonalInfoSaveRequest.strFamilyName;
            DuplicateCheckRequest.PersonalIdType = EmployeePersonalInfoSaveRequest.idfPersonalIDType != null && EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString() != string.Empty ? long.Parse(EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString()) : null;
            DuplicateCheckRequest.PersonalIDValue = EmployeePersonalInfoSaveRequest.strPersonalID;
            DuplicateCheckRequest.OrganizationID = EmployeePersonalInfoSaveRequest.idfInstitution;
            DuplicateCheckRequest.Page = 1;
            DuplicateCheckRequest.PageSize = 10;
            DuplicateCheckRequest.SortOrder = "ASC";
            DuplicateCheckRequest.SortColumn = "EmployeeID";
            List<EmployeeListViewModel> duplicateResponse = await EmployeeClient.GetEmployeeList(DuplicateCheckRequest);
            if (duplicateResponse != null && duplicateResponse.Count > 0)
            {
                EmployeePersonalInfoSaveRequest.idfPerson = duplicateResponse.FirstOrDefault().EmployeeID;
                response.RetunMessage = "DOES EXIST";
                string duplicate_Field = "";
                duplicate_Field = duplicateResponse.FirstOrDefault().LastOrSurName != null && duplicateResponse.FirstOrDefault().LastOrSurName != "" ? duplicateResponse.FirstOrDefault().LastOrSurName : "";
                duplicate_Field += duplicateResponse.FirstOrDefault().FirstOrGivenName != null && duplicateResponse.FirstOrDefault().FirstOrGivenName != "" ? " " + duplicateResponse.FirstOrDefault().FirstOrGivenName : "";
                duplicate_Field += duplicateResponse.FirstOrDefault().OrganizationID != null && duplicateResponse.FirstOrDefault().OrganizationID != 0 ? " " + duplicateResponse.FirstOrDefault().OrganizationAbbreviatedName : "";
                duplicate_Field += EmployeePersonalInfoSaveRequest.idfPersonalIDType != null && EmployeePersonalInfoSaveRequest.idfPersonalIDType != "" ? " " + EmployeePersonalInfoSaveRequest.idfPersonalIDTypeText : "";
                duplicate_Field += EmployeePersonalInfoSaveRequest.strPersonalID != null && EmployeePersonalInfoSaveRequest.strPersonalID != "" ? " " + EmployeePersonalInfoSaveRequest.strPersonalID : "";
                response.DuplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), duplicate_Field);
            }
            else
            {
                response = await EmployeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);
            }
            return response;
        }
        protected async Task ShowSuccessMessage()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }
        protected async Task ShowDuplicateMessage(string message)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>();
            dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
            dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(message));
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

    }
}
