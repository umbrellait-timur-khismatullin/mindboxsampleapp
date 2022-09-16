package com.example.mindboxsampleapp

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import cloud.mindbox.mindbox_android.MindboxAndroidPlugin
import cloud.mindbox.mobile_sdk.Mindbox

import io.flutter.embedding.android.FlutterActivity


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        processMindboxIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        processMindboxIntent(intent)
    }

    private fun processMindboxIntent(intent: Intent?) {
        intent?.let {
            // Проверяем, что интент - это пуш Mindbox
            val uniqueKey = intent.getStringExtra("uniq_push_key")
            if (uniqueKey != null) {
                Mindbox.onPushClicked(this, it)
                Mindbox.onNewIntent(intent)
                // Передача ссылки из пуша во Flutter
                val link = Mindbox.getUrlFromPushIntent(intent) ?: ""
                val payload = Mindbox.getPayloadFromPushIntent(intent) ?: ""
                MindboxAndroidPlugin.pushClicked(link, payload)
            }
        }
    }
}
