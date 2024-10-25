using CsvHelper;
using CsvHelper.Configuration;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Validators;

public class CsvValidator : ISpreadsheetValidator
{
    public async Task<byte[]> CleanUp(byte[] data)
    {
        var lines = await GetRecords(data);

        lines = CleanUp(lines);

        return await GetOutputData(lines);
    }

    private static List<string[]> CleanUp(List<string[]> lines)
    {
        var deniedFirstCharacters = new[] { '=', '@', '+', '-' };

        foreach (var line in lines)
        {
            for (var i = 0; i < line.Length; i++)
            {
                var cellText = line[i];

                if (cellText.Length > 1)
                {
                    var firstCharacter = cellText[0];
                    if (deniedFirstCharacters.Contains(firstCharacter))
                    {
                        line[i] = $"\'{cellText}";
                    }
                }
            }
        }

        return lines;
    }

    private static async Task<byte[]> GetOutputData(List<string[]> lines)
    {
        using var writeStream = new MemoryStream();
        using var streamWriter = new StreamWriter(writeStream);
        using var csvWriter = new CsvWriter(streamWriter, CultureInfo.InvariantCulture);
        foreach (var line in lines)
        {
            foreach (var cell in line)
            {
                csvWriter.WriteField(cell);
            }
            await csvWriter.NextRecordAsync();
        }
        streamWriter.Flush();

        return writeStream.ToArray();
    }

    private static async Task<List<string[]>> GetRecords(byte[] data)
    {
        using var readStream = new MemoryStream(data);
        using var streamReader = new StreamReader(readStream);
        var config = new CsvConfiguration(CultureInfo.InvariantCulture)
        {
            BadDataFound = context => { }
        };
        using var csvParser = new CsvParser(streamReader, config);

        var lines = new List<string[]>();
        while (await csvParser.ReadAsync())
        {
            if (csvParser.Record != null)
            {
                lines.Add(csvParser.Record);
            }
        }

        return lines;
    }
}
