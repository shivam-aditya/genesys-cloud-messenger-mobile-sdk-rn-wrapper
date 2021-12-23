package com.genesys.messenger

import android.content.pm.ActivityInfo
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod


class GenesysCloud(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {
    private var screenOrientation: Int = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED

    override fun getName(): String {
        return "GenesysCloud"
    }

    @ReactMethod
    fun startChat(deploymentId: String, domain: String, tokenStoreKey: String, logging: Boolean) {
        reactApplicationContext.let {
            currentActivity?.run {
                startActivity(
                    GenesysCloudChatActivity.intentFactory(
                        deploymentId, domain, tokenStoreKey, logging, screenOrientation
                    )
                );
            }
        }
    }

    @ReactMethod
    fun requestScreenOrientation(orientation:Int){
        screenOrientation = orientation
    }

    override fun getConstants(): Map<String, Any>? {
        val constants: MutableMap<String, Any> = HashMap()
        constants["SCREEN_ORIENTATION_PORTRAIT"] = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        constants["SCREEN_ORIENTATION_LANDSCAPE"] = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        constants["SCREEN_ORIENTATION_NONE"] = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        constants["SCREEN_ORIENTATION_LOCKED"] = ActivityInfo.SCREEN_ORIENTATION_LOCKED
        return constants
    }

}
