using System.Threading.Tasks;
using EIDSS.Web.Services;

namespace EIDSS.Domain.Interfaces;

public interface IHdrContainerObserver
{
    Task OnHdrStateContainerChange(IHdrStateContainer currentValue, IHdrStateContainer previous);
}