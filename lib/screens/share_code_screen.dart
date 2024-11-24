import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: unused_import
import 'dart:io';
import 'movie_selection_screen.dart';
import '../utils/device_id_manager.dart';

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  Future<List<Data>> startSession() async {
    String? deviceId = await DeviceIDManager.getDeviceId();

    if (deviceId != null) {
      var response = await http.get(
        Uri.parse(
            'https://movie-night-api.onrender.com/start-session?device_id=$deviceId'),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Night',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
            )),
        backgroundColor: const Color.fromARGB(84, 0, 0, 0),
      ),
      body: Center(
          child: FutureBuilder(
              future: startSession(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (snapshot.hasData && snapshot.data != null)
                      Column(
                        children: [
                          Text('Code: ${snapshot.data![0].code}',
                              style: textTheme.headlineLarge
                                  ?.copyWith(color: colorScheme.onPrimary)),
                          const SizedBox(height: 20),
                          Text("Share this code with your friends",
                              style: textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold))
                        ],
                      )
                    else
                      Text('Error: ${snapshot.error}',
                          style: textTheme.headlineMedium
                              ?.copyWith(color: colorScheme.onPrimary)),
                    const SizedBox(height: 80),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                          onPressed: () {
                            if (snapshot.hasData && snapshot.data != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieSelectionScreen(
                                      sessionId: snapshot.data![0].sessionId),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Session is not available yet')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12)),
                          child: Text(
                            'Begin'.toUpperCase(),
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          )),
                    ),
                  ],
                );
              })),
    );
  }
}

class Data {
  final String sessionId;
  final String message;
  final String code;

  Data({required this.sessionId, required this.message, required this.code});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
        sessionId: json['session_id'] ?? '',
        message: json['message'] ?? '',
        code: json['code'] ?? '');
  }
}
