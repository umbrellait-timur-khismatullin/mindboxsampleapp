package com.example.mindboxsampleapp

import cloud.mindbox.mobile_sdk.Mindbox
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage


class FirebaseService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Mindbox.updatePushToken(applicationContext, token)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Метод возвращает boolean, чтобы можно было сделать фолбек для обработки пуш уведомлений
        val messageWasHandled = Mindbox.handleRemoteMessage(
            context = applicationContext,
            activities = mapOf(),
            message = remoteMessage,
            channelId = "notification_channel_id", // Идентификатор канала для уведомлений, отправленных из Mindbox
            channelName = "notification_channel_name", // Название канала
            pushSmallIcon = android.R.drawable.ic_dialog_info, // Маленькая иконка для уведомлений
            defaultActivity = MainActivity::class.java,
            channelDescription = "notification_channel_description" // Описание канала
        )

        if (!messageWasHandled) {
            // Если пуш был не от Mindbox или в нем некорректные данные, то можно написать фолбе для его обработки
        }
    }
}