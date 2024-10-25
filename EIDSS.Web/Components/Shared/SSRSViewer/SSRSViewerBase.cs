using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Radzen;
using Radzen.Blazor;
namespace EIDSS.Web.Components.Shared.SSRSViewer;

public class SSRSViewerBase : BaseComponent
{
    [Parameter]
    public bool UseProxy { get; set; } = false;

    [Parameter]
    public string ReportServer { get; set; }

    [Parameter]
    public string ReportName { get; set; }

    [Parameter]
    public RenderFragment Parameters { get; set; }
    
    [Inject] 
    protected NavigationManager uriHelper { get; set; }

    public string ReportUrl
    {
        get
        {
            var urlParams = string.Join("&", parameters
                .Where(p => !string.IsNullOrEmpty(p.ParameterName))
                .Select(p => $"{Uri.EscapeDataString(p.ParameterName)}={Uri.EscapeDataString(p.Value)}"));
            
            var urlParamString = parameters.Count > 0 ? $"&{urlParams}" : urlParams;

            var url = $"{ReportServer}/Pages/ReportViewer.aspx?%2f{ReportName}&rs:Command=Render&rs:Embed=true{urlParamString}";

            if (UseProxy)
            {
                url = $"{uriHelper.BaseUri}__ssrsreport?reportName={ReportName}{urlParamString}";
            }

            return url;
        }
    }

    public void Reload()
    {
        InvokeAsync(StateHasChanged);
    }

    protected List<SSRSViewerParameter> parameters = new();

    public void AddParameter(SSRSViewerParameter parameter)
    {
        if (parameters.IndexOf(parameter) == -1)
        {
            parameters.Add(parameter);
            StateHasChanged();
        }
    }

    [Parameter]
    public EventCallback<ProgressEventArgs> Load { get; set; }

    async protected Task OnLoad(ProgressEventArgs args)
    {
        await Load.InvokeAsync(args);
    }
}