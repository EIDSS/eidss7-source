namespace EIDSS.Web.Validators;

public interface ISpreadsheetValidatorFactory
{
    ISpreadsheetValidator GetValidator(string fileExtension);
}
