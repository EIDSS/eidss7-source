using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Runtime.Serialization;
using System.Text;
using EIDSS.Localization.Helpers;

namespace EIDSS.ClientLibrary.Responses
{
    /// <summary>
    /// Preferences container class that contains both system and user preference confugration settings.
    /// </summary>
    public class Preferences
    {
        /// <summary>
        /// Contains system preference configuration settings
        /// </summary>
        public SystemPreferences SystemPreferences { get; set; } = new SystemPreferences();

        ///// <summary>
        ///// Contains user preference configuration settings
        ///// </summary>
        public UserPreferences UserPreferences { get; set; }

        public Preferences( IUserConfigurationService configurationService)
        {
            UserPreferences = new UserPreferences(configurationService);
        }
    }

    public class MapProject
    {
        public string MapText { get; set; } = "Default";
        public int Value { get; set; } = -1;
    }

    [DataContract]
    public abstract class BasePreference
    {
        protected string _startupLanguage = "en-US";

        /// <summary>
        /// Indicates the default startup language code as a standard ISO 639-1 language code.
        /// </summary>
        [DataMember]
        [Display(Name = "Startup Language")]
        [LocalizedRequired]
        public virtual string StartupLanguage
        {
            get => _startupLanguage;
            set => _startupLanguage = value;
        }

        /// <summary>
        /// Default map project.
        /// </summary>
        [DataMember]
        public virtual int? DefaultMapProject { get; set; } = -1;

        /// <summary>
        /// Specifies the default region displayed in region specific location drop downs.
        /// </summary>
        [DataMember]
        public virtual bool DefaultRegionInSearchPanels { get; set; }

        /// <summary>
        /// Specifies the default rayon displayed in rayon specific location drop downs.
        /// </summary>
        [DataMember]
        public virtual bool DefaultRayonInSearchPanels { get; set; }

        /// <summary>
        /// A boolean value indicating wheter the user has the ability to print a map in the Veterinary Investigation Forms.
        /// </summary>
        [DataMember]
        public virtual bool PrintMapInVetInvestigationForms { get; set; }

        public virtual List<MapProject> MapProjects { get; set; }

        public virtual string PageHeading { get; set; }

        public virtual List<CountryModel> CountryList { get; set; }

        public virtual List<LanguageModel> LanguageList { get; set; }


    }

    /// <summary>
    /// Container class for system preferences
    /// </summary>
    [DataContract]
    public class SystemPreferences : BasePreference
    {
        #region Properties

        /// <summary>
        /// Specifies the country for which this instance of the application is configured.
        /// </summary>
        [DataMember]
        [LocalizedRequired]
        public virtual string Country { get; set; } = "Georgia";

        /// <summary>
        /// A boolean value indicating whether to display warning messages for final case classifications.
        /// </summary>
        [DataMember]
        public virtual bool ShowWarningForFinalCaseClassification { get; set; } = false;

        /// <summary>
        /// A boolean value indicating whether to filter sample lists by disease.
        /// </summary>
        [DataMember]
        public virtual bool FilterSamplesByDisease { get; set; } = false;

        /// <summary>
        /// Specifies whether to link a sample identifier to a report/session identifier
        /// for: human, livestock and avian disease reports, case investigations, human and veterinary active surveillance session.
        /// </summary>
        [DataMember]
        //[Display(Name = "Link local Sample ID to the Report/Session ID")]
        public virtual bool LinkLocalSampleIdToReportSessionId { get; set; } = false;

        /// <summary>
        /// Indicates whether past dates can be used for criteria specification for laboratory only.
        /// </summary>
        [DataMember]
        [Display(Name = "Allow dates in the Past in the Laboratory Module")]
        public virtual bool AllowPastDates { get; set; } = false;

        /// <summary>
        /// Specifies the maximum number of days
        /// </summary>
        [DataMember]
        [LocalizedRequired]
        [LocalizedRangeFrom("1", "36500")]
        public virtual int NumberDaysDisplayedByDefault { get; set; } = 14;
        ///// <summary>
        ///// Indicates the default startup language code as a standard ISO 639-1 language code.
        ///// </summary>
        //[DataMember]
        //public string StartupLanguage { get; internal set; } = "en-US";

        /// <summary>
        /// Indicates the row identifier that specifies this entry in the system preferences table.
        /// </summary>
        [IgnoreDataMember]
        [HiddenInput(DisplayValue = false)]
        public virtual long SystemPreferencesId { get; set; }

      
        #endregion Properties

        #region Constructors

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        public SystemPreferences()
        {
        }

        #endregion Constructors
    }

    [DataContract]
    /// <summary>
    /// Container class for user preferences
    /// </summary>
    public class UserPreferences : BasePreference
    {

        public UserPreferences()
        {

        }
        private string _activeLanguage;

        #region Properties

        /// <summary>
        /// Indicates the row identifier that specifies this entry in the system preferences table.
        /// </summary>
        [IgnoreDataMember]
        [HiddenInput(DisplayValue = false)]
        public virtual long? UserPreferencesId { get; set; } = 0;

        [IgnoreDataMember]
        public virtual long UserId { get; set; }

        #endregion Properties

        [IgnoreDataMember]
        /// <summary>
        /// Represents the actively selected langauge for the user.
        /// </summary>
        public virtual string ActiveLanguage
        {
            get => _activeLanguage;
            set => _activeLanguage = value;
        }

        [IgnoreDataMember]
        public virtual string AuditUserName { get; set; }

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        public UserPreferences( IUserConfigurationService configurationService)
        {
            var sysPrefs = configurationService.SystemPreferences;

            // Take system preferences defaults...
        }

    }
}