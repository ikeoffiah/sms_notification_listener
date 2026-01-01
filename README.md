# SMS Notification Listener

A Flutter plugin to listen for incoming SMS notifications on Android devices. This plugin provides a simple API to handle SMS permissions and a stream of incoming SMS messages.

## Features

- 📱 Listen for incoming SMS messages in real-time.
- 🔐 Streamlined API for checking and requesting SMS permissions.
- 🏗️ Lightweight and easy to integrate.
- 🤖 Android-only support.

## Installation

Add `sms_notification_listener` to your `pubspec.yaml`:

```yaml
dependencies:
  sms_notification_listener: ^0.0.1
```

## Android Setup

To use this plugin, you must add the following permissions to your `AndroidManifest.xml` (located in `android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
```

> [!IMPORTANT]
> For Android 6.0 (API level 23) and above, you need to request permissions at runtime. This plugin handles the runtime permission request for you using `SmsNotificationListener.requestPermission()`.

## Usage

### 1. Handle Permissions

Before listening for messages, you need to ensure the app has the necessary permissions.

```dart
import 'package:sms_notification_listener/sms_notification_listener.dart';

// Check if permission is already granted
bool hasPermission = await SmsNotificationListener.hasPermission;

if (!hasPermission) {
  // Request permission from the user
  bool granted = await SmsNotificationListener.requestPermission();
  if (granted) {
      // Proceed to listen
  }
}
```

### 2. Start Listening

Once permissions are granted, you can start the listener and subscribe to the `onSmsReceived` stream.

```dart
// Start the SMS listener service
await SmsNotificationListener.startListening();

// Subscribe to incoming messages
final subscription = SmsNotificationListener.onSmsReceived.listen((SmsMessage message) {
  print('SMS Received from: ${message.address}');
  print('Message: ${message.body}');
});
```

### 3. Stop Listening

To stop receiving SMS notifications, call `stopListening()`.

```dart
await SmsNotificationListener.stopListening();
subscription.cancel();
```

## Data Model: SmsMessage

The `onSmsReceived` stream emits `SmsMessage` objects with the following properties:

| Property | Type | Description |
| :--- | :--- | :--- |
| `address` | `String?` | The originating address (phone number) of the SMS. |
| `body` | `String?` | The content of the SMS message. |
| `date` | `int?` | The timestamp when the message was received. |
| `dateSent` | `int?` | The timestamp when the message was sent. |

## Limitations

- **Android Only**: This plugin currently only supports Android.
- **Background Support**: The listener works while the app is in the foreground or background (as a service), but the behavior may vary across different Android versions due to battery optimization settings.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
