using EIDSS.Domain.RequestModels.Human;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace EIDSS.Repository.Repositories
{
    public class TlbHumanActualRepository : ITlbHumanActualRepository
    {
        private readonly EIDSSContext _context;

        public TlbHumanActualRepository(EIDSSContext context)
        {
            _context = context;
        }

        public async Task<bool> IsPersonIDExistsAsync(string strPersonID, long? idfHumanActual)
        {
            if (string.IsNullOrEmpty(strPersonID))
            {
                return false;
            }

            return await _context.TlbHumanActual.AnyAsync(
                x => x.StrPersonID == strPersonID &&
                (!idfHumanActual.HasValue || x.IdfHumanActual != idfHumanActual));
        }

        public async Task<int> UpdateAsync(UpdateHumanActualRequestModel request)
        {
            var human = await _context.TlbHumanActual.FirstOrDefaultAsync(x => x.IdfHumanActual == request.HumanActualId);
            if (human == null)
            {
                return 0;
            }

            human.DatDateOfBirth = request.DateOfBirth;
            human.DatDateOfDeath = request.DateOfDeath;

            _context.Entry(human).State = EntityState.Modified;

            return await _context.SaveChangesAsync();
        }
    }
}
