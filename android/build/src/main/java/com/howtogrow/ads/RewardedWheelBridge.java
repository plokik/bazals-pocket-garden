package com.howtogrow.ads;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import java.lang.ref.WeakReference;
import org.json.JSONObject;

/** Narrow JavaClassWrapper bridge. SDK callbacks never mutate game inventory.
 * An earned receipt survives process death until Godot confirms a durable save.
 * No live IDs, mediators, banner ads or automatic ad displays are supported.
 */
public final class RewardedWheelBridge {
    private static final String TEST_UNIT = "ca-app-pub-3940256099942544/5224354917";
    private static WeakReference<Activity> activity = new WeakReference<>(null);
    private static SharedPreferences prefs;
    private static final Handler UI = new Handler(Looper.getMainLooper());
    private static String token = "";
    private static String status = "idle";
    private static boolean earned;
    private static volatile boolean initialized;
    private static boolean acknowledged;
    private RewardedWheelBridge() {}

    public static synchronized void initialize(Activity owner) {
        activity = new WeakReference<>(owner);
        prefs = owner.getSharedPreferences("fortune_wheel_test_ads", 0);
        String receipt = prefs.getString("earned", "");
        if (!receipt.isEmpty() && token.isEmpty()) {
            token = receipt;
            earned = true;
            status = "closed";
        }
        // SDK initialization is intentionally lazy: opening the wheel is offline.
    }

    public static synchronized String getState() {
        try {
            return new JSONObject().put("id", token).put("status", status)
                .put("earned", earned).toString();
        } catch (Exception ignored) { return "{}"; }
    }

    public static synchronized boolean request(String id) {
        Activity owner = activity.get();
        if (owner == null || owner.isFinishing() || !token.isEmpty()
                || id == null || !id.matches("[0-9a-f]{32}")) return false;
        token = id;
        status = "loading";
        earned = false;
        acknowledged = false;
        UI.post(() -> {
            if (initialized) load(owner, id);
            else new Thread(() -> MobileAds.initialize(owner.getApplicationContext(), result -> {
                initialized = true;
                UI.post(() -> load(owner, id));
            }), "WheelAdsInit").start();
        });
        UI.postDelayed(() -> failIfLoading(id), 60000);
        return true;
    }

    private static synchronized boolean isLoading(String id) {
        return token.equals(id) && status.equals("loading");
    }

    private static synchronized void failIfLoading(String id) {
        if (isLoading(id)) status = "failed";
    }

    private static void load(Activity owner, String id) {
        if (!isLoading(id) || owner.isFinishing() || owner.isDestroyed()) {
            failIfLoading(id); return;
        }
        RewardedAd.load(owner, TEST_UNIT, new AdRequest.Builder().build(), new RewardedAdLoadCallback() {
            @Override public void onAdFailedToLoad(@NonNull LoadAdError error) {
                Log.w("WheelAds", "Load failed: " + error.getDomain() + "/" + error.getCode()
                    + " " + error.getMessage());
                failIfLoading(id);
            }
            @Override public void onAdLoaded(@NonNull RewardedAd ad) {
                synchronized (RewardedWheelBridge.class) {
                    if (!isLoading(id)) return;
                    status = "showing";
                }
                ad.setFullScreenContentCallback(new FullScreenContentCallback() {
                    @Override public void onAdDismissedFullScreenContent() { closed(id, "closed"); }
                    @Override public void onAdFailedToShowFullScreenContent(@NonNull AdError error) { closed(id, "failed"); }
                });
                if (owner.isFinishing() || owner.isDestroyed()) { closed(id,"failed"); return; }
                ad.show(owner, reward -> {
                    synchronized (RewardedWheelBridge.class) {
                        if (!token.equals(id) || earned) return;
                        earned = true;
                        // Commit before the game can acknowledge and before the ad closes.
                        prefs.edit().putString("earned", id).commit();
                    }
                });
            }
        });
    }

    private static synchronized void closed(String id, String state) {
        if (!token.equals(id)) return;
        status = state;
        if (acknowledged) clear();
    }

    public static synchronized void acknowledge(String id) {
        if (!token.equals(id)) return;
        prefs.edit().remove("earned").commit();
        acknowledged = true;
        if (!status.equals("showing")) clear();
    }

    private static void clear() {
        token = ""; status = "idle"; earned = false; acknowledged = false;
    }
}
