using Miqo.EncryptedJsonConfiguration;

namespace EIDSS.Security.Encryption
{
    /// <summary>
    /// Protected configuration extensions that perform cryptographic operations on a string.
    /// </summary>
    public static class ProtectedConfigurationExtensions
    {
        private const string AesKey = "";

        /// <summary>
        /// Encrypts a string.
        /// </summary>
        /// <param name="str">The unencrypted string to encrypt.</param>
        /// <returns>Returns the string encrypted.</returns>
        public static string Encrypt(this string str) => AesEncryptionHelpers.Encrypt(str, AesKey);

        /// <summary>
        /// Decrypts a string.
        /// </summary>
        /// <param name="str">The encrypted string to decrypt.</param>
        /// <returns>Returns the string decrypted.</returns>
        public static string Decrypt(this string str) => AesEncryptionHelpers.Decrypt(str, AesKey);
    }
}
