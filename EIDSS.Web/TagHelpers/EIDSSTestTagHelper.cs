using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Text;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
//using Nancy.Json;
using System.IO;
using System.Collections.Generic;
using System.Collections.Specialized;


namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement("eidss-test")]
    public class EIDSSTestTagHelper : TagHelper
    {
        public string ID { get; set; }

        public EIDSSTestTagHelper()
        {

        }
        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            output.TagName = "div";

            //Enable Start and  End Tag
            output.TagMode = TagMode.StartTagAndEndTag;

            List<KeyValuePair<string, string>> kvpReplacements = new List<KeyValuePair<string, string>>();

            kvpReplacements.Add(new KeyValuePair<string, string>("MESSAGE1", "Testing the a new process. "));
            kvpReplacements.Add(new KeyValuePair<string, string>("MESSAGE2", "Message replacement is successful."));
            kvpReplacements.Add(new KeyValuePair<string, string>("divID", "dABCD"));
            

            string strTestReturn = sbFile(".\\TagHelpers\\CustomFiles\\test.txt", kvpReplacements);

            output.Attributes.Add("id", ID);
            output.PreContent.SetHtmlContent(strTestReturn);

            //output.PostElement.AppendHtml(LoadJavascript());
        }

        private string sbFile(string strFileAndPath, List<KeyValuePair<string, string>> ldReplacements)
        {
            string strContent = string.Empty;

            //string strPath = ".\\TagHelpers\\js.txt";
            using (StreamReader sr = File.OpenText(strFileAndPath))
            {
                strContent = sr.ReadToEnd();
            }
            ListDictionary ld = new ListDictionary();

            //Make replacesments
            foreach (KeyValuePair<string, string> kvpItem in ldReplacements)
            {
                strContent = strContent.Replace("[" + kvpItem.Key + "]", kvpItem.Value);
            }

            StringBuilder sb = new StringBuilder();

            sb.Append(strContent);

            return sb.ToString();
        }
    }
}
