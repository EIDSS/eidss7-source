namespace EIDSS.Web.Services
{
    public interface IAppVersionService
    {
        string Version { get; }
        string GetOrganizationName();
        string GetYears();
    }
}
