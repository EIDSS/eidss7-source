using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using EIDSS.Domain.ResponseModels.PIN;
using System.Text.Json;

namespace EIDSS.Api.Integrations.PIN.Georgia
{
    public interface IPINMockDataService
    {
        PersonalDataModel GetDataModel(string pin, string birthYear);
    }

    public class PINMockDataService : IPINMockDataService
    {
        private List<PersonalDataModel> _datamodels = new();

        public PINMockDataService()
        {
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };
            var filename = ".\\Integrations\\PIN\\Georgia\\PINMockData.Json";
            string json = File.ReadAllText(filename);
            _datamodels = JsonSerializer.Deserialize<List<PersonalDataModel>>(json,options);
        }
        public PersonalDataModel GetDataModel(string pin, string birthYear)
        {
            var dm = new PersonalDataModel();

            if (string.IsNullOrEmpty(birthYear) || !int.TryParse(birthYear, out int n))
                return dm;

            dm = _datamodels.Where(w => w.PrivateNumber == pin &&
                                         DateTime.Parse(w.BirthDate).Year == n).FirstOrDefault();
            return dm;
        }
    }
}
