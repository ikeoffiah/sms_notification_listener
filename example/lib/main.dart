import 'package:flutter/material.dart';
import 'package:sms_notification_listener/sms_notification_listener.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<SmsMessage> _messages = [];
  StreamSubscription<SmsMessage>? _subscription;
  bool _hasPermission = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await SmsNotificationListener.hasPermission;
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await SmsNotificationListener.requestPermission();
    setState(() {
      _hasPermission = granted;
    });
    if (granted) {
      _showSnackBar('Permission granted!');
    } else {
      _showSnackBar('Permission denied');
    }
  }

  void _startListening() async {
    final started = await SmsNotificationListener.startListening();
    if (started) {
      _subscription = SmsNotificationListener.onSmsReceived.listen((message) {
        setState(() {
          _messages.insert(0, message);
        });
        _showSnackBar('New SMS from ${message.address}');
      });
      setState(() {
        _isListening = true;
      });
      _showSnackBar('Started listening for SMS');
    } else {
      _showSnackBar('Failed to start listening');
    }
  }

  void _stopListening() async {
    await _subscription?.cancel();
    await SmsNotificationListener.stopListening();
    setState(() {
      _isListening = false;
    });
    _showSnackBar('Stopped listening for SMS');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Notification Listener'),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Permission Status: ${_hasPermission ? "Granted" : "Not Granted"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Listening Status: ${_isListening ? "Active" : "Inactive"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_hasPermission)
                    ElevatedButton(
                      onPressed: _requestPermission,
                      child: const Text('Request Permission'),
                    ),
                  if (_hasPermission && !_isListening)
                    ElevatedButton(
                      onPressed: _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Start Listening'),
                    ),
                  if (_isListening)
                    ElevatedButton(
                      onPressed: _stopListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Stop Listening'),
                    ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Received Messages (${_messages.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages received yet.\nSend an SMS to this device to test.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final date = message.date != null
                            ? DateTime.fromMillisecondsSinceEpoch(message.date!)
                            : null;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.message),
                            ),
                            title: Text(message.address ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.body ?? 'No content'),
                                if (date != null)
                                  Text(
                                    '${date.hour}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
