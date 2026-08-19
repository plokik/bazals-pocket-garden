package com.howtogrow.notifications;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

final class CareActivityLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
    @Override public void onActivityCreated(Activity activity, Bundle state) { CareNotificationBridge.updateActivity(activity); }
    @Override public void onActivityStarted(Activity activity) { CareNotificationBridge.activityStarted(activity); }
    @Override public void onActivityResumed(Activity activity) { CareNotificationBridge.updateActivity(activity); }
    @Override public void onActivityPaused(Activity activity) {}
    @Override public void onActivityStopped(Activity activity) { CareNotificationBridge.activityStopped(); }
    @Override public void onActivitySaveInstanceState(Activity activity, Bundle state) {}
    @Override public void onActivityDestroyed(Activity activity) {}
}
