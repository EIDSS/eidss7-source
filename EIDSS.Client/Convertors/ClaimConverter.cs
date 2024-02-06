using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using JsonSerializer = System.Text.Json.JsonSerializer;

namespace EIDSS.ClientLibrary.Convertors
{
	public class ClaimConverter : JsonConverter
    {
        public override void WriteJson(JsonWriter writer, object value, Newtonsoft.Json.JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, Newtonsoft.Json.JsonSerializer serializer)
        {
            JObject jo = JObject.Load(reader);
            string type = (string)jo["type"];
            string value = (string)jo["value"];
            string valueType = (string)jo["valueType"];
            string issuer = (string)jo["issuer"];
            string originalIssuer = (string)jo["originalIssuer"];
            return new Claim(type, value, valueType, issuer, originalIssuer);
        }

        public override bool CanConvert(Type objectType)
        {
            return (objectType == typeof(System.Security.Claims.Claim));
        }

      

        public override bool CanWrite => false;

       
    }
}
