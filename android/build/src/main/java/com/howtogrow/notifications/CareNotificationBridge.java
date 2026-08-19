package com.howtogrow.notifications;

import android.Manifest;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.Application;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import java.lang.ref.WeakReference;

public final class CareNotificationBridge {
    static final String CHANNEL_ID = "care_reminders";
    static final int NOTIFICATION_ID = 4401;
    static final int ALARM_REQUEST_CODE = 4401;
    static final int CONTENT_REQUEST_CODE = 4403;
    public static final String ACTION_OPEN_CARE = "com.howtogrow.notifications.OPEN_CARE";
    private static final String EXTRA_OPEN_SLOT = "care_open_slot";
    private static final int PERMISSION_REQUEST_CODE = 4402;
    private static final String PREFS_NAME = "how_to_grow_care_notifications";
    private static final String PREF_TRIGGER = "trigger_millis";
    private static final String PREF_SLOT = "slot_number";
    private static final String PREF_TITLE = "title";
    private static final String PREF_BODY = "body";
    private static final String PREF_PERMISSION_REQUESTED = "permission_requested";

    private static Context appContext;
    private static WeakReference<Activity> currentActivity = new WeakReference<>(null);
    private static boolean lifecycleRegistered;
    private static int startedActivityCount;
    private static int pendingOpenedSlotNumber;

    private CareNotificationBridge() {}

    public static synchronized void initialize(Activity activity) {
        if (activity == null) {
            return;
        }
        appContext = activity.getApplicationContext();
        currentActivity = new WeakReference<>(activity);
        createChannel(appContext);
        if (!lifecycleRegistered) {
            lifecycleRegistered = true;
            Application application = activity.getApplication();
            application.registerActivityLifecycleCallbacks(new CareActivityLifecycleCallbacks());
        }
    }

    static void updateActivity(Activity activity) {
        if (activity != null) {
            currentActivity = new WeakReference<>(activity);
            if (appContext == null) {
                appContext = activity.getApplicationContext();
            }
        }
    }

    static synchronized void activityStarted(Activity activity) {
        updateActivity(activity);
        startedActivityCount += 1;
    }

    static synchronized void activityStopped() {
        startedActivityCount = Math.max(0, startedActivityCount - 1);
    }

    static synchronized boolean isActivityVisible() {
        return startedActivityCount > 0;
    }

    public static boolean isSupported() {
        return appContext != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N;
    }

    public static boolean hasPermission() {
        if (!isSupported()) {
            return false;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
                && appContext.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            return false;
        }
        NotificationManager manager = (NotificationManager) appContext.getSystemService(Context.NOTIFICATION_SERVICE);
        return manager != null && manager.areNotificationsEnabled();
    }

    public static boolean requestPermission() {
        if (!isSupported()) {
            return false;
        }
        Activity activity = currentActivity.get();
        SharedPreferences prefs = prefs();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
                && appContext.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
                && activity != null
                && !prefs.getBoolean(PREF_PERMISSION_REQUESTED, false)) {
            prefs.edit().putBoolean(PREF_PERMISSION_REQUESTED, true).apply();
            activity.requestPermissions(new String[] {Manifest.permission.POST_NOTIFICATIONS}, PERMISSION_REQUEST_CODE);
            return true;
        }
        return openNotificationSettings();
    }

    public static boolean openNotificationSettings() {
        if (!isSupported()) {
            return false;
        }
        Intent intent = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, appContext.getPackageName())
                .setData(Uri.parse("package:" + appContext.getPackageName()))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        appContext.startActivity(intent);
        return true;
    }

    public static synchronized void captureLaunchIntent(Intent intent) {
        if (intent == null || !ACTION_OPEN_CARE.equals(intent.getAction())) {
            return;
        }
        int slotNumber = intent.getIntExtra(EXTRA_OPEN_SLOT, 0);
        if (slotNumber > 0) {
            pendingOpenedSlotNumber = slotNumber;
        }
        intent.removeExtra(EXTRA_OPEN_SLOT);
        intent.setAction(null);
    }

    public static synchronized int consumeOpenedSlotNumber() {
        int slotNumber = pendingOpenedSlotNumber;
        pendingOpenedSlotNumber = 0;
        return slotNumber;
    }

    public static boolean scheduleReminder(long triggerMillis, int slotNumber, String title, String body) {
        if (!hasPermission()) {
            return false;
        }
        long safeTrigger = Math.max(System.currentTimeMillis() + 15_000L, triggerMillis);
        AlarmManager alarmManager = (AlarmManager) appContext.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            return false;
        }
        PendingIntent pendingIntent = reminderPendingIntent(appContext, slotNumber, title, body);
        alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, safeTrigger, pendingIntent);
        prefs().edit()
                .putLong(PREF_TRIGGER, safeTrigger)
                .putInt(PREF_SLOT, slotNumber)
                .putString(PREF_TITLE, title)
                .putString(PREF_BODY, body)
                .apply();
        return true;
    }

    public static void cancelReminder() {
        if (!isSupported()) {
            return;
        }
        AlarmManager alarmManager = (AlarmManager) appContext.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager != null) {
            alarmManager.cancel(reminderPendingIntent(appContext, 0, "", ""));
        }
        clearScheduledReminder();
    }

    public static long getScheduledAtMillis() {
        return isSupported() ? prefs().getLong(PREF_TRIGGER, 0L) : 0L;
    }

    static void rescheduleStoredReminder(Context context) {
        if (context == null) {
            return;
        }
        appContext = context.getApplicationContext();
        createChannel(appContext);
        SharedPreferences prefs = prefs();
        long trigger = prefs.getLong(PREF_TRIGGER, 0L);
        if (trigger <= 0L || !hasPermission()) {
            return;
        }
        int slot = prefs.getInt(PREF_SLOT, 1);
        String title = prefs.getString(PREF_TITLE, "Bazal’s Pocket Garden · kontrola péče");
        String body = prefs.getString(PREF_BODY, "Rostlina potřebuje kontrolu.");
        scheduleReminder(Math.max(trigger, System.currentTimeMillis() + 30_000L), slot, title, body);
    }

    static void showReminder(Context context, Intent sourceIntent) {
        if (context == null) {
            return;
        }
        appContext = context.getApplicationContext();
        createChannel(appContext);
        if (isActivityVisible()) {
            clearScheduledReminder();
            return;
        }
        if (!hasPermission()) {
            clearScheduledReminder();
            return;
        }
        String title = sourceIntent.getStringExtra(PREF_TITLE);
        String body = sourceIntent.getStringExtra(PREF_BODY);
        int slot = sourceIntent.getIntExtra(PREF_SLOT, 1);
        if (title == null || title.isEmpty()) {
            title = "Bazal’s Pocket Garden · kontrola péče";
        }
        if (body == null || body.isEmpty()) {
            body = "Květináč " + slot + " potřebuje kontrolu.";
        }
        Intent launchIntent = appContext.getPackageManager().getLaunchIntentForPackage(appContext.getPackageName());
        PendingIntent contentIntent = null;
        if (launchIntent != null) {
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            launchIntent.setAction(ACTION_OPEN_CARE);
            launchIntent.putExtra(EXTRA_OPEN_SLOT, slot);
            contentIntent = PendingIntent.getActivity(appContext, CONTENT_REQUEST_CODE, launchIntent, immutableFlags(PendingIntent.FLAG_UPDATE_CURRENT));
        }
        Notification.Builder builder = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? new Notification.Builder(appContext, CHANNEL_ID)
                : new Notification.Builder(appContext);
        builder.setSmallIcon(android.R.drawable.ic_popup_reminder)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(new Notification.BigTextStyle().bigText(body))
                .setAutoCancel(true)
                .setCategory(Notification.CATEGORY_REMINDER)
                .setVisibility(Notification.VISIBILITY_PRIVATE)
                .setContentIntent(contentIntent);
        NotificationManager manager = (NotificationManager) appContext.getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager != null) {
            manager.notify(NOTIFICATION_ID, builder.build());
        }
        clearScheduledReminder();
    }

    private static PendingIntent reminderPendingIntent(Context context, int slotNumber, String title, String body) {
        Intent intent = new Intent(context, CareNotificationReceiver.class)
                .setAction(context.getPackageName() + ".CARE_REMINDER")
                .putExtra(PREF_SLOT, slotNumber)
                .putExtra(PREF_TITLE, title)
                .putExtra(PREF_BODY, body);
        return PendingIntent.getBroadcast(context, ALARM_REQUEST_CODE, intent, immutableFlags(PendingIntent.FLAG_UPDATE_CURRENT));
    }

    private static int immutableFlags(int baseFlags) {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? baseFlags | PendingIntent.FLAG_IMMUTABLE : baseFlags;
    }

    private static SharedPreferences prefs() {
        return appContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    private static void clearScheduledReminder() {
        if (appContext != null) {
            prefs().edit().remove(PREF_TRIGGER).remove(PREF_SLOT).remove(PREF_TITLE).remove(PREF_BODY).apply();
        }
    }

    private static void createChannel(Context context) {
        if (context == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return;
        }
        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager == null) {
            return;
        }
        NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Péče o rostliny", NotificationManager.IMPORTANCE_DEFAULT);
        channel.setDescription("Dobrovolná upozornění na další kontrolu rostliny.");
        manager.createNotificationChannel(channel);
    }
}
