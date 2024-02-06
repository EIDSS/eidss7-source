using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "SystemFunctionsView")]
    public class SystemFunctionsViewComponent : ViewComponent
    {
        readonly private ICrossCuttingClient _crossCuttingClient;
        readonly private ISettlementClient _settlementClient;
        readonly private ICrossCuttingService _crossCuttingService;
        private IConfiguration _configuration;
        public IConfiguration Configuration { get { return _configuration; } }
        public SystemFunctionsPagesViewModel _systemFunctionViewModel { get; set; }
        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        public string CurrentLanguage { get; set; }
        public string  CountryId { get; set; }
        private readonly ITokenService _tokenService;
        private readonly AuthenticatedUser _authenticatedUser;


        public SystemFunctionsViewComponent(ICrossCuttingClient crossCuttingClient, ISettlementClient settlementClient,IConfiguration configuration,ICrossCuttingService crossCuttingService, ITokenService tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _settlementClient = settlementClient;
            _crossCuttingService = crossCuttingService;
            _tokenService = tokenService;
            _configuration = configuration;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

            CurrentLanguage = cultureInfo.Name;
        }

        public async Task<IViewComponentResult> InvokeAsync(SystemFunctionsPagesViewModel systemFunctionsPagesViewModel)
        {
            _systemFunctionViewModel = systemFunctionsPagesViewModel;
            var SystemFunctionPermissions = await _crossCuttingClient.GetSystemFunctionPermissions(CurrentLanguage,null);

           // SystemFunctionPermissions = SystemFunctionPermissions.OrderBy(a => a.strSystemFunction).ToList();


            var LoggedInUserPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions(_authenticatedUser.PersonId, CurrentLanguage);
            var UserGroupPermissions = new List<SystemFunctionPermissionsViewModel>();
            if (_systemFunctionViewModel.UserIDAndUserGroups == "-1")
                UserGroupPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions("0", CurrentLanguage);
            else
                UserGroupPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions(_systemFunctionViewModel.EmployeeID.ToString(), CurrentLanguage);

            if (_systemFunctionViewModel.isChange)
            {
                UserGroupPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions(_systemFunctionViewModel.UserIDAndUserGroups, CurrentLanguage);
            }
            else if(UserGroupPermissions!=null && UserGroupPermissions.Count()==0 && !_systemFunctionViewModel.isChange)
            {
                UserGroupPermissions = await _crossCuttingClient.GetUserGroupUserSystemFunctionPermissions(_systemFunctionViewModel.UserIDAndUserGroups, CurrentLanguage);
            }
           // UserGroupPermissions = UserGroupPermissions.OrderBy(a => a.Permission).ToList();
            List<SystemFunctionPermissionsPageViewModel> lstSytemFuncPermModel = new List<SystemFunctionPermissionsPageViewModel>();
            try
            {
                SystemFunctionPermissionsPageViewModel svm = new SystemFunctionPermissionsPageViewModel();
                if (UserGroupPermissions.Count > 0)
                {                   
                    for (int i = 0; i < SystemFunctionPermissions.Count(); i++)
                    {
                        long systemFunctionId = SystemFunctionPermissions[i].SystemFunctionID;
                        var lstUserGroupPermissions = UserGroupPermissions.Where(a => a.SystemFunctionId == systemFunctionId);
                        var lstSystemFunctions = SystemFunctionPermissions.Where(a => a.SystemFunctionID == systemFunctionId);
                        var lstLoggedInUserPermissions = LoggedInUserPermissions.Where(a => a.SystemFunctionId == systemFunctionId).ToList().FirstOrDefault();
                        svm = new SystemFunctionPermissionsPageViewModel();
                        svm.SystemFunctionId = systemFunctionId;
                        svm.Permission = SystemFunctionPermissions[i].strSystemFunction;
                        if (lstUserGroupPermissions.Count() > 0)
                        {
                            foreach (var item in lstUserGroupPermissions)
                            {
                                var lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long) PermissionLevelEnum.Read).ToList();
                                if (lstSystemFunctionsOps.Count()>0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasReadPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.ReadPermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasReadPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasReadPermission)
                                        svm.ReadPermission = UpdatePermission(svm.HasReadPermission, (long)PermissionLevelEnum.Read, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                 }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Write).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasWritePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.WritePermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasWritePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }
                                if (svm.HasWritePermission)
                                    svm.WritePermission = UpdatePermission(svm.HasWritePermission, (long)PermissionLevelEnum.Write, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Create).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasCreatePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.CreatePermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasCreatePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasCreatePermission)
                                        svm.CreatePermission = UpdatePermission(svm.HasCreatePermission, (long)PermissionLevelEnum.Create, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                 }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Delete).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasDeletePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.DeletePermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasDeletePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasDeletePermission)
                                        svm.DeletePermission = UpdatePermission(svm.HasDeletePermission, (long)PermissionLevelEnum.Delete, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                 }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Execute).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasExecutePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.ExecutePermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasExecutePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasExecutePermission)
                                        svm.ExecutePermission = UpdatePermission(svm.HasExecutePermission, (long)PermissionLevelEnum.Execute, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToGenderAndAgeData).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasAccessToGenderAndAgeDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.AccessToGenderAndAgeDataPermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasAccessToGenderAndAgeDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasAccessToGenderAndAgeDataPermission)
                                        svm.AccessToGenderAndAgeDataPermission = UpdatePermission(svm.HasAccessToGenderAndAgeDataPermission, (long)PermissionLevelEnum.AccessToGenderAndAgeData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                }
                                lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToPersonalData).ToList();
                                if (lstSystemFunctionsOps.Count() > 0)
                                {
                                    if (lstLoggedInUserPermissions != null)
                                    {
                                        svm.HasAccessToPersonalDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.AccessToPersonalDataPermission == 0 ? true : false;
                                    }
                                    else
                                    {
                                        svm.HasAccessToPersonalDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                    }
                                    if (svm.HasAccessToPersonalDataPermission)
                                        svm.AccessToPersonalDataPermission = UpdatePermission(svm.HasAccessToPersonalDataPermission, (long)PermissionLevelEnum.AccessToPersonalData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                                }
                            }
                        }
                        else
                        {
                            var lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Read).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasReadPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.ReadPermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasReadPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }                               
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Write).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasWritePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.WritePermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasWritePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }                               
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Create).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasCreatePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.CreatePermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasCreatePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Delete).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasDeletePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.DeletePermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasDeletePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }                                
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Execute).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasExecutePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.ExecutePermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasExecutePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }                               
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToGenderAndAgeData).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasAccessToGenderAndAgeDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.AccessToGenderAndAgeDataPermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasAccessToGenderAndAgeDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }                            
                            }
                            lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToPersonalData).ToList();
                            if (lstSystemFunctionsOps.Count() > 0)
                            {
                                if (lstLoggedInUserPermissions != null)
                                {
                                    svm.HasAccessToPersonalDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.AccessToPersonalDataPermission == 0 ? true : false;
                                }
                                else
                                {
                                    svm.HasAccessToPersonalDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                                }
                            }
                            //var lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Read).ToList();
                            //if(lstSystemFunctionsOps.Count()>0)
                            //    svm.HasReadPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Write).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0)
                            //    svm.HasWritePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Create).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0)
                            //    svm.HasCreatePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Execute).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0 && lstLoggedInUserPermissions!=null)
                            //    svm.HasExecutePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 && lstLoggedInUserPermissions.ExecutePermission == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.Delete).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0)
                            //    svm.HasDeletePermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToGenderAndAgeData).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0)
                            //    svm.HasAccessToGenderAndAgeDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;
                            //lstSystemFunctionsOps = lstSystemFunctions.Where(a => a.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToPersonalData).ToList();
                            //if (lstSystemFunctionsOps.Count() > 0)
                            //    svm.HasAccessToPersonalDataPermission = lstSystemFunctionsOps.FirstOrDefault().intRowStatus == 0 ? true : false;

                            ////if (svm.HasReadPermission)
                            ////    svm.ReadPermission = UpdatePermission(svm.HasReadPermission, (long)PermissionLevelEnum.Read, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            //////}
                            ////  else if (item.WritePermission == (long)PermissionLevelEnum.Write)
                            //// {
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasWritePermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.WritePermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasWritePermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            //if (svm.HasWritePermission)
                            //    svm.WritePermission = UpdatePermission(svm.HasWritePermission, (long)PermissionLevelEnum.Write, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            //// }
                            ////else if (item.CreatePermission == (long)PermissionLevelEnum.Create)
                            ////  {
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasCreatePermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.CreatePermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasCreatePermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            ////if (svm.HasCreatePermission)
                            ////    svm.CreatePermission = UpdatePermission(svm.HasCreatePermission, (long)PermissionLevelEnum.Create, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            ////// }
                            //// else if (item.DeletePermission == (long)PermissionLevelEnum.Delete)
                            ////{
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasDeletePermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.DeletePermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasDeletePermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            ////if (svm.HasDeletePermission)
                            ////    svm.DeletePermission = UpdatePermission(svm.HasDeletePermission, (long)PermissionLevelEnum.Delete, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            ////// }
                            ////else if (item.ExecutePermission == (long)PermissionLevelEnum.Execute)
                            ////{
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasExecutePermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.ExecutePermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasExecutePermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            ////if (svm.HasExecutePermission)
                            ////    svm.ExecutePermission = UpdatePermission(svm.HasExecutePermission, (long)PermissionLevelEnum.Execute, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            ////// }
                            ////else if (item.AccessToGenderAndAgeDataPermission == (long)PermissionLevelEnum.AccessToGenderAndAgeData)
                            ////{
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasAccessToGenderAndAgeDataPermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.AccessToGenderAndAgeDataPermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasAccessToGenderAndAgeDataPermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            ////if (svm.HasAccessToGenderAndAgeDataPermission)
                            ////    svm.AccessToGenderAndAgeDataPermission = UpdatePermission(svm.HasAccessToGenderAndAgeDataPermission, (long)PermissionLevelEnum.AccessToGenderAndAgeData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            //////}
                            ////else if (item.AccessToPersonalDataPermission == (long)PermissionLevelEnum.AccessToPersonalData)
                            ////{
                            //if (lstLoggedInUserPermissions != null)
                            //{
                            //    svm.HasAccessToPersonalDataPermission = SystemFunctionPermissions[i].intRowStatus == 0 && lstLoggedInUserPermissions.AccessToPersonalDataPermission == 0 ? true : false;
                            //}
                            //else
                            //{
                            //    svm.HasAccessToPersonalDataPermission = SystemFunctionPermissions[i].intRowStatus == 0 ? true : false;
                            //}
                            //if (svm.HasAccessToPersonalDataPermission)
                            //    svm.AccessToPersonalDataPermission = UpdatePermission(svm.HasAccessToPersonalDataPermission, (long)PermissionLevelEnum.AccessToPersonalData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
                            // }
                        }

                        var isFunctionExist = lstSytemFuncPermModel.Any(a => a.SystemFunctionId == systemFunctionId);
                        if (!isFunctionExist)
                            lstSytemFuncPermModel.Add(svm);

                    }
                }

               //else if (UserGroupPermissions.Count > 0)
               // {
               //     SystemFunctionPermissionsPageViewModel svm = new SystemFunctionPermissionsPageViewModel();
               //     for (int i = 0; i < UserGroupPermissions.Count(); i++)
               //     {
               //         long systemFunctionId = UserGroupPermissions[i].SystemFunctionId;
               //         var lstUserGroupPermissions = UserGroupPermissions.Where(a => a.SystemFunctionId == systemFunctionId);
               //         var lstSystemFunctions = SystemFunctionPermissions.Where(a => a.SystemFunctionID == systemFunctionId);
               //         var lstLoggedInUserPermissions=LoggedInUserPermissions.Where(a=>a.SystemFunctionId==systemFunctionId).ToList().FirstOrDefault();
               //         svm = new SystemFunctionPermissionsPageViewModel();
               //         svm.SystemFunctionId = systemFunctionId;
               //         svm.Permission = UserGroupPermissions[i].Permission;
               //         foreach (var item in lstSystemFunctions)
               //         {
               //             if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.Read)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasReadPermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.ReadPermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasReadPermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasReadPermission)
               //                     svm.ReadPermission = UpdatePermission(svm.HasReadPermission, (long)PermissionLevelEnum.Read, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.Write)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasWritePermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.WritePermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasWritePermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasWritePermission)
               //                     svm.WritePermission = UpdatePermission(svm.HasWritePermission, (long)PermissionLevelEnum.Write, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.Create)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasCreatePermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.CreatePermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasCreatePermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasCreatePermission)
               //                     svm.CreatePermission = UpdatePermission(svm.HasCreatePermission, (long)PermissionLevelEnum.Create, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.Delete)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasDeletePermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.DeletePermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasDeletePermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasDeletePermission)
               //                     svm.DeletePermission = UpdatePermission(svm.HasDeletePermission, (long)PermissionLevelEnum.Delete, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.Execute)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasExecutePermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.ExecutePermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasExecutePermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasExecutePermission)
               //                     svm.ExecutePermission = UpdatePermission(svm.HasExecutePermission, (long)PermissionLevelEnum.Execute, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToGenderAndAgeData)
               //             {
               //                 if (lstLoggedInUserPermissions != null )
               //                 {
               //                     svm.HasAccessToGenderAndAgeDataPermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.AccessToGenderAndAgeDataPermission == 0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasAccessToGenderAndAgeDataPermission = item.intRowStatus == 0  ? true : false;
               //                 }
               //                 if (svm.HasAccessToGenderAndAgeDataPermission)
               //                     svm.AccessToGenderAndAgeDataPermission = UpdatePermission(svm.HasAccessToGenderAndAgeDataPermission, (long)PermissionLevelEnum.AccessToGenderAndAgeData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID);
               //             }
               //             else if (item.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToPersonalData)
               //             {
               //                 if (lstLoggedInUserPermissions != null)
               //                 {
               //                     svm.HasAccessToPersonalDataPermission = item.intRowStatus == 0 && lstLoggedInUserPermissions.AccessToPersonalDataPermission==0 ? true : false;
               //                 }
               //                 else
               //                 {
               //                     svm.HasAccessToPersonalDataPermission = item.intRowStatus == 0 ? true : false;
               //                 }
               //                 if (svm.HasAccessToPersonalDataPermission)
               //                     svm.AccessToPersonalDataPermission = UpdatePermission(svm.HasAccessToPersonalDataPermission, (long)PermissionLevelEnum.AccessToPersonalData, lstUserGroupPermissions, _systemFunctionViewModel.EmployeeID); }

               //         }

               //         var isExist = lstSytemFuncPermModel.Any(a => a.SystemFunctionId == systemFunctionId);
               //         if (!isExist)
               //             lstSytemFuncPermModel.Add(svm);

               //     }
               // }
                else
                {
                    foreach (var item in SystemFunctionPermissions)
                    {
                        svm = new SystemFunctionPermissionsPageViewModel();
                        svm.SystemFunctionId = item.SystemFunctionID;
                        svm.Permission = item.strSystemFunction;
                        var lstSystemFunctions = SystemFunctionPermissions.Where(a => a.SystemFunctionID == svm.SystemFunctionId);
                        foreach (var op in lstSystemFunctions)
                        {
                            if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.Read)
                            {
                                svm.HasReadPermission = op.intRowStatus == 0 ? true : false;
                               
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.Write)
                            {
                                svm.HasWritePermission = op.intRowStatus == 0 ? true : false;
                              
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.Create)
                            {
                                svm.HasCreatePermission = op.intRowStatus == 0 ? true : false;
                                
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.Delete)
                            {
                                svm.HasDeletePermission = op.intRowStatus == 0 ? true : false;
                               
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.Execute)
                            {
                                svm.HasExecutePermission = op.intRowStatus == 0 ? true : false;
                               
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToGenderAndAgeData)
                            {
                                svm.HasAccessToGenderAndAgeDataPermission = op.intRowStatus == 0 ? true : false;
                               
                            }
                            else if (op.SystemFunctionOperationID == (long)PermissionLevelEnum.AccessToPersonalData)
                            {
                                svm.HasAccessToPersonalDataPermission = op.intRowStatus == 0 ? true : false;                              
                            }
                            var isExist = lstSytemFuncPermModel.Any(a => a.SystemFunctionId == svm.SystemFunctionId);
                            if (!isExist)
                                lstSytemFuncPermModel.Add(svm);
                        }                       
                    }
                    
                }

                _systemFunctionViewModel.PermissionViewModel = lstSytemFuncPermModel;
                //_systemFunctionViewModel.PermissionViewModel = lstSytemFuncPermModel.OrderBy(a=>a.Permission).ToList();
            }
            catch (Exception)
            {

            }           

             return View(_systemFunctionViewModel);
        }
        private bool UpdatePermission(bool PermissionType,long permission,IEnumerable<SystemFunctionPermissionsViewModel> LstPermissions,long EmployeeID)
        {
            bool permFlag = false;
            if (PermissionType)
            {
                foreach (var perm in LstPermissions)
                {
                    switch (permission)
                    {
                        case (long) PermissionLevelEnum.Read:
                            permFlag = perm.ReadPermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.ReadPermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.ReadPermission == 1)
                            //        permFlag = perm.ReadPermission == 1 ? false : true;
                            //}
                            break;
                        case (long) PermissionLevelEnum.Write:

                            permFlag = perm.WritePermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.WritePermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.WritePermission == 1)
                            //        permFlag = perm.WritePermission == 1 ? false : true;
                            //}
                            break;
                        case (long)PermissionLevelEnum.Create:
                            permFlag = perm.CreatePermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.CreatePermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.CreatePermission == 1)
                            //        permFlag = perm.CreatePermission == 1 ? false : true;
                            //}
                            break;
                        case (long)PermissionLevelEnum.Delete:
                            permFlag = perm.DeletePermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.DeletePermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.DeletePermission == 1)
                            //        permFlag = perm.DeletePermission == 1 ? false : true;
                            //}
                            break;
                        case (long)PermissionLevelEnum.Execute:
                            permFlag = perm.ExecutePermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.ExecutePermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.ExecutePermission == 1)
                            //        permFlag = perm.ExecutePermission == 1 ? false : true;
                            //}
                            break;
                        case (long)PermissionLevelEnum.AccessToPersonalData:
                            permFlag = perm.AccessToPersonalDataPermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.AccessToPersonalDataPermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag && perm.AccessToPersonalDataPermission == 1)
                            //        permFlag = perm.AccessToPersonalDataPermission == 1 ? false : true;
                            //}
                            break;
                        case (long)PermissionLevelEnum.AccessToGenderAndAgeData:
                            permFlag = perm.AccessToGenderAndAgeDataPermission == 0 ? true : false;
                            //if (perm.RoleID == EmployeeID)
                            //{
                            //    permFlag = perm.AccessToGenderAndAgeDataPermission == 1 ? false : true;
                            //    break;
                            //}
                            //else
                            //{
                            //    if (!permFlag&& perm.AccessToGenderAndAgeDataPermission == 1)
                            //        permFlag = perm.AccessToGenderAndAgeDataPermission == 1 ? false : true;
                            //}
                            break;
                        default:
                            break;
                    }
                } 
            }
            return permFlag;
        }
    }
}


