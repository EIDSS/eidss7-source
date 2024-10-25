#region Usings

using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Razor.TagHelpers;
using Microsoft.Extensions.Localization;
using System;
using System.Globalization;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading;

#endregion

namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-calendar", Attributes = "asp-for")]
    [HtmlTargetElement("eidss-calendar", Attributes = "language")]
    [HtmlTargetElement("eidss-calendar", Attributes = "min-date")]
    [HtmlTargetElement("eidss-calendar", Attributes = "max-date")]

    public class EIDSSCalendarTagHelper : TagHelper
    {
        [HtmlAttributeName("name")]
        public string Name { get; set; }
        [HtmlAttributeName("id")]
        public string Id { get; set; }

        [HtmlAttributeName("dates-ids-to_validate")]
        public string DatesIdsToValidate { get; set; }

        public override int Order => 100;

        public string CssClass { get; set; }

        [HtmlAttributeName("min-date")]
        public string MinDate { get; set; }

        [HtmlAttributeName("max-date")]
        public string MaxDate { get; set; }

        public string YearRange { get; set; } = string.Format("-{0}:+{1}", DateTime.Now.Year - 1900, 79);

        [HtmlAttributeName("asp-for")]
        public ModelExpression AspFor { get; set; }

        [HtmlAttributeName("language")]
        public ModelExpression Language { get; set; }

        [HtmlAttributeName("disabled")]
        public bool Disabled { get; set; } = false;

        [HtmlAttributeName("clear-button")]
        public bool ClearButton { get; set; } = false;

        private readonly IStringLocalizer Localizer;

        protected static CultureInfo CurrentCulture => Thread.CurrentThread.CurrentCulture;

        private IServiceProvider ServiceProvider { get; set; }

        private LocalizationMemoryCacheProvider CacheProvider;
        private string strFirstDate { get; set; }
        private string strSecondDate { get; set; }
        private string strDataValErrorMessage { get; set; }

        private string strFutureDateValErrorMessage { get; set; }

        public EIDSSCalendarTagHelper(IStringLocalizer localizer, IServiceProvider serviceProvider)
        {
            Localizer = localizer;
            ServiceProvider = serviceProvider;
        }

        private static string GetPropertyValue(string FieldName, Type src)
        {
            try
            {
                if (src.GetField(FieldName) != null)
                {
                    return src.GetField(FieldName).GetValue(src).ToString();
                }
                else
                {
                    return FieldName;
                }
            }
            catch
            {
                return FieldName;
            }
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            output.TagMode = TagMode.StartTagAndEndTag;

            var preElement = new StringBuilder();
            preElement.AppendLine("<div class=\"input-group flex-nowrap\">");
            output.PreElement.AppendHtml(preElement.ToString());

            output.TagName = "input";

            output.Attributes.SetAttribute("type", "text");

            if (!string.IsNullOrEmpty(Id))
            {
                output.Attributes.SetAttribute("id", Id.Replace(".", "_"));
            }

            if (!string.IsNullOrEmpty(Name))
            {
                output.Attributes.SetAttribute("name", Name);
            }

            if (!string.IsNullOrEmpty(CssClass))
            {
                output.Attributes.SetAttribute("class", CssClass);
            }

            if (Disabled)
            {
                output.Attributes.SetAttribute("disabled", "disabled");
            }

            if (AspFor.Model is DateTime currentValue)
            {
                output.Attributes.Add("value", currentValue.ToShortDateString());
            }
            else
            {
                output.Attributes.Add("value", AspFor.Model);
            }

            if ((AspFor != null) && (AspFor.Metadata.ValidatorMetadata.Count > 0))
            {
                output.Attributes.Add("data-val", "true");

                foreach (object validator in AspFor.Metadata.ValidatorMetadata)
                {
                    switch (validator.GetType().Name)
                    {
                        case nameof(Localization.Helpers.DateComparerAttribute):
                            CacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

                            var dateComparerAttribute = AspFor.Metadata.ValidatorMetadata.OfType<Localization.Helpers.DateComparerAttribute>().FirstOrDefault();

                            strFirstDate = Localizer.GetString(GetPropertyValue(dateComparerAttribute.FirstDateLabel, typeof(FieldLabelResourceKeyConstants)));
                            strSecondDate = Localizer.GetString(GetPropertyValue(dateComparerAttribute.SecondDateLabel, typeof(FieldLabelResourceKeyConstants)));

                            if (dateComparerAttribute.Compare == CompareTypeEnum.GreaterThanOrEqualTo)
                            {
                                if (Language == null || Language.Model == null)
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.Date2MustBeSameOrLaterThanDate1Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                                }
                                else
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(Language.Model.ToString(), MessageResourceKeyConstants.Date2MustBeSameOrLaterThanDate1Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Language);
                                }
                            }

                            if (dateComparerAttribute.Compare == CompareTypeEnum.LessThanOrEqualTo)
                            {
                                if (Language == null || Language.Model == null)
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.Date1MustBeSameOrEarlierThanDate2Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                                }
                                else
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(Language.Model.ToString(), MessageResourceKeyConstants.Date1MustBeSameOrEarlierThanDate2Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Language.Model.ToString());
                                }
                            }

                            if (dateComparerAttribute.Compare == CompareTypeEnum.GreaterThan)
                            {
                                if (Language == null || Language.Model == null)
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.Date2MustBeSameOrLaterThanDate1Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                                }
                                else
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(Language.Model.ToString(), MessageResourceKeyConstants.Date2MustBeSameOrLaterThanDate1Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Language.Model.ToString());
                                }
                            }

                            if (dateComparerAttribute.Compare == CompareTypeEnum.LessThan)
                            {
                                if (Language == null || Language.Model == null)
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.Date1MustBeSameOrEarlierThanDate2Message), strFirstDate, strSecondDate);
                                    output.Attributes.Add("data-val-datecomparer-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                                }
                                else
                                {
                                    strDataValErrorMessage = string.Format(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(Language.Model.ToString(), MessageResourceKeyConstants.Date1MustBeSameOrEarlierThanDate2Message), strFirstDate, strSecondDate);

                                    output.Attributes.Add("data-val-datecomparer-language", Language.Model.ToString());
                                }
                            }
                            Console.Write(strDataValErrorMessage);
                            output.Attributes.Add("data-val-datecomparer", strDataValErrorMessage);
                            output.Attributes.Add("data-val-datecomparer-firstdate", dateComparerAttribute.FirstDateElement);
                            output.Attributes.Add("data-val-datecomparer-seconddate", dateComparerAttribute.SecondDateElement);
                            output.Attributes.Add("data-val-datecomparer-compare", dateComparerAttribute.Compare.ToString());

                            break;
                        case nameof(Localization.Helpers.DateBetweenAttribute):
                            var dateBetweenAttribute = AspFor.Metadata.ValidatorMetadata.OfType<Localization.Helpers.DateBetweenAttribute>().FirstOrDefault();
                            output.Attributes.Add("data-val-datebetween", dateBetweenAttribute.ValidationMessage);
                            output.Attributes.Add("data-val-datebetween-fromdate", dateBetweenAttribute.FromDateElement);
                            output.Attributes.Add("data-val-datebetween-todate", dateBetweenAttribute.ToDateElement);
                            output.Attributes.Add("data-val-datebetween-validationmessage", dateBetweenAttribute.ValidationMessage);
                            output.Attributes.Add("data-val-datebetween-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                            break;
                        case nameof(Localization.Helpers.LocalizedDateLessThanOrEqualToTodayAttribute):
                            strFutureDateValErrorMessage = Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage);
                            output.Attributes.Add("data-val-localizeddatelessthanorequaltotoday", Localizer.GetString(MessageResourceKeyConstants.FutureDatesAreNotAllowedMessage));
                            output.Attributes.Add("data-val-localizeddatelessthanorequaltotoday-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                            break;
                        case nameof(Localization.Helpers.IsValidDateAttribute):
                            output.Attributes.Add("data-val-isvaliddate", Localizer.GetString(MessageResourceKeyConstants.InvalidFieldMessage));
                            output.Attributes.Add("data-val-isvaliddate-language", Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName);
                            break;
                        case nameof(Localization.Helpers.LocalizedRequiredAttribute):
                            CacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
                            if (Language == null || Language.Model == null)
                                output.Attributes.Add("data-val-required", CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage));
                            else
                                output.Attributes.Add("data-val-required", CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(Language.Model.ToString(), MessageResourceKeyConstants.FieldIsRequiredMessage));
                            break;
                        case nameof(Localization.Helpers.LocalizedRequiredIfTrueAttribute):
                            var localizedRequiredIfTrueAttribute = AspFor.Metadata.ValidatorMetadata.OfType<Localization.Helpers.LocalizedRequiredIfTrueAttribute>().FirstOrDefault();

                            CacheProvider = (LocalizationMemoryCacheProvider)ServiceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

                            string propertyValue = (typeof(FieldLabelResourceKeyConstants).GetField(localizedRequiredIfTrueAttribute.PropertyName).GetValue(typeof(FieldLabelResourceKeyConstants))).ToString();
                            if (bool.TryParse(CacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, propertyValue), out bool isRequired))
                            {
                                if (isRequired)
                                {
                                    string errorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

                                    output.Attributes.Add("data-val-localizedrequirediftrue", errorMessage);
                                }
                            }
                            break;
                    }
                }
            }

            if (ClearButton)
            {
                var clearButtonHtml = new StringBuilder();
                clearButtonHtml.AppendLine("<button type=\"button\" class=\"ui-datepicker-trigger\" onclick=\"clearDateInput('" + Id.Replace(".", "_") + "')\"><i class=\"fas fa-times-circle\"></i></button>");
                output.PostContent.AppendHtml(clearButtonHtml.ToString());
            }

            var postContent = new StringBuilder();
            postContent.AppendLine("</div>");
            output.PostContent.AppendHtml(postContent.ToString());
            output.PostElement.AppendHtml(GenerateScript());
        }

        public string GenerateScript()
        {
            StringBuilder sb = new();

            sb.AppendLine("<script>");

            sb.AppendLine("$(document).ready(function() {");
            sb.AppendLine(" $('#" + Id.Replace(".", "_") + "').datepicker(");
            sb.AppendLine("$.extend({");
            sb.AppendLine("changeMonth: true ,");
            sb.AppendLine("changeYear: true, ");
            sb.AppendLine("showOn: \"both\", ");
            sb.AppendLine("yearRange: \"" + YearRange + "\", ");
            if (!string.IsNullOrEmpty(MinDate))
            {
                sb.AppendLine("minDate: \"" + MinDate + "\", ");
            }
            if (!string.IsNullOrEmpty(MaxDate))
            {
                sb.AppendLine("maxDate: \"" + MaxDate + "\", ");
            }

            sb.AppendLine("constrainInput: false, ");
            sb.AppendLine("buttonText: \"\", ");

            sb.AppendLine("beforeShow: function() {");
            sb.AppendLine("setTimeout(function(){");
            sb.AppendLine("$('.ui-datepicker').css('z-index', 9999);");
            sb.AppendLine("}, 0);");
            sb.AppendLine("}");

            sb.AppendLine("},");

            sb.AppendLine("$.datepicker.regional[\"" + CurrentCulture.TwoLetterISOLanguageName + "\"],");

            sb.AppendLine("{dateFormat: '" + CurrentCulture.DateTimeFormat.ToJavascriptShortDatePattern() + "'} ");
            
            sb.AppendLine(")).next('.ui-datepicker-trigger').addClass('flex-form-datepicker fas fa-calendar');");

            sb.AppendLine("$(document).on ('change close', '#" + Id.Replace(".", "_") + "', function(){");


            sb.AppendLine("$(this).valid();");
            if (!string.IsNullOrEmpty(DatesIdsToValidate))
            {
                var datesToValidate = DatesIdsToValidate.Split(",");
                foreach (var dateToValidate  in datesToValidate)
                {
                    sb.AppendLine("var dateToValidate=$('#" + dateToValidate + "');");
                    sb.AppendLine("if (!!$(dateToValidate )){ ");
                    sb.AppendLine("$(dateToValidate).valid();");
                    sb.AppendLine("}");
                }


            }
           
            sb.AppendLine("});");

            if (Disabled)
            {
                sb.AppendLine("$('#" + Id.Replace(".", "_") + "').datepicker( \"option\", \"disabled\", true ).next('.ui-datepicker-trigger').addClass('flex-form-datepicker fas fa-calendar');");
            }

            sb.AppendLine("});");

            sb.AppendLine("function clearDateInput(inputId) {");
            sb.AppendLine("$('#' + inputId).val(null).change();");
            sb.AppendLine("}");

            sb.AppendLine("</script>");
            return sb.ToString();
        }
    }
}