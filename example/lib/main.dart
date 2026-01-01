import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms_notification_listener/sms_notification_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String status = 'Idle';
  final List<SmsMessage> _messages = [];
  StreamSubscription<SmsMessage>? _smsSubscription;

  Future<void> startListening() async {
    setState(() {
      status = 'Checking permissions...';
    });

    bool hasPermission = await SmsNotificationListener.hasPermission;
    if (!hasPermission) {
      setState(() {
        status = 'Requesting permissions...';
      });
      hasPermission = await SmsNotificationListener.requestPermission();
    }

    if (!hasPermission) {
      setState(() {
        status = 'Permission denied';
      });
      return;
    }

    final result = await SmsNotificationListener.startListening();
    if (result) {
      _smsSubscription?.cancel();
      _smsSubscription = SmsNotificationListener.onSmsReceived.listen((
        message,
      ) {
        setState(() {
          _messages.insert(0, message);
        });
      });
    }

    setState(() {
      status = 'Listening: $result';
    });
  }

  Future<void> stopListening() async {
    final result = await SmsNotificationListener.stopListening();
    await _smsSubscription?.cancel();
    _smsSubscription = null;
    setState(() {
      status = 'Stopped: $result';
    });
  }

  @override
  void dispose() {
    _smsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SMS Listener')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: $status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: startListening,
                    child: const Text('Start Listening'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: stopListening,
                    child: const Text('Stop Listening'),
                  ),
                ],
              ),
              const Divider(height: 30),
              const Text(
                'Messages:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: Text('No messages received yet'))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(msg.address ?? 'Unknown'),
                              subtitle: Text(msg.body ?? ''),
                              trailing: Text(
                                msg.date != null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                        msg.date!,
                                      ).toString().split('.').first
                                    : '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
