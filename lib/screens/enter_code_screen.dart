import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'movie_selection_screen.dart';
import '../utils/app_spacing.dart';
import '../utils/id_manager.dart';
import '../utils/http_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: unused_import
import 'dart:io';

final spacing = AppSpacing();

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  String? _sessionId;
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final MyData _data = MyData();
  List<Data> _sessionData = [];

  @override
  void initState() {
    super.initState();
    _initializeSessionId();
  }

  Future<void> _initializeSessionId() async {
    try {
      // Check if a device ID is already saved
      bool hasSavedSessionId = await SessionIDManager.hasSessionId();
      // print(hasSavedSessionId);

      if (!hasSavedSessionId) {
        // Fetch Session ID
        List<Data> sessionData = await joinSession();
        if (sessionData.isNotEmpty) {
          _sessionId = sessionData[0].sessionId;

          // Save the session ID
          await SessionIDManager.saveSessionId(_sessionId!);
          print("Session ID saved: $_sessionId");
        } else {
          throw Exception("No session data returned.");
        }
      }

      // Retrieve the device ID
      final storedSessionId = await SessionIDManager.getSessionId();
      setState(() {
        _sessionId = storedSessionId;
      });
    } catch (e) {
      setState(() {
        _sessionId = 'Error fetching Session ID: $e';
      });
    }
  }

  Future<List<Data>> joinSession() async {
    String? deviceId = await DeviceIDManager.getDeviceId();

    final httpHelper = HttpHelper();
    final joinSession = httpHelper.joinSessionUrl;

    if (deviceId != null) {
      var response = await http.get(
        Uri.parse('$joinSession?device_id=$deviceId&code=${_data.code}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as Map<String, dynamic>;
        // print(data);
        return [Data.fromJson(data)];
      } else {
        throw Exception('Failed to start session');
      }
    } else {
      throw Exception('Device ID is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Movie Night".toUpperCase(),
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
            )),
        //border
        backgroundColor: const Color.fromARGB(84, 0, 0, 0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
          child: Column(
            children: [
              Text('Enter the code you received',
                  style: textTheme.displayMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  )),
              const SizedBox(height: 50),
              Form(
                key: _formStateKey,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: Center(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                            letterSpacing: spacing.spacing),
                        decoration: InputDecoration(
                            labelText: 'Enter 4 digit code',
                            labelStyle: textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is empty, please enter a 4 digit code';
                          } else if (value.length != 4) {
                            return 'Please enter exactly 4 digits';
                          }
                          return null; // Valid input
                        },
                        onSaved: (String? value) {
                          _data.code = value != null ? int.parse(value) : 0;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12)),
                  onPressed: () async {
                    if (_formStateKey.currentState?.validate() ?? false) {
                      _formStateKey.currentState?.save();

                      try {
                        List<Data> session = await joinSession();

                        setState(() {
                          _sessionData = session;
                        });

                        // Print session info or navigate to the next screen
                        print('Session ID: ${_sessionData[0].sessionId}');
                        print('Message: ${_sessionData[0].message}');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieSelectionScreen(
                              sessionId: _sessionData[0].sessionId,
                            ),
                          ),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error fetching session: $error')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a 4 digit code')),
                      );
                    }
                  },
                  child: Text('Begin'.toUpperCase(),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Data {
  final String sessionId;
  final String message;

  Data({required this.sessionId, required this.message});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
        sessionId: json['session_id'] ?? '', message: json['message'] ?? '');
  }
}

class MyData {
  int? code;
}
