using EIDSS.Domain.Enumerations;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Repository.Repositories
{
    public class TrtBaseReferenceRepository : ITrtBaseReferenceRepository
    {
        private readonly EIDSSContext _context;

        public TrtBaseReferenceRepository(EIDSSContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<TrtBaseReference>> GetAgeTypesAsync(
            string languageIsoCode,
            string searchText,
            params long[] excludeIds)
        {
            var ageTypeKey = (long)BaseReferenceTypeEnum.AgeType;

            excludeIds ??= Array.Empty<long>();

            var query = from br in _context.TrtBaseReference
                        join snt in (from snt in _context.TrtStringNameTranslation
                                     let languageId = GetLanguageId(languageIsoCode)
                                     where snt.IdfsLanguage == languageId
                                     select snt)
                        on br.IdfsBaseReference equals snt.IdfsBaseReference
                        into join1
                        from snt in join1.DefaultIfEmpty()
                        where br.IdfsReferenceType == ageTypeKey
                        && br.IntRowStatus == 0
                        && !excludeIds.Contains(br.IdfsBaseReference)
                        && (string.IsNullOrEmpty(searchText)
                        || (snt.StrTextString ?? br.StrDefault).Contains(searchText))
                        select new TrtBaseReference
                        {
                            IdfsBaseReference = br.IdfsBaseReference,
                            StrDefault = snt.StrTextString ?? br.StrDefault,
                        };

            return await query.ToListAsync();
        }

        private long GetLanguageId(string languageIsoCode)
        {
            var languageKey = (long)BaseReferenceTypeEnum.Language;

            return (from br in _context.TrtBaseReference
                    where br.IdfsReferenceType == languageKey
                    && br.IntRowStatus == 0
                    && br.StrBaseReferenceCode == languageIsoCode
                    select br.IdfsBaseReference)
                    .FirstOrDefault();
        }
    }
}
