#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.PIN;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.PIN;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.Person
{
    public class PINSearchBase : BaseComponent
    {
        
        #region Dependencies

        [Inject] private IPINClient pinClient { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter] public string PersonalID { get; set; }
        [Parameter] public DateTime DateOfBirth { get; set; }

        #endregion Parameters

        #region Properties        

        protected IEnumerable<PersonViewModel> _PINSearchResults { get; set; }
        protected bool _displayErrorMessage { get; set; }

        #endregion Properties

        #region Member Variables        
        
        List<PersonViewModel> persons = new();
        protected bool _isLoading;

        #endregion        
       
        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _isLoading = true;
            int birthYear = 0;

            if (DateOfBirth != DateTime.MinValue)
                birthYear = DateOfBirth.Year;

            PersonalDataModel response = await pinClient.GetPersonData(PersonalID, birthYear.ToString());

            PersonViewModel person = new();            

            if(EIDSSConstants.CultureNames.enUS == GetCurrentLanguage())
            {
                person.FirstOrGivenName = response.FirstNameEn;
                person.LastOrSurname = response.LastNameEn;
            }
            else
            {
                person.FirstOrGivenName = response.FirstName;
                person.LastOrSurname = response.LastName;
            }                        

            DateTime dob;
            DateTime.TryParse(response.BirthDate, out dob);
            person.DateOfBirth = dob;
            person.PersonalID = PersonalID;
            //PINPersonGendersEnum gender = response.GenderID;
            person.GenderTypeName = response.GenderNameEn;

            if (!string.IsNullOrEmpty(response.FirstNameEn) && !string.IsNullOrEmpty(response.LastNameEn) && !string.IsNullOrEmpty(response.BirthDate))
                persons.Add(person);

            if (!persons.Any()) _displayErrorMessage = true;
            else _displayErrorMessage = false;

            _PINSearchResults = persons;
            _isLoading = false;

            #region OLD
            //_isLoading = true;       
            //PINGetPersonInfoResponse response = await pinClient.GetPersonByPIN("0", "0", PersonalID);

            //PersonViewModel person = new();
            //person.FirstOrGivenName = response.FirstName;
            //person.SecondName = response.MiddleName;
            //person.LastOrSurname = response.LastName;
            //person.DateOfBirth = response.BirthDate;
            //person.PersonalID = response.PersonalID;        s
            //PINPersonGendersEnum gender = response.Gender;
            //person.GenderTypeName = gender.ToString();
            //persons.Add(person);

            //_PINSearchResults = persons;        
            //_isLoading = false;        
            #endregion

        }

        protected void OnOkClick()
        {
            DiagService.Close(persons.FirstOrDefault());
        }        

    }
}

