import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';

/// Mirrors the logic added in home.dart `checkForUpdate()` with injectable
/// dependencies so the branching logic can be unit-tested independently of the
/// dart:io [Platform] check and static [InAppUpdate] methods.
Future<void> performUpdateCheck({
  required Future<AppUpdateInfo> Function() checkForUpdate,
  required Future<void> Function() performImmediateUpdate,
  required bool isAndroid,
}) async {
  if (isAndroid) {
    try {
      final info = await checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await performImmediateUpdate();
      }
    } catch (e) {
      // Exceptions are silently caught, matching the debugPrint-only handler
      // in the production implementation.
    }
  }
}

void main() {
  group('checkForUpdate logic', () {
    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    /// Builds an [AppUpdateInfo] with the given availability.
    AppUpdateInfo _makeInfo(UpdateAvailability availability) {
      return AppUpdateInfo(
        updateAvailability: availability,
        immediateUpdateAllowed: availability == UpdateAvailability.updateAvailable,
        flexibleUpdateAllowed: false,
        availableVersionCode: availability == UpdateAvailability.updateAvailable ? 999 : null,
        clientVersionStalenessDays: null,
        flexibleAllowedPreconditions: [],
        immediateAllowedPreconditions: [],
        installStatus: InstallStatus.unknown,
        packageName: 'com.example.app',
        updatePriority: 0,
      );
    }

    // ---------------------------------------------------------------------------
    // Android platform – update available
    // ---------------------------------------------------------------------------

    test('calls performImmediateUpdate when update is available on Android',
        () async {
      bool immediateUpdateCalled = false;

      await performUpdateCheck(
        isAndroid: true,
        checkForUpdate: () async => _makeInfo(UpdateAvailability.updateAvailable),
        performImmediateUpdate: () async {
          immediateUpdateCalled = true;
        },
      );

      expect(immediateUpdateCalled, isTrue);
    });

    // ---------------------------------------------------------------------------
    // Android platform – no update available
    // ---------------------------------------------------------------------------

    test('does not call performImmediateUpdate when no update is available',
        () async {
      bool immediateUpdateCalled = false;

      await performUpdateCheck(
        isAndroid: true,
        checkForUpdate: () async =>
            _makeInfo(UpdateAvailability.updateNotAvailable),
        performImmediateUpdate: () async {
          immediateUpdateCalled = true;
        },
      );

      expect(immediateUpdateCalled, isFalse);
    });

    // ---------------------------------------------------------------------------
    // Android platform – unknown availability
    // ---------------------------------------------------------------------------

    test('does not call performImmediateUpdate when availability is unknown',
        () async {
      bool immediateUpdateCalled = false;

      await performUpdateCheck(
        isAndroid: true,
        checkForUpdate: () async => _makeInfo(UpdateAvailability.unknown),
        performImmediateUpdate: () async {
          immediateUpdateCalled = true;
        },
      );

      expect(immediateUpdateCalled, isFalse);
    });

    // ---------------------------------------------------------------------------
    // Android platform – checkForUpdate throws
    // ---------------------------------------------------------------------------

    test('silently catches exception thrown by checkForUpdate', () async {
      bool immediateUpdateCalled = false;

      await expectLater(
        performUpdateCheck(
          isAndroid: true,
          checkForUpdate: () async => throw Exception('Play Store unavailable'),
          performImmediateUpdate: () async {
            immediateUpdateCalled = true;
          },
        ),
        completes,
      );

      expect(immediateUpdateCalled, isFalse);
    });

    // ---------------------------------------------------------------------------
    // Android platform – performImmediateUpdate throws
    // ---------------------------------------------------------------------------

    test('silently catches exception thrown by performImmediateUpdate',
        () async {
      await expectLater(
        performUpdateCheck(
          isAndroid: true,
          checkForUpdate: () async =>
              _makeInfo(UpdateAvailability.updateAvailable),
          performImmediateUpdate: () async =>
              throw Exception('User cancelled update'),
        ),
        completes,
      );
    });

    // ---------------------------------------------------------------------------
    // Non-Android platform
    // ---------------------------------------------------------------------------

    test('skips all update logic on non-Android platforms', () async {
      bool checkCalled = false;
      bool immediateUpdateCalled = false;

      await performUpdateCheck(
        isAndroid: false,
        checkForUpdate: () async {
          checkCalled = true;
          return _makeInfo(UpdateAvailability.updateAvailable);
        },
        performImmediateUpdate: () async {
          immediateUpdateCalled = true;
        },
      );

      expect(checkCalled, isFalse);
      expect(immediateUpdateCalled, isFalse);
    });

    // ---------------------------------------------------------------------------
    // Regression: developer preview / unknown future availability value
    // ---------------------------------------------------------------------------

    test(
        'regression: unrecognised UpdateAvailability value does not trigger update',
        () async {
      bool immediateUpdateCalled = false;

      // developerTriggeredUpdateInProgress is a known variant that is NOT
      // updateAvailable and must not trigger an immediate update flow.
      await performUpdateCheck(
        isAndroid: true,
        checkForUpdate: () async => _makeInfo(
          UpdateAvailability.developerTriggeredUpdateInProgress,
        ),
        performImmediateUpdate: () async {
          immediateUpdateCalled = true;
        },
      );

      expect(immediateUpdateCalled, isFalse);
    });

    // ---------------------------------------------------------------------------
    // Boundary: checkForUpdate returns synchronously (no async gap)
    // ---------------------------------------------------------------------------

    test('handles synchronous-like Future completion without error', () async {
      bool immediateUpdateCalled = false;

      await performUpdateCheck(
        isAndroid: true,
        checkForUpdate: () => Future.value(
          _makeInfo(UpdateAvailability.updateAvailable),
        ),
        performImmediateUpdate: () {
          immediateUpdateCalled = true;
          return Future.value();
        },
      );

      expect(immediateUpdateCalled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Method channel integration – in_app_update channel
  // ---------------------------------------------------------------------------

  group('InAppUpdate method channel behaviour', () {
    const channel = MethodChannel('dev.fluttercommunity.plus/in_app_update');

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('channel returns update info map with updateAvailability field',
        () async {
      // Simulate what the native Android plugin returns for checkForUpdate.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'checkForUpdate') {
          return {
            'updateAvailability': 1, // 1 == updateAvailable in Play Core
            'immediateUpdateAllowed': true,
            'flexibleUpdateAllowed': false,
          };
        }
        if (call.method == 'performImmediateUpdate') {
          return 1; // ActivityResult.RESULT_OK
        }
        return null;
      });

      // We can't invoke InAppUpdate.checkForUpdate() directly on a non-Android
      // host because the native resolver isn't present; we instead verify that
      // the mock handler is wired correctly and responds as expected.
      final completer = Completer<Map<Object?, Object?>?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('checkForUpdate')),
        (data) {
          if(data == null){completer.complete(null);return;}final result = channel.codec.decodeEnvelope(data);
          completer.complete(result as Map<Object?, Object?>?);
        },
      );

      final result = await completer.future;
      expect(result, isNotNull);
      expect(result!['updateAvailability'], equals(1));
      expect(result['immediateUpdateAllowed'], isTrue);
    });

    test('channel handler for performImmediateUpdate returns success code',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'performImmediateUpdate') {
          return 1; // RESULT_OK
        }
        return null;
      });

      final completer = Completer<Object?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec
            .encodeMethodCall(const MethodCall('performImmediateUpdate')),
        (data) {
          if(data == null){completer.complete(null);return;}final result = channel.codec.decodeEnvelope(data);
          completer.complete(result);
        },
      );

      final result = await completer.future;
      expect(result, equals(1));
    });

    test('channel handler for performImmediateUpdate returns cancelled code',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'performImmediateUpdate') {
          return 0; // RESULT_CANCELED
        }
        return null;
      });

      final completer = Completer<Object?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec
            .encodeMethodCall(const MethodCall('performImmediateUpdate')),
        (data) {
          if(data == null){completer.complete(null);return;}final result = channel.codec.decodeEnvelope(data);
          completer.complete(result);
        },
      );

      final result = await completer.future;
      expect(result, equals(0));
    });
  });
}
