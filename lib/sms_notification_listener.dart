import 'dart:async';
import 'package:flutter/services.dart';

/// Represents an SMS message received
class SmsMessage {
  final String? address;
  final String? body;
  final int? date;
  final int? dateSent;

  SmsMessage({this.address, this.body, this.date, this.dateSent});

  factory SmsMessage.fromMap(Map<dynamic, dynamic> map) {
    return SmsMessage(
      address: map['address'] as String?,
      body: map['body'] as String?,
      date: map['date'] as int?,
      dateSent: map['date_sent'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'body': body,
      'date': date,
      'date_sent': dateSent,
    };
  }

  @override
  String toString() {
    return 'SmsMessage(address: $address, body: $body, date: $date, dateSent: $dateSent)';
  }
}

/// Main plugin class for listening to SMS notifications
class SmsNotificationListener {
  static const MethodChannel _channel = MethodChannel(
    'sms_notification_listener',
  );
  static const EventChannel _eventChannel = EventChannel(
    'sms_notification_listener/events',
  );

  static Stream<SmsMessage>? _onSmsReceived;

  /// Stream of incoming SMS messages
  static Stream<SmsMessage> get onSmsReceived {
    _onSmsReceived ??= _eventChannel.receiveBroadcastStream().map(
      (dynamic event) => SmsMessage.fromMap(event as Map),
    );
    return _onSmsReceived!;
  }

  /// Check if SMS permissions are granted
  static Future<bool> get hasPermission async {
    try {
      final bool result = await _channel.invokeMethod('hasPermission');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Request SMS permissions
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermission');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Start listening for SMS messages
  static Future<bool> startListening() async {
    try {
      final bool result = await _channel.invokeMethod('startListening');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Stop listening for SMS messages
  static Future<bool> stopListening() async {
    try {
      final bool result = await _channel.invokeMethod('stopListening');
      return result;
    } catch (e) {
      return false;
    }
  }
}
