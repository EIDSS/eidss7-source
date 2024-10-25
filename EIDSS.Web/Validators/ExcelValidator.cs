using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml;
using System.IO;
using System.Threading.Tasks;

namespace EIDSS.Web.Validators;

public class ExcelValidator : ISpreadsheetValidator
{
    public async Task<byte[]> CleanUp(byte[] data)
    {
        var task = Task.Run(() =>
        {
            using var readStream = new MemoryStream(data);
            var openSettings = new OpenSettings
            {
                RelationshipErrorHandlerFactory = (p) => new CustomRelationshipErrorHandler()
            };
            using var document = SpreadsheetDocument.Open(readStream, true, openSettings);

            if (document.WorkbookPart == null)
            {
                throw new InvalidDataException();
            }

            foreach (var worksheetPart in document.WorkbookPart.WorksheetParts)
            {
                var worksheet = worksheetPart.Worksheet;
                foreach (var cell in worksheet.Descendants<Cell>())
                {
                    if (cell.CellFormula == null)
                    {
                        continue;
                    }

                    var formula = cell.CellFormula.Text;
                    cell.CellFormula.Remove();

                    cell.CellValue = new CellValue($"\'={formula}");
                    cell.DataType = new EnumValue<CellValues>(CellValues.String);
                }
            }

            if (document.WorkbookPart.CalculationChainPart != null)
            {
                document.WorkbookPart.DeletePart(document.WorkbookPart.CalculationChainPart);
            }

            document.Save();
            document.Close();

            return readStream.ToArray();
        });

        return await task;
    }
}
