import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_forest_adventure/core/zombie_audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZombieAudioController Spatial Tests', () {
    test('Audio controller initializes and responds to audio status flags', () {
      final audioCtrl = ZombieAudioController.instance;
      audioCtrl.init();
      expect(audioCtrl.isZombieAudioActive, isFalse);

      audioCtrl.startZombieModeAudio();
      expect(audioCtrl.isZombieAudioActive, isTrue);

      audioCtrl.stopAllZombieAudio();
      expect(audioCtrl.isZombieAudioActive, isFalse);
    });

    test('Spatial audio triggers execute cleanly at varied distances', () {
      final audioCtrl = ZombieAudioController.instance;
      audioCtrl.startZombieModeAudio();

      expect(() => audioCtrl.playSpatialGrowl(distance: 150), returnsNormally);
      expect(() => audioCtrl.playSpatialGrowl(distance: 800, isLarge: true), returnsNormally);
      expect(() => audioCtrl.playZombieFootstep(distance: 200, isLarge: false), returnsNormally);
      expect(() => audioCtrl.playZombieFootstep(distance: 400, isLarge: true), returnsNormally);
      expect(() => audioCtrl.playZombieScream(distance: 300), returnsNormally);
      expect(() => audioCtrl.playChaseAmbience(5, minDistance: 250), returnsNormally);
      expect(() => audioCtrl.playZombieAttack(distance: 100), returnsNormally);
      expect(() => audioCtrl.playPlayerAttack(isHeavy: true), returnsNormally);
      expect(() => audioCtrl.playHitImpact(isHeavy: true), returnsNormally);
      expect(() => audioCtrl.playZombieDeath(distance: 200), returnsNormally);
      expect(() => audioCtrl.playWaveWarning(), returnsNormally);
      expect(() => audioCtrl.playCountdownBeep(3), returnsNormally);
      expect(() => audioCtrl.playTowerStep(), returnsNormally);
      expect(() => audioCtrl.updateHordeIntensity(nearbyZombieCount: 10, isPlayerOnTower: true), returnsNormally);

      audioCtrl.stopAllZombieAudio();
    });
  });
}
