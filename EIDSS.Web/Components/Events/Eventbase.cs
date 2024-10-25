using EIDSS.Web.Components.Events.CustomEventArgs;
using Microsoft.AspNetCore.Components;
using System;

namespace EIDSS.Web.Components.Events
{
    public class Eventbase:ComponentBase
    {
        public static event EventHandler<NotificationEventArgs> NotificationTriggered;

        public static event EventHandler NotificationCompleted;

        public void TriggerNotification(Notification notification)
        {
            NotificationTriggered?.Invoke(this, new NotificationEventArgs {
                
                Notification = notification

            });

        }

        public void NotificationComplated(Notification notification)
        {
            NotificationCompleted?.Invoke(this,null);

        }
    }
}
