package com.example.mindboxsampleapp
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import cloud.mindbox.mobile_sdk.Mindbox
import cloud.mindbox.mobile_sdk.MindboxConfiguration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    lateinit  var channel: MethodChannel
    private var deviceUuidSubscription: String? = null
    private var tokenSubscription: String? = null

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
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("pushClicked", listOf(link, payload))
                }
            }

        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor, "mindbox.cloud/flutter-sdk")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSdkVersion" -> {
                    result.success(Mindbox.getSdkVersion())
                }
                "init" -> {
                    if (call.arguments is HashMap<*, *>) {
                        val args = call.arguments as HashMap<*, *>
                        val domain: String = args["domain"] as String
                        val endpointId: String = args["endpointAndroid"] as String
                        val previousDeviceUuid: String = args["previousDeviceUUID"] as String
                        val previousInstallId: String = args["previousInstallationId"] as String
                        val subscribeIfCreated: Boolean =
                            args["subscribeCustomerIfCreated"] as Boolean
                        val shouldCreateCustomer: Boolean = args["shouldCreateCustomer"] as Boolean
                        val config = MindboxConfiguration.Builder(context, domain, endpointId)
                            .setPreviousDeviceUuid(previousDeviceUuid)
                            .setPreviousInstallationId(previousInstallId)
                            .subscribeCustomerIfCreated(subscribeIfCreated)
                            .shouldCreateCustomer(shouldCreateCustomer)
                            .build()
                        Mindbox.init(context, config, listOf())
                        result.success("initialized")
                    } else {
                        result.error("-1", "Initialization error", "Wrong argument type")
                    }
                }
                "getDeviceUUID" -> {
                    if (deviceUuidSubscription != null) {
                        Mindbox.disposeDeviceUuidSubscription(deviceUuidSubscription!!)
                    }
                    deviceUuidSubscription = Mindbox.subscribeDeviceUuid { uuid ->
                        result.success(uuid)
                    }
                }
                "getToken" -> {
                    if (tokenSubscription != null) {
                        Mindbox.disposePushTokenSubscription(tokenSubscription!!)
                    }
                    tokenSubscription = Mindbox.subscribePushToken { token ->
                        result.success(token)
                    }
                }
                "executeAsyncOperation" -> {
                    if (call.arguments is List<*>) {
                        val args = call.arguments as List<*>
                        Mindbox.executeAsyncOperation(context, args[0] as String, args[1] as String)
                        result.success("executed")
                    }
                }
                "executeSyncOperation" -> {
                    if (call.arguments is List<*>) {
                        val args = call.arguments as List<*>
                        Mindbox.executeSyncOperation(
                            context,
                            args[0] as String,
                            args[1] as String,
                            { response ->
                                result.success(response)
                            },
                            { error ->
                                result.error(
                                    error.statusCode.toString(),
                                    error.toJson(),
                                    null
                                )
                            })
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
