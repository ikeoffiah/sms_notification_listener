import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sms_notification_listener/sms_notification_listener.dart';

void main() {
  group('SmsMessage', () {
    final Map<String, dynamic> smsMap = {
      'address': '1234567890',
      'body': 'Hello Test',
      'date': 123456789,
      'date_sent': 123456780,
    };

    test('SmsMessage.fromMap creates correct object', () {
      final message = SmsMessage.fromMap(smsMap);
      expect(message.address, '1234567890');
      expect(message.body, 'Hello Test');
      expect(message.date, 123456789);
      expect(message.dateSent, 123456780);
    });

    test('SmsMessage.toMap creates correct map', () {
      final message = SmsMessage(
        address: '1234567890',
        body: 'Hello Test',
        date: 123456789,
        dateSent: 123456780,
      );
      expect(message.toMap(), smsMap);
    });

    test('SmsMessage.toString returns expected string', () {
      final message = SmsMessage(
        address: '1234567890',
        body: 'Hello Test',
        date: 123456789,
        dateSent: 123456780,
      );
      expect(
        message.toString(),
        'SmsMessage(address: 1234567890, body: Hello Test, date: 123456789, dateSent: 123456780)',
      );
    });
  });

  group('SmsNotificationListener', () {
    const MethodChannel channel = MethodChannel('sms_notification_listener');
    final List<MethodCall> log = <MethodCall>[];

    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case 'hasPermission':
                return true;
              case 'requestPermission':
                return true;
              case 'startListening':
                return true;
              case 'stopListening':
                return true;
              default:
                return null;
            }
          });
      log.clear();
    });

    test('hasPermission returns true', () async {
      final result = await SmsNotificationListener.hasPermission;
      expect(result, isTrue);
      expect(log, <Matcher>[isMethodCall('hasPermission', arguments: null)]);
    });

    test('requestPermission returns true', () async {
      final result = await SmsNotificationListener.requestPermission();
      expect(result, isTrue);
      expect(log, <Matcher>[
        isMethodCall('requestPermission', arguments: null),
      ]);
    });

    test('startListening returns true', () async {
      final result = await SmsNotificationListener.startListening();
      expect(result, isTrue);
      expect(log, <Matcher>[isMethodCall('startListening', arguments: null)]);
    });

    test('stopListening returns true', () async {
      final result = await SmsNotificationListener.stopListening();
      expect(result, isTrue);
      expect(log, <Matcher>[isMethodCall('stopListening', arguments: null)]);
    });

    test('onSmsReceived emits messages', () async {
      const EventChannel eventChannel = EventChannel(
        'sms_notification_listener/events',
      );
      final Map<String, dynamic> smsMap = {
        'address': '123456',
        'body': 'Stream Test',
        'date': 1600000000000,
        'date_sent': 1600000000000,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, SmsMockStreamHandler(smsMap));

      final message = await SmsNotificationListener.onSmsReceived.first;

      expect(message.address, '123456');
      expect(message.body, 'Stream Test');
    });
  });
}

class SmsMockStreamHandler extends MockStreamHandler {
  final Map<String, dynamic> smsMap;

  SmsMockStreamHandler(this.smsMap);

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    events.success(smsMap);
  }

  @override
  void onCancel(Object? arguments) {}
}
