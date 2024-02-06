using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace EIDSS.Web.Components.Leaflet.Utils
{
    public class StringHelper
    {

        //private static readonly Random _random = new Random();

        public static string GetRandomString(int length)
        {
            var randomGenerator = RandomNumberGenerator.Create();
            byte[] data = new byte[16];
            randomGenerator.GetBytes(data);
            return BitConverter.ToString(data);

            //var randomGenerator = RandomNumberGenerator.Create();
            //const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
            //return new string(Enumerable.Repeat(chars, length)
//              .Select(s => s[_random.Next(s.Length)]).ToArray());
        }

    }
}
