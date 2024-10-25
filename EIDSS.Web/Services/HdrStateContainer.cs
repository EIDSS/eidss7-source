using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.Domain.Interfaces;

namespace EIDSS.Web.Services;

public interface IHdrStateContainer : IHdrContainerObservable
{
    public DateTime? DateEntered { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public DateTime? DateOfDeath { get; set; }
    public DateTime? DateOfDischarge { get; set; }
    public DateTime? DateOfHospitalization { get; set; }
    public DateTime? DateOfSymptomsOnset { get; set; }
    public DateTime? DateOfNotification { get; set; }
    public DateTime? DateOfDiagnosis { get; set; }
    public DateTime? DateOfStartInvestigation { get; set; }
    public DateTime? DateOfChangedDiagnosis { get; set; }
    public DateTime? DateOfCompletion { get; set; }
    public DateTime? DateOfSoughtCareFirst { get; set; }
    public DateTime? DateOfFinalCaseClassification { get; set; }
    public DateTime? DateOfExposure { get; set; }
    public DateTime? DateOfCurrentSampleSent { get; set; }
    public DateTime? DateOfCurrentSampleCollection { get; set; }
    public DateTime? MinimumValueOfSampleSentDateFromSamples { get; set; }
    public DateTime? MinimumValueOfSampleCollectionDateFromSamples { get; set; }
    public DateTime? MinimumValueOfLastContactDateFromContacts { get; set; }
    public long? InvestigatedByOfficeId { get; set; }

    public DateTime? GetEndDateForAgeCalculation();
    Task ChangeWithNotifyAboutStateChange(Action<IHdrStateContainer> updatesMethod);
}

public class HdrStateContainer : IHdrStateContainer
{
    private readonly HashSet<IHdrContainerObserver> _observers = new();
    private HdrStateContainer LastState { get; set; }
    
    public DateTime? DateEntered { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public DateTime? DateOfDeath { get; set; }
    public DateTime? DateOfDischarge { get; set; }
    public DateTime? DateOfHospitalization { get; set; }
    public DateTime? DateOfSymptomsOnset { get; set; }
    public DateTime? DateOfNotification { get; set; }
    public DateTime? DateOfDiagnosis { get; set; }
    public DateTime? DateOfChangedDiagnosis { get; set; }
    public DateTime? DateOfStartInvestigation { get; set; }
    public DateTime? DateOfCompletion { get; set; }
    public DateTime? DateOfSoughtCareFirst { get; set; }
    public DateTime? DateOfFinalCaseClassification { get; set; }
    public DateTime? DateOfExposure { get; set; }
    public DateTime? DateOfCurrentSampleSent { get; set; }
    public DateTime? DateOfCurrentSampleCollection { get; set; }
    public DateTime? MinimumValueOfLastContactDateFromContacts { get; set; }
    public DateTime? MinimumValueOfSampleSentDateFromSamples { get; set; }
    public DateTime? MinimumValueOfSampleCollectionDateFromSamples { get; set; }
    public long? InvestigatedByOfficeId { get; set; }

    public HdrStateContainer()
    {
        LastState = this;
    }

    public DateTime? GetEndDateForAgeCalculation()
    {
        var date = DateOfSymptomsOnset ?? DateOfNotification ?? DateOfDiagnosis ?? DateEntered;

        if (DateOfDeath != null && DateOfDeath < (date ?? DateTime.Today))
        {
            return DateOfDeath;
        }

        return date;
    }

    public async Task ChangeWithNotifyAboutStateChange(Action<IHdrStateContainer> updatesMethod)
    {
        updatesMethod(this);
        foreach (var observer in _observers)
        {
            await observer.OnHdrStateContainerChange(this, LastState);
        }
        LastState = MemberwiseClone() as HdrStateContainer;
    }

    public IDisposable Subscribe(IHdrContainerObserver observer)
    {
        _observers.Add(observer);
        return new Unsubscriber(() =>
        {
            _observers.Remove(observer);
        }) ;
    }
    
    private class Unsubscriber(Action unsubscribeFromNotifications) : IDisposable
    {
        public void Dispose()
        {
            unsubscribeFromNotifications();
        }
    }
}