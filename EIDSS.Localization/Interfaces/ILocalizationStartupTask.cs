using Microsoft.AspNetCore.Builder;
using System.Threading.Tasks;

namespace EIDSS.Localization.Interfaces
{
    public interface ILocalizationStartupTask
    {
        Task InvokeAsync(IApplicationBuilder app);
    }
}