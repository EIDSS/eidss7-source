
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

        public EmployeePersonalInfoPageViewModel Model { get; set; }

        protected IEnumerable<BaseReferenceEditorsViewModel> lstPersonalIDType;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> lstOrganizations;
        protected IEnumerable<DepartmentGetListViewModel> lstDepartment;
        protected IEnumerable<BaseReferenceEditorsViewModel> lstPositions;
        protected RadzenTemplateForm<EmployeePersonalInfoPageViewModel> _form;

        protected int personalIDTypeCount { get; set; }

        protected int orgCount { get; set; }

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

           // EditContext.OnFieldChanged += EditContext_OnFieldChanged;

            Model = new EmployeePersonalInfoPageViewModel();

            if (OrganizationID is not null)
                Model.OrganizationID = OrganizationID;

            //EditContext = new(Model);
            await LoadPersonalTypeIDs(null);
            await LoadOrganizations(null);
            await LoadPositions(null);
        }



        public void Dispose()
        {

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



        public async Task LoadOrganizations(LoadDataArgs args)
        {
            try
            {

                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = null,
                };
                if (args != null && args.Filter != null && args.Filter != "")
                {
                    request.AdvancedSearch = args.Filter;
                }
                else
                    request.AdvancedSearch = null;
                var list = await OrganizationClient.GetOrganizationAdvancedList(request);
                lstOrganizations = list.AsODataEnumerable();
                orgCount = lstOrganizations.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }


        public async Task GetSiteDetails(long Value)
        {
            List<EmployeeSiteFromOrgViewModel> response = new List<EmployeeSiteFromOrgViewModel>();
            try
            {
                long? OrgID = 0;
                response = await EmployeeClient.GetEmployeeSiteFromOrg(Value);
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


        public async Task GetSiteNameAndDepartments(object value)
        {
            if (Model.OrganizationID != null && Model.OrganizationID != 0 && value != null)
            {
                long orgID = 0;
                DepartmentGetRequestModel model = new DepartmentGetRequestModel();
                model.LanguageId = GetCurrentLanguage();
                orgID = long.Parse(value.ToString());
                Model.OrganizationID = orgID;
                model.SortColumn = "intOrder";
                model.SortOrder = "asc";
                model.PageSize = 10000;
                model.Page = 1;
                var list = await CrossCuttingClient.GetDepartmentList(model);
                lstDepartment = list.AsODataEnumerable();
                departmentCount = lstDepartment.Count();
                EnableDepartment = false;

                // Load Site ID

                await GetSiteDetails(orgID);

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

                    //if (jsonObject["PersonalIDType"] != null && jsonObject["PersonalIDType"].ToString() != string.Empty)
                    //{
                    //    personalIDType = long.Parse(jsonObject["PersonalIDType"].ToString());
                    //}
                    //if (jsonObject["PersonalID"] != null)
                    //{
                    //    personalID = jsonObject["PersonalID"].ToString();
                    //}


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
                        //var list = response.Where(a => a.IdfPersonalIDType == personalIDType).ToList();
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
                   // var id = EditContext.Field("ValPersonaID");

                    //EditContext.NotifyFieldChanged(id);
                    await InvokeAsync(StateHasChanged);
                }
                else
                    IsPersonalIDInValid = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            //return isValid;
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
                //  || model.SearchCriteria.DateEnteredFrom != null)
                {

                    var newEmployee = _form.EditContext as EditContext;

                    EmployeeSaveRequestResponseModel response = await SaveNonUserEmployee(newEmployee);

                    if (response.RetunMessage == "Success")
                    {
                        await ShowSuccessMessage();
                        DiagService.Close(EditContext);
                    }
                    else if (response.RetunMessage == "DOES EXIST")
                    {
                        await ShowDuplicateMessage(response.DuplicateMessage);
                    }
                    await InvokeAsync(StateHasChanged);
                    

                }
                else
                {
                    //no search criteria entered - display the EIDSS dialog component
                    //searchSubmitted = false;
                    //await ShowNoSearchCriteriaDialog();
                }
            }
        }

        protected async Task HandleInvalidEmployeeSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {



                // var buttons = new List<DialogButton>();
                // var okButton = new DialogButton()
                // {
                //     ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                //     ButtonType = DialogButtonType.OK
                // };
                // buttons.Add(okButton);

                // //TODO - display the validation Errors on the dialog?  
                // var dialogParams = new Dictionary<string, object>();
                // dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                // dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage));
                //// await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                // var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                // if (result is DialogReturnResult)
                // {
                //     //do nothing because it is just the ok button
                // }


            }
            catch (Exception)
            {
                throw;
            }
        }
        public async Task<EmployeeSaveRequestResponseModel> SaveNonUserEmployee(EditContext result)
        {
            var newEmployee = result as EditContext;
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
                bool isValid = false;
                //if (EmployeePersonalInfoSaveRequest.strPersonalID != null && EmployeePersonalInfoSaveRequest.strPersonalID != "")
                //{
                //    isValid = await ValidatePersonalID(long.Parse(EmployeePersonalInfoSaveRequest.idfPersonalIDType), EmployeePersonalInfoSaveRequest.strPersonalID);
                //    if (!isValid)
                //    {
                //        response.RetunMessage = "ERROR";
                //        response.ValidationError = string.Format(Localizer.GetString(FieldLabelResourceKeyConstants.PersonalIDFieldLabel)) + ":" + string.Format(_localizer.GetString(MessageResourceKeyConstants.InvalidFieldMessage));
                //    }
                //}
                //else
                //{
                    isValid = true;
                //}
                if (isValid)
                    response = await EmployeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);
            }
            // return Json(response);
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
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(message));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

    }




}
