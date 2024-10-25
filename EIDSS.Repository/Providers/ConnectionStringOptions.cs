namespace EIDSS.Repository.Providers
{
    public class ConnectionStringOptions
    {
        public const string SectionName = "ConnectionStrings";

        public string? EIDSSConn { get; set; }
        public string? LoggingConn { get; set; }
        public string? LocalizationConn { get; set; }
        public string? EIDSSArchiveConn { get; set; }

    }
}
