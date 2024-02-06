using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Newtonsoft.Json.Linq;
using Radzen;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.StatisticalData
{
    public class FileUploadDialogBase : BaseComponent
    {
        #region Dependencies

        [Inject] protected IStatisticalDataClient StatisticalDataClient { get; set; }
        [Inject] protected Radzen.DialogService _dialogService { get; set; }
        [Inject] protected ILogger<FileUploadDialogBase> Logger { get; set; }        
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public string Information { get; set; }
        [Parameter] public string informationVisibility { get; set; }
        [Parameter] public string returnMsgInformationVisibility { get; set; }
        [Parameter] public List<string> returnMessages { get; set; }
        [Parameter] public StatisticalDataFileModel _InstatisticalDataFileModel { get; set; }
        [Parameter] public UserPermissions userPermissions { get; set; }
        [Parameter] public StatisticalDataFileModel _statisticalDataFileModel { get; set; }
        [Parameter] public String Username { get; set; }        
        [Parameter] public bool IsIncorrectFileFormat { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        protected override async Task OnInitializedAsync()
        {
            userPermissions = GetUserPermissions(PagePermission.AccessToStatisticsList);
            
            //if (userPermissions.Execute)
            //{

            //}

            _logger = Logger;
            _source = new();
            _token = _source.Token;

            Information = Localizer.GetString(MessageResourceKeyConstants.StatisticalDataImportdataMessage);
            authenticatedUser = _tokenService.GetAuthenticatedUser();

            //Default Date Settings
            informationVisibility = "visible;";
            returnMsgInformationVisibility = "hidden;";

            if(_statisticalDataFileModel.ErrorCount == 0)
            {
                await SaveStatisticalDataFromImport(_statisticalDataFileModel);
            }


            await base.OnInitializedAsync();            
        }

        public async Task SaveStatisticalDataFromImport(StatisticalDataFileModel saveModel)
        {
            returnMessages = new List<string>();
            int addedRecs = 0;
            List<USP_ADMIN_STAT_SETResultResponseModel> response = new List<USP_ADMIN_STAT_SETResultResponseModel>();
            USP_ADMIN_STAT_SETResultRequestModel request = new USP_ADMIN_STAT_SETResultRequestModel();

            try
            {
                StringBuilder sb = new StringBuilder();
                if (saveModel.GoodRows != null)
                {
                    long siteId = Convert.ToInt64(authenticatedUser.SiteId);
                    long userId = Convert.ToInt64(authenticatedUser.EIDSSUserId);

                    for (int i = 0; i < saveModel.GoodRows.Count; i++)
                    {
                        if (saveModel.GoodRows[i].idfsStatisticDataType != null &
                            saveModel.GoodRows[i].idfsStatisticPeriodType != null &
                            saveModel.GoodRows[i].datStatisticStartDate != null &
                            saveModel.GoodRows[i].idfsStatisticAreaType != null &
                            saveModel.GoodRows[i].LocationUserControlidfsCountry != null)
                        {
                            saveModel.GoodRows[i].SiteId = siteId;
                            saveModel.GoodRows[i].UserId = userId;

                            response = await StatisticalDataClient.SaveStatisticalData(saveModel.GoodRows[i]);

                            if (response[0].ReturnMessage == "DOES EXIST")
                            {
                                returnMessages.Add("Row " + i.ToString() + " " + Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage).Value.Replace("with {0}", " "));
                                //String.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), sb.ToString());
                            }
                            else if (response[0].ReturnMessage == "SUCCESS")
                            {                               
                                addedRecs++;
                            }
                        }
                    }

                    if (saveModel.ErrorCount > 0)
                    {
                        Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);

                        dynamic result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage, null, ButtonResourceKeyConstants.OKButton, null, null);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                            {
                                await InvokeAsync(StateHasChanged);
                                DiagService.Close();
                                _source?.Cancel();
                            }
                        }
                    }
                }                
                //StateHasChanged();               
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }

            //_dialogService.Close();
        }
    }
}


