import 'package:flutter/material.dart';
import 'enter_code_screen.dart';
import 'share_code_screen.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../utils/device_id_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  Future<void> _initializeDeviceId() async {
    try {
      // Check if a device ID is already saved
      bool hasSavedDeviceId = await DeviceIDManager.hasDeviceId();

      if (!hasSavedDeviceId) {
        // Fetch device ID
        final deviceId = await PlatformDeviceId.getDeviceId;

        if (deviceId != null) {
          // Save the device ID
          await DeviceIDManager.saveDeviceId(deviceId);
          print("Device ID saved: $deviceId");
        } else {
          print("Device ID could not be fetched.");
        }
      }

      // Retrieve the device ID
      final storedDeviceId = await DeviceIDManager.getDeviceId();
      setState(() {
        _deviceId = storedDeviceId;
      });
    } catch (e) {
      setState(() {
        _deviceId = 'Error fetching Device ID: $e';
      });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(50, 100, 50, 50),
                child: Text("Select An Option",
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                    ))),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShareCodeScreen()),
                  );
                },
                style:
                    ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
                child: Text("Start Session".toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EnterCodeScreen()),
                  );
                },
                style:
                    ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
                child: Text("Enter Code".toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
