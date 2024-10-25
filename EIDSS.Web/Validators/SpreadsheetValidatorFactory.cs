namespace EIDSS.Web.Validators;

public class SpreadsheetValidatorFactory : ISpreadsheetValidatorFactory
{
    public ISpreadsheetValidator GetValidator(string fileExtension)
    {
        return fileExtension switch
        {
            ".csv" => new CsvValidator(),
            ".xls" or ".xlsx" => new ExcelValidator(),
            _ => null,
        };
    }
}
