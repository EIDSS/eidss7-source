namespace EIDSS.Api.Configuration
{
    public class ProtectedSettings
    {
        public const string ProtectedConfigurationSection = "ProtectedConfiguration";

        public string EIDSSDatabaseUser { get; set; }
        public string EIDSSDatabasePassword { get; set; }
        public string LocalizationDatabaseUser { get; set; }
        public string LocalizationDatabasePassword { get; set; }
        public string EIDSSArchiveDatabaseUser { get; set; }
        public string EIDSSArchiveDatabasePassword { get; set; }
        public string XSiteEnUsDatabaseUser { get; set; }
        public string XSiteEnUsDatabasePassword { get; set; }
        public string XSiteAzLDatabaseUser { get; set; }
        public string XSiteAzLDatabasePassword { get; set; }
        public string XSiteKaGeDatabaseUser { get; set; }
        public string XSiteKaGeDatabasePassword { get; set; }
    }
}
