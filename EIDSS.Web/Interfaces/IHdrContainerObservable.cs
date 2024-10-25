using System;

namespace EIDSS.Domain.Interfaces;

public interface IHdrContainerObservable
{
    IDisposable Subscribe(IHdrContainerObserver observer);
}