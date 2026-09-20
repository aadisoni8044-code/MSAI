import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/core/zombie_audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZombieAudioController Tests', () {
    test('Audio controller initializes and responds to audio status flags', () {
      final audioCtrl = ZombieAudioController.instance;
      audioCtrl.init();
      expect(audioCtrl.isZombieAudioActive, isFalse);

      audioCtrl.startZombieModeAudio();
      expect(audioCtrl.isZombieAudioActive, isTrue);

      audioCtrl.stopAllZombieAudio();
      expect(audioCtrl.isZombieAudioActive, isFalse);
    });

    test('Audio trigger calls execute cleanly without error when sound enabled or disabled', () {
      final audioCtrl = ZombieAudioController.instance;
      audioCtrl.startZombieModeAudio();

      expect(() => audioCtrl.playZombieGrowl(), returnsNormally);
      expect(() => audioCtrl.playZombieScream(), returnsNormally);
      expect(() => audioCtrl.playChaseAmbience(5), returnsNormally);
      expect(() => audioCtrl.playZombieAttack(), returnsNormally);
      expect(() => audioCtrl.playPlayerAttack(), returnsNormally);
      expect(() => audioCtrl.playHitImpact(), returnsNormally);
      expect(() => audioCtrl.playZombieDeath(), returnsNormally);
      expect(() => audioCtrl.playWaveWarning(), returnsNormally);
      expect(() => audioCtrl.playCountdownBeep(3), returnsNormally);
      expect(() => audioCtrl.playTowerStep(), returnsNormally);

      audioCtrl.stopAllZombieAudio();
    });
  });
}
