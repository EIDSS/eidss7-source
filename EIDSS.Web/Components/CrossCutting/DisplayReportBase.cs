#region Usings

using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using static System.String;

#endregion

namespace EIDSS.Web.Components.CrossCutting
{
    public class DisplayReportBase : BaseComponent
    {
        #region Dependencies

        [Inject] private IConfiguration ConfigurationService { get; set; }
        
        [Inject] protected TimeZoneService TimeZoneService { get; set; }

        [Inject] private IHttpContextAccessor HttpContextAccessor { get; set; }

        #endregion

        #region Parameters

        [Parameter] public string ReportHeader { get; set; }
        [Parameter] public string ReportName { get; set; }
        [Parameter] public List<KeyValuePair<string, string>> Parameters { get; set; }
        [Parameter] public string ParametersJson { get; set; }
        [Parameter] public CultureInfo Culture { get; set; }
        [Parameter] public bool CancelButtonVisibleIndicator { get; set; }
        [Parameter] public bool RefreshComponent { get; set; }

        #endregion

        #region Properties

        protected RadzenSSRSViewer Viewer { get; set; } = new RadzenSSRSViewer();
        protected string ReportServer { get; set; }
        private string ReportPath { get; set; }
        protected bool UseProxy { get; set; }

        private const string PrintDateTimeKey = "PRINTDATETIME";

        #endregion

        #region Member Variables

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            var usCultureInfo = new CultureInfo("en-US");
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            var browserLanguage = "en-US";

            if (HttpContextAccessor.HttpContext != null)
            {
                var languages = HttpContextAccessor.HttpContext.Request.GetTypedHeaders()
                    .AcceptLanguage
                    ?.OrderByDescending(x =>
                        x.Quality ?? 1) // Quality defines priority from 0 to 1, where 1 is the highest.
                    .Select(x => x.Value.ToString())
                    .ToArray() ?? Array.Empty<string>();
                var bLanguage = languages.FirstOrDefault();
                browserLanguage = bLanguage switch
                {
                    "ka" => "ka-GE",
                    "az" => "az-Latn-AZ",
                    "ru" => "ru-RU",
                    "en" => "en-US",
                    _ => "en-US"
                };
            }

            string[] languageArray = { "az-Latn-AZ", "en-US", "ka-GE", "ru-RU", "ar-JO" };

            if (Parameters is null)
            {
                if (!IsNullOrEmpty(ParametersJson))
                {
                    Parameters = System.Text.Json.JsonSerializer.Deserialize<List<KeyValuePair<string, string>>>(ParametersJson);
                }
            }

            var bPrintDateExists = false;
            cultureInfo.DateTimeFormat.GetAllDateTimePatterns();
            usCultureInfo.DateTimeFormat.GetAllDateTimePatterns();
            if (Parameters != null)
            {
                var updatedParameters = new List<KeyValuePair<string, string>>();
                foreach (var (key, value) in Parameters)
                {
                    var isShortDate = key.ToUpper() != PrintDateTimeKey;
                    GetLocalizedDate(languageArray, value, browserLanguage, out var resultValue, isShortDate);
                    updatedParameters.Add(!IsNullOrEmpty(resultValue)
                        ? new KeyValuePair<string, string>(key, resultValue)
                        : new KeyValuePair<string, string>(key, HttpUtility.UrlEncode(value)));
                }

                Parameters = updatedParameters;

                if (Parameters.Any(kvp => kvp.Key.ToUpper() == PrintDateTimeKey))
                {
                    bPrintDateExists = true;
                }
                if (!bPrintDateExists)
                {
                   var clientDate= await TimeZoneService.GetLocalDate();
                   

                    // Add ClientDate as parameter. Passing the Culture as en-US as the report serer will take care of the Culture based on language Parameter
                    Parameters?.Add(new KeyValuePair<string, string>("PrintDateTime",
                        clientDate.ToString(CultureInfo.GetCultureInfo(browserLanguage))));
                }
            }

            ReportServer = ConfigurationService.GetValue<string>("ReportServer:Url");
            UseProxy = ConfigurationService.GetValue<bool>("ReportServer:UseProxy");

            ReportPath = ConfigurationService.GetValue<string>("ReportServer:Path").Replace("/", Empty);
            if (ReportName.Contains(ReportPath))
            {
                if (ReportName.StartsWith("/"))
                    ReportName = ReportName.Remove(0, 1);
            }
            else
                ReportName = ReportPath + "/" + ReportName;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override void OnAfterRender(bool firstRender)
        {
            if (!firstRender)
            {
                Viewer.DefaultCulture = Culture;

                if (IsNullOrEmpty(ReportPath))
                {
                    ReportPath = ConfigurationService.GetValue<string>("ReportServer:Path").Replace("/", Empty);
                    if (ReportName.Contains(ReportPath))
                        ReportName = ReportName.Remove(0, 1);
                    else
                        ReportName = ReportPath + "/" + ReportName;
                }

                Viewer.ReportName = ReportName;
                Viewer.ReportServer = ReportServer;
                Viewer.UseProxy = UseProxy;

                if (RefreshComponent)
                {
                    StateHasChanged();
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
        }

        #endregion

        #region Cancel Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage) }
                };

                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
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

        private static void GetLocalizedDate(IEnumerable<string> languages, string dateValue, string browserLanguage,
            out string returnDateValue, bool isShortDate)
        {
            returnDateValue = "";
            foreach (var lan in languages)
            {
                var culture = new CultureInfo(lan);
                var formats = culture.DateTimeFormat.GetAllDateTimePatterns();
                if (!DateTime.TryParseExact(dateValue, formats, culture, DateTimeStyles.None, out var outDateValue))
                    continue;
                outDateValue = Convert.ToDateTime(outDateValue, new CultureInfo(browserLanguage));
                returnDateValue = isShortDate ? outDateValue.ToString("d", new CultureInfo(browserLanguage)) : outDateValue.ToString(new CultureInfo(browserLanguage));
                break;
            }
        }
    }
}