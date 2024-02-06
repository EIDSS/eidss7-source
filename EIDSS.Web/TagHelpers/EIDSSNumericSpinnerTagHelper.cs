using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-numericSpinner")]
    public class EIDSSNumericSpinnerTagHelper : TagHelper
    {

        private string _minValue;
        private string _maxValue;
        /// <summary>
        /// ID Of Control
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// Name Of Control
        /// </summary>
        public string Name { get; set; }

        public string Value { get; set; }
        /// <summary>
        /// Name Of Control
        /// </summary>
        /// 
        /// <summary>
        /// Class Name Of Control
        /// </summary>
        public string ClassName { get; set; }

        /// <summary>
        /// Class Name of the Control's Label
        /// </summary>
        public string LabelClassName { get; set; }

        public string MaxValue
        {
            get
            {
                if (int.TryParse(_maxValue, out _))
                    return _maxValue;
                else if (IntegerOnly)
                    return int.MaxValue.ToString();
                else
                    return long.MaxValue.ToString();
            }

            set
            {
                _maxValue = value;
            }
        }

        public string MinValue
        {
            get
            {
                if (int.TryParse(_minValue, out _))
                    return _minValue;
                else if (IntegerOnly)
                    return int.MinValue.ToString();
                else
                    return long.MinValue.ToString();
            }

            set
            {
                _minValue = value;
            }
        }

        [HtmlAttributeName("disabled")]
        public bool Disabled { get; set; } = false;

        public Boolean IntegerOnly { get; set; }

        public string OnChange { get; set; }

        //public string OnBlur { get; set; }

        public string Placeholder { get; set; }

        public string StepProperty { get; set; }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            string strOnchangeScript = "";
            string onInputScript = string.Empty;


            if (OnChange != null)
            {
                if (OnChange.IndexOf(":") != -1)
                    strOnchangeScript = OnChange.Substring(OnChange.IndexOf(":") + 1);
                else
                    strOnchangeScript = OnChange;

                output.Attributes.SetAttribute("onchange", strOnchangeScript);
            }

            //Actual Element
            output.TagName = "input ";

            output.Attributes.SetAttribute("type", "number");

            //Create Attributes
            if (!string.IsNullOrEmpty(this.ID))
            {
                output.Attributes.SetAttribute("id", this.ID);
            }

            if (!string.IsNullOrEmpty(this.Value))
            {
                output.Attributes.SetAttribute("value", this.Value);
            }
            if (!string.IsNullOrEmpty(this.Name))
            {
                output.Attributes.SetAttribute("name", this.Name);
            }
            if (!string.IsNullOrEmpty(this.ClassName))
            {
                output.Attributes.SetAttribute("class", this.ClassName);
            }

            if (!string.IsNullOrEmpty(this.MinValue))
            {
                output.Attributes.SetAttribute("min", this.MinValue);
            }

            if (!string.IsNullOrEmpty(this.MaxValue))
            {
                output.Attributes.SetAttribute("max", this.MaxValue);
            }

            if (!string.IsNullOrEmpty(this.Placeholder))
            {
                output.Attributes.SetAttribute("placeholder", this.Placeholder);
            }

            if (!string.IsNullOrEmpty(this.StepProperty))
            {
                output.Attributes.SetAttribute("step", this.StepProperty);
            }

            if (Disabled)
            {
                output.Attributes.SetAttribute("disabled", "true");
            }
            //if (!string.IsNullOrEmpty(this.OnBlur))
            //{
            //    output.Attributes.SetAttribute("onblur", this.OnBlur);
            //}

            output.Attributes.SetAttribute("onkeydown", "if(event.key === 'Backspace') this.value = value.substr(0, value.length - 1);");

            if (onInputScript != string.Empty)
                output.Attributes.SetAttribute("oninput", onInputScript);

            // Select the entire text when focus is set.
            output.Attributes.SetAttribute("onfocus", "$(this).select();");

            //Enable Start and  End Tag
            output.TagMode = TagMode.StartTagOnly;

            //output.PostElement.AppendHtml(LoadJavascript());

        }


        public string LoadJavascript()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<script type ='text/javascript'>");
            sb.AppendLine("window.addEventListener('load', function() {");
            sb.AppendLine("$(document).ready(function() {");
            //sb.AppendLine(LoadLatLongChanged());
            //sb.AppendLine(SetCoordinates());

            sb.AppendLine("});");
            sb.AppendLine("});");

            sb.AppendLine("</script>");
            return sb.ToString();
        }


        private string LoadLatLongChanged()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function latLongChanged() {");
            sb.AppendLine(" if (parseFloat($(Latitude).val()) && parseFloat($(Longitude).val()))");
            sb.AppendLine("{");

           // sb.AppendLine("setCoordinates();");
            sb.AppendLine("};");
            sb.AppendLine("};");


            return sb.ToString();

        }

        private string SetCoordinates()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("function setCoordinates(){");
            sb.AppendLine("var shortLat = parseFloat($(Latitude).val());");
            sb.AppendLine("var shortLong = parseFloat($(Longitude).val());");
            sb.AppendLine("var strShortLat = shortLat.toFixed(6);");
            sb.AppendLine("var strShortLong = shortLong.toFixed(6);");

            sb.AppendLine("$(Latitude).val(strShortLat.toLocaleString('en-US'));");
            sb.AppendLine("$(Longitude).val(strShortLong.toLocaleString('en-US'));");

            //sb.AppendLine("if (strShortLat != null && strShortLat != 'NaN' && strShortLong != null && strShortLong != 'NaN') {");
            //sb.AppendLine("document.getElementById(btnMap).setAttribute('onclick', 'setTile('<% =ConfigurationManager.AppSettings("LeafletAPIUrl") %>reverse?lat=" + strShortLat.toLocaleString("en-US") + "&lon=" + strShortLong.toLocaleString("en-US") + "', '12')");");
            //sb.AppendLine("};");
            sb.AppendLine("};");

            return sb.ToString();

        }
    }
}
