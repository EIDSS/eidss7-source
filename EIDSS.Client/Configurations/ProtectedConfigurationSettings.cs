using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Intrinsics.Arm;
using System.Text;
using System.Threading.Tasks;
using Miqo.EncryptedJsonConfiguration;

namespace EIDSS.ClientLibrary.Configurations
{

    public class ProtectedConfigurationSettings
    {
        public const string ProtectedConfigurationSection = "ProtectedConfiguration";


        public string PIN_UserName
        {
            get;
            set;
        }

        public string PIN_Password
        {
            get;
            set;
        }
        public string SSRS_Domain
        {
            get;
            set;
        }
        public string SSRS_UserName
        {
            get;
            set;
        }
        public string SSRS_Password
        {
            get;
            set;
        }

    }

    /// <summary>
    /// Protected configuration extensions that perform cryptographic operations on a string.
    /// </summary>
    public static class ProtectedConfigurationExtensions
    {
        private static string aeskey = "";

        /// <summary>
        /// Encrypts a string.
        /// </summary>
        /// <param name="str">The unencrypted string to encrypt.</param>
        /// <returns>Returns the string encrypted.</returns>
        public static string Encrypt(this string str) => AesEncryptionHelpers.Encrypt(str, aeskey);

        /// <summary>
        /// Decrypts a string.
        /// </summary>
        /// <param name="str">The encrypted string to decrypt.</param>
        /// <returns>Returns the string decrypted.</returns>
        public static string Decrypt(this string str) => AesEncryptionHelpers.Decrypt(str, aeskey);
    }
}
