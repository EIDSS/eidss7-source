using System.Threading.Tasks;

namespace EIDSS.Web.Validators;

public interface ISpreadsheetValidator
{
    Task<byte[]> CleanUp(byte[] data);
}
