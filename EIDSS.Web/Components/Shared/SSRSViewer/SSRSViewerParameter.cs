using Microsoft.AspNetCore.Components;

namespace EIDSS.Web.Components.Shared.SSRSViewer;

public class SSRSViewerParameter : ComponentBase
{
    string _parameterName;

    [Parameter]
    public string ParameterName
    {
        get => _parameterName;
        set
        {
            if (_parameterName != value)
            {
                _parameterName = value;
                if (Viewer != null)
                {
                    Viewer.Reload();
                }
            }
        }
    }

    string _value;

    [Parameter]
    public string Value
    {
        get => _value;
        set
        {
            if (_value != value)
            {
                _value = value;
                if (Viewer != null)
                {
                    Viewer.Reload();
                }
            }
        }
    }

    SSRSViewer _viewer;

    [CascadingParameter]
    public SSRSViewer Viewer
    {
        get => _viewer;
        set
        {
            if (_viewer != value)
            {
                _viewer = value;
                _viewer.AddParameter(this);
            }
        }
    }
}