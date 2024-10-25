using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text;

namespace EIDSS.Web.TagHelpers
{
    public class Select2DropDownJSScriptTagHelper : TagHelperComponent
    {
        private readonly string _javascript;
        public Select2DropDownJSScriptTagHelper(string _controlId, string _endPoint)
        {
            _javascript = LoadSelect2DropDown(_controlId,  _endPoint,string.Empty,string.Empty);
        }
        public override Task ProcessAsync(TagHelperContext context, TagHelperOutput output)
        {
            if (string.Equals(context.TagName, "body", StringComparison.Ordinal))
            {
                output.PostContent.AppendHtml($"<script type='text/javascript'>{_javascript}</script>");
            }
            return Task.CompletedTask;
        }




        private string LoadSelect2DropDown(string _controlId, string _endPoint, string _filteredControlId, string _filteredEndPoint)
        {
            StringBuilder sb = new StringBuilder();


            sb.AppendLine("function LoadSelect2DropDown(controlId,endPoint,filterControlId,filteredEndpoint){");
            sb.AppendLine("var _controlId = null;");
            sb.AppendLine("var _filterIdControlId = null;");
            sb.AppendLine("var _endPoint = null;");
            sb.AppendLine("var _fileredEndpoint = null;");
            sb.AppendLine("_endPoint = endPoint ;");
            sb.AppendLine("_controlId =  controlId ;");
            sb.AppendLine("_filterIdControlId = filterControlId;");
            sb.AppendLine("_filteredEndpoint = filteredEndpoint;");
            sb.AppendLine("if (_controlId != null & _controlId != 'null' & _controlId != undefined) {");
            sb.AppendLine("//Instantiate Select 2 Library on DropDown");
            sb.AppendLine(" $('#' + _controlId).select2({");
            sb.AppendLine("ajax: {");
            sb.AppendLine("url: _endPoint,");
            sb.AppendLine("data: function (params) {");
            sb.AppendLine("var query = {");
            sb.AppendLine("// data: JSON.stringify(datalist),");
            sb.AppendLine(" term: params.term, page: params.page || 1");
            sb.AppendLine("}");
            sb.AppendLine("return query");
            sb.AppendLine("}");
            sb.AppendLine("},");
            sb.AppendLine("width: '100%',");
            sb.AppendLine("tags: true,");
            sb.AppendLine("closeOnSelect: true,");
            sb.AppendLine("allowClear: true,");
            sb.AppendLine("placeholder: ' '");
            sb.AppendLine("});");
            sb.AppendLine("}");
            sb.AppendLine("}");


            sb.AppendLine("LoadSelect2DropDown('" + _controlId + "','" + _endPoint + "','" + _filteredControlId + "','" + _filteredEndPoint + "');");
            return sb.ToString();
        }


        public string LoadFilteredSelect2DropDown()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine();

            return sb.ToString();
        }
    }
}
