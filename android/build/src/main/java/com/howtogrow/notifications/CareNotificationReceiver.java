package com.howtogrow.notifications;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public final class CareNotificationReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        CareNotificationBridge.showReminder(context, intent);
    }
}
