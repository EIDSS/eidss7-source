namespace EIDSS.ClientLibrary.Configurations
{
    public class ProtectedConfigurationSettings
    {
        public const string ProtectedConfigurationSection = "ProtectedConfiguration";

        public string PIN_UserName { get; set; }
        public string PIN_Password { get; set; }
        public string SSRS_Domain { get; set; }
        public string SSRS_UserName { get; set; }
        public string SSRS_Password { get; set; }
    }
}
