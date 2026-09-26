import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/store_links.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/services/update/app_version.dart';
import 'package:mishkat/services/update/release_notes.dart';
import 'package:mishkat/services/update/update_config.dart';
import 'package:mishkat/services/update/update_policy.dart';

AppVersion v(String s) => AppVersion.parse(s);

UpdateConfig config({
  String recommended = '0.0.0',
  String min = '0.0.0',
  String notes = '',
  bool allowReading = true,
}) => UpdateConfig.fromValues(
  recommended: recommended,
  minSupported: min,
  releaseNotes: notes,
  allowReading: allowReading,
);

const notes130 =
    '{"version":"1.3.0","notes":[{"icon":"bell","ar":"تذكيرات أدق","en":"Sharper reminders"},'
    '{"icon":"sparkle","ar":"أيقونة لا يعرفها هذا الإصدار","en":"An icon this build lacks"}]}';

void main() {
  group('AppVersion', () {
    test('reads store, About and Remote Config forms alike', () {
      expect(v('1.3.0+34'), const AppVersion(1, 3, 0));
      expect(v('1.2.0 (34)'), const AppVersion(1, 2, 0));
      expect(v(' 1.3 '), const AppVersion(1, 3, 0));
      expect(v('v2.0.1'), const AppVersion(2, 0, 1));
    });

    test('compares numerically, not as text', () {
      expect(v('1.10.0') > v('1.9.9'), isTrue);
      expect(v('2.0.0') > v('1.99.99'), isTrue);
      expect(v('1.2.0').compareTo(v('1.2.0+99')), 0);
    });

    test('garbage is no version, never a crash', () {
      expect(AppVersion.tryParse('latest'), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse(null), isNull);
    });

    test('Arabic uses Arabic-Indic digits and the decimal separator', () {
      expect(v('1.3.0').display('ar'), '١٫٣٫٠');
      expect(v('1.3.0').display('en'), '1.3.0');
    });
  });

  group('resolveUpdate', () {
    test('nothing published: no update', () {
      expect(
        resolveUpdate(installed: v('1.2.0'), config: config()),
        isA<NoUpdate>(),
      );
    });

    test('below recommended: optional, with notes only for that version', () {
      final d = resolveUpdate(
        installed: v('1.2.0'),
        config: config(recommended: '1.3.0', notes: notes130),
      );
      expect(d, isA<OptionalUpdate>());
      d as OptionalUpdate;
      expect(d.target, v('1.3.0'));
      expect(d.notes!.notes, hasLength(2));
      expect(d.notes!.notes.last.icon, MIcon.info);

      final stale = resolveUpdate(
        installed: v('1.2.0'),
        config: config(recommended: '1.4.0', notes: notes130),
      );
      expect((stale as OptionalUpdate).notes, isNull);
    });

    test('below the minimum: required, aiming at the newest version', () {
      final d = resolveUpdate(
        installed: v('1.2.0'),
        config: config(recommended: '1.4.0', min: '1.3.0', allowReading: false),
      );
      expect(d, isA<RequiredUpdate>());
      d as RequiredUpdate;
      expect(d.installed, v('1.2.0'));
      expect(d.target, v('1.4.0'));
      expect(d.allowReading, isFalse);
    });

    test('required wins over optional; target is at least the minimum', () {
      final d = resolveUpdate(
        installed: v('1.0.0'),
        config: config(recommended: '1.1.0', min: '1.2.0'),
      );
      expect((d as RequiredUpdate).target, v('1.2.0'));
    });

    test('at or above both versions: no update', () {
      for (final installed in ['1.3.0', '1.4.2']) {
        expect(
          resolveUpdate(
            installed: v(installed),
            config: config(recommended: '1.3.0', min: '1.3.0'),
          ),
          isA<NoUpdate>(),
        );
      }
    });

    test('a mistyped value or an unknown installed version gates nothing', () {
      expect(
        resolveUpdate(
          installed: v('1.2.0'),
          config: config(recommended: 'soon', min: '1,3'),
        ),
        isA<NoUpdate>(),
      );
      expect(
        resolveUpdate(installed: null, config: config(min: '9.0.0')),
        isA<NoUpdate>(),
      );
    });
  });

  group('shouldPromptUpdate', () {
    final now = DateTime(2026, 9, 20, 9);

    test('a version never offered is offered', () {
      expect(
        shouldPromptUpdate(
          target: v('1.3.0'),
          lastPromptedVersion: null,
          lastPromptedAt: null,
          now: now,
        ),
        isTrue,
      );
      expect(
        shouldPromptUpdate(
          target: v('1.3.0'),
          lastPromptedVersion: v('1.2.5'),
          lastPromptedAt: now,
          now: now,
        ),
        isTrue,
      );
    });

    test('the same version waits three days', () {
      bool after(Duration d) => shouldPromptUpdate(
        target: v('1.3.0'),
        lastPromptedVersion: v('1.3.0'),
        lastPromptedAt: now.subtract(d),
        now: now,
      );
      expect(after(const Duration(days: 2, hours: 23)), isFalse);
      expect(after(const Duration(days: 3)), isTrue);
    });

    test('never when a reminder opened the app', () {
      expect(
        shouldPromptUpdate(
          target: v('1.3.0'),
          lastPromptedVersion: null,
          lastPromptedAt: null,
          now: now,
          launchedFromReminder: true,
        ),
        isFalse,
      );
    });
  });

  group('whatsNewAfterUpdate', () {
    Release r(String version) => Release(
      version: v(version),
      notes: const [ReleaseNote(icon: MIcon.bell, ar: 'أ', en: 'a')],
    );
    final changelog = Changelog([r('1.3.0'), r('1.2.1'), r('1.2.0')]);

    test('a first install is not an update', () {
      expect(
        whatsNewAfterUpdate(
          lastSeen: null,
          installed: v('1.3.0'),
          changelog: changelog,
        ),
        isNull,
      );
    });

    test('every release since the last one seen, newest first', () {
      final releases = whatsNewAfterUpdate(
        lastSeen: v('1.2.0'),
        installed: v('1.3.0'),
        changelog: changelog,
      );
      expect(releases!.map((r) => r.version.toString()), ['1.3.0', '1.2.1']);
    });

    test('same version, a downgrade, or no notes: nothing to say', () {
      expect(
        whatsNewAfterUpdate(
          lastSeen: v('1.3.0'),
          installed: v('1.3.0'),
          changelog: changelog,
        ),
        isNull,
      );
      expect(
        whatsNewAfterUpdate(
          lastSeen: v('1.4.0'),
          installed: v('1.3.0'),
          changelog: changelog,
        ),
        isNull,
      );
      expect(
        whatsNewAfterUpdate(
          lastSeen: v('1.3.0'),
          installed: v('1.3.1'),
          changelog: changelog,
        ),
        isNull,
      );
    });
  });

  test('the store page follows the platform', () {
    expect(
      storePageUri(TargetPlatform.android).queryParameters['id'],
      kPlayPackage,
    );
    expect(
      storePageUri(TargetPlatform.iOS),
      kStoreLinksReady
          ? Uri.parse('https://apps.apple.com/app/id$kAppStoreId')
          : Uri.parse('https://mishkatalwird.com/'),
    );
  });
}
