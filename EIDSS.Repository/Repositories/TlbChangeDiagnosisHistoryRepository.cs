using EIDSS.Domain.Enumerations;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels.Custom;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Repository.Repositories;

public class TlbChangeDiagnosisHistoryRepository(EIDSSContext context) : ITlbChangeDiagnosisHistoryRepository
{
    private readonly EIDSSContext _context = context;

    public async Task<IEnumerable<ChangeDiagnosisHistoryReturnModel>> GetChangeDiagnosisHistoryAsync(long idfHumanCase, string languageIsoCode)
    {
        var query = from cdh in _context.TlbChangeDiagnosisHistory
                    join lang in _context.TrtBaseReference on 1 equals 1
                    join p in _context.TlbPerson on cdh.IdfPerson equals p.IdfPerson
                    join o in _context.TlbOffice on p.IdfInstitution equals o.IdfOffice into officeGroup
                    from o in officeGroup.DefaultIfEmpty()
                    join obr in _context.TrtBaseReference on o.IdfsOfficeAbbreviation equals obr.IdfsBaseReference into officeRefGroup
                    from obr in officeRefGroup.DefaultIfEmpty()
                    join osnt in _context.TrtStringNameTranslation on new { obr.IdfsBaseReference, IdfsLanguage = lang.IdfsBaseReference } equals new { osnt.IdfsBaseReference, osnt.IdfsLanguage } into officeStringGroup
                    from osnt in officeStringGroup.DefaultIfEmpty()
                    join cd in _context.TrtDiagnosis on cdh.IdfsCurrentDiagnosis equals cd.IdfsDiagnosis into currentDiagnosisGroup
                    from cd in currentDiagnosisGroup.DefaultIfEmpty()
                    join cdbr in _context.TrtBaseReference on cd.IdfsDiagnosis equals cdbr.IdfsBaseReference into currentDiagnosisRefGroup
                    from cdbr in currentDiagnosisRefGroup.DefaultIfEmpty()
                    join cdsnt in _context.TrtStringNameTranslation on new { cdbr.IdfsBaseReference, IdfsLanguage = lang.IdfsBaseReference } equals new { cdsnt.IdfsBaseReference, cdsnt.IdfsLanguage } into currentDiagnosisStringGroup
                    from cdsnt in currentDiagnosisStringGroup.DefaultIfEmpty()
                    join pd in _context.TrtDiagnosis on cdh.IdfsPreviousDiagnosis equals pd.IdfsDiagnosis into previousDiagnosisGroup
                    from pd in previousDiagnosisGroup.DefaultIfEmpty()
                    join pdbr in _context.TrtBaseReference on pd.IdfsDiagnosis equals pdbr.IdfsBaseReference into previousDiagnosisRefGroup
                    from pdbr in previousDiagnosisRefGroup.DefaultIfEmpty()
                    join pdsnt in _context.TrtStringNameTranslation on new { pdbr.IdfsBaseReference, IdfsLanguage = lang.IdfsBaseReference } equals new { pdsnt.IdfsBaseReference, pdsnt.IdfsLanguage } into previousDiagnosisStringGroup
                    from pdsnt in previousDiagnosisStringGroup.DefaultIfEmpty()
                    join crbr in _context.TrtBaseReference on cdh.IdfsChangeDiagnosisReason equals crbr.IdfsBaseReference into changeReasonGroup
                    from crbr in changeReasonGroup.DefaultIfEmpty()
                    join crsnt in _context.TrtStringNameTranslation on new { crbr.IdfsBaseReference, IdfsLanguage = lang.IdfsBaseReference } equals new { crsnt.IdfsBaseReference, crsnt.IdfsLanguage } into changeReasonStringGroup
                    from crsnt in changeReasonStringGroup.DefaultIfEmpty()
                    where cdh.IdfHumanCase == idfHumanCase
                          && lang.IdfsReferenceType == (long)BaseReferenceTypeEnum.Language
                          && lang.IntRowStatus == 0
                          && lang.StrBaseReferenceCode == languageIsoCode
                    select new ChangeDiagnosisHistoryReturnModel
                    {
                        DateOfChange = cdh.DatChangedDate,
                        ChangedByOrganization = osnt.StrTextString ?? obr.StrDefault,
                        ChangedByPerson = ConcatFullName(p.StrFamilyName, p.StrFirstName, p.StrSecondName),
                        PreviousDisease = pdsnt.StrTextString ?? pdbr.StrDefault,
                        ChangedDisease = cdsnt.StrTextString ?? cdbr.StrDefault,
                        Reason = crsnt.StrTextString ?? crbr.StrDefault
                    };


        return await query.ToListAsync();
    }

    private static string ConcatFullName(string lastName, string firstName, string secondName)
    {
        return $"{lastName}{AddLeadingSpace(firstName)}{AddLeadingSpace(secondName)}";
    }

    private static string AddLeadingSpace(string text)
    {
        return string.IsNullOrEmpty(text) ? string.Empty : $" {text}";
    }
}
