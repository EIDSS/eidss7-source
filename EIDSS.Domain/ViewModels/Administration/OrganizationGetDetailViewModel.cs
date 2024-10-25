using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class OrganizationGetDetailViewModel : BaseModel
    {
        public long? OrganizationKey { get; set; }

        [StringLength(100)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.UniqueOrganizationIDFieldLabel))]
        public string OrganizationID { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OrganizationTypeFieldLabel))]
        public long? OrganizationTypeID { get; set; }

        public string OrganizationTypeName { get; set; }

        public long? AbbreviatedNameReferenceID { get; set; }

        [StringLength(2000)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AbbreviationDefaultValueFieldLabel))]
        public string AbbreviatedNameDefaultValue { get; set; }

        [StringLength(2000)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AbbreviationNationalValueFieldLabel))]
        public string AbbreviatedNameNationalValue { get; set; }

        public long? FullNameReferenceID { get; set; }

        [StringLength(2000)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OrganizationFullNameDefaultValueFieldLabel))]
        public string FullNameDefaultValue { get; set; }

        [StringLength(2000)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OrganizationFullNameNationalValueFieldLabel))]
        public string FullNameNationalValue { get; set; }

        public long? AddressID { get; set; }


        private long? locationID;

        public long? LocationID
        {
            get
            {
                if (AdministrativeLevel4ID != null)
                    locationID = AdministrativeLevel4ID;
                else if (AdministrativeLevel3ID != null)
                    locationID = AdministrativeLevel3ID;
                else if (AdministrativeLevel2ID != null)
                    locationID = AdministrativeLevel2ID;
                else if (AdministrativeLevel1ID != null)
                    locationID = AdministrativeLevel1ID;
                else
                    locationID = CountryID;

                return locationID;
            }
            set => locationID = value;
        }

        public long CountryID { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel1FieldLabel))]
         public long? AdministrativeLevel1ID { get; set; }

        public string AdministrativeLevel1Name { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel2FieldLabel))]
         public long? AdministrativeLevel2ID { get; set; }

        public string AdministrativeLevel2Name { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel3FieldLabel))]
         public long? AdministrativeLevel3ID { get; set; }

        public string AdministrativeLevel3Name { get; set; }

        public long? AdministrativeLevel4ID { get; set; }

        public string AdministrativeLevel4Name { get; set; }

        public long? SettlementTypeID { get; set; }

        public long? StreetID { get; set; }

        [StringLength(200)]
        public string StreetName { get; set; }

        [StringLength(200)]
        public string House { get; set; }

        [StringLength(200)]
        public string Building { get; set; }

        [StringLength(200)]
        public string Apartment { get; set; }


        public long? PostalCodeID { get; set; }

        [StringLength(200)]
        public string PostalCode { get; set; }

        public bool ForeignAddressIndicator { get; set; }

        [StringLength(200)]
        public string ForeignAddressString { get; set; }

        public string AddressString { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PhoneFieldLabel))]
        [LocalizedStringLength(15, MinimumLength = 8)]
        public string ContactPhone { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OwnershipFormFieldLabel))]
        public long? OwnershipFormTypeID { get; set; }

        public string OwnershipFormTypeName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.LegalFormFieldLabel))]
        public long? LegalFormTypeID { get; set; }

        public string LegalFormTypeName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.MainFormOfActivityFieldLabel))]
        public long? MainFormOfActivityTypeID { get; set; }
        public string MainFormOfActivityTypeName { get; set; }
        private string accessoryCodeString;
        public string AccessoryCodeIDsString
        {
            get => accessoryCodeString;
            set
            {
                accessoryCodeString = value;
                if (accessoryCodeString != null)
                {
                    // Extract all accessory codes from the JSON string and add them up.
                    Regex csvRegex = new(@"(?:(?<value>\d+),?)+",RegexOptions.None,TimeSpan.FromMilliseconds(5));
                    foreach (Capture capture in csvRegex.Match(accessoryCodeString).Groups["value"].Captures)
                    {
                        AccessoryCode ??= 0;
                        AccessoryCode += Convert.ToInt32(capture.Value);
                    }
                }
            }
        }
        public string AccessoryCodeNamesString { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OrganizationInfoAccessoryCodeFieldLabel))]
        public int? AccessoryCode { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OrderFieldLabel))]
        [LocalizedRange("-2147483648", "2147483648")]
        public int Order { get; set; }
        public long SiteID { get; set; }
        public int RowStatus { get; set; }
        public long? SettlementID { get; set; }

        public string SettlementName { get; set; }
    }
}
