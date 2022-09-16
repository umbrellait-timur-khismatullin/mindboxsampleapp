package com.example.mindboxsampleapp

import android.app.Application
import cloud.mindbox.mindbox_firebase.MindboxFirebase
import cloud.mindbox.mobile_sdk.Mindbox

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Mindbox.initPushServices(this, listOf(MindboxFirebase))
    }
}