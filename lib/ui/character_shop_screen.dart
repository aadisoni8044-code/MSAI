import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/character_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/widgets/character_preview_widget.dart';

class CharacterShopScreen extends StatefulWidget {
  const CharacterShopScreen({super.key});

  @override
  State<CharacterShopScreen> createState() => _CharacterShopScreenState();
}

class _CharacterShopScreenState extends State<CharacterShopScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  Duration _lastElapsed = Duration.zero;
  late CharacterData _previewCharacter;
  String? _messageText;
  bool _isSuccessMessage = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _previewCharacter = CharacterProgressController.instance.selectedCharacter;
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (mounted) {
      setState(() {
        _time += dt;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool success = true}) {
    setState(() {
      _messageText = text;
      _isSuccessMessage = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _messageText == text) {
        setState(() {
          _messageText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final charCtrl = CharacterProgressController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF040817),
      body: ListenableBuilder(
        listenable: charCtrl,
        builder: (context, _) {
          final isOwned = charCtrl.isUnlocked(_previewCharacter.id);
          final isSelected = charCtrl.isSelected(_previewCharacter.id);

          return Stack(
            children: [
              // 1. Dark Fantasy Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF070C1A),
                      Color(0xFF02040A),
                    ],
                  ),
                ),
              ),

              // 2. Top Header Bar
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xCC0F172A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: GameColors.uiGlassBorder, width: 1.2),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'LOBBY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF80FFDB), Color(0xFF38BDF8), Color(0xFFEAB308)],
                          ).createShader(bounds),
                          child: const Text(
                            'HEROES & LEGENDS (50)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        // Coin Balance Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0F172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: GameColors.coinGold, width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33FFD166), blurRadius: 8),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${charCtrl.totalCoins}',
                                style: const TextStyle(
                                  color: GameColors.coinGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Notification Message Toast
              if (_messageText != null)
                Positioned(
                  top: 54,
                  left: screenSize.width * 0.2,
                  right: screenSize.width * 0.2,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isSuccessMessage ? const Color(0xEE065F46) : const Color(0xEE991B1B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccessMessage ? const Color(0xFF34D399) : const Color(0xFFF87171),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        _messageText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Main Content (Left: 50-Character Grid, Right: Large Detail Preview)
              Positioned(
                top: 56,
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    // LEFT: Responsive 50-Character Grid
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x880F172A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: GameColors.uiGlassBorder, width: 1.2),
                        ),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 105.0,
                            mainAxisExtent: 88.0,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: CharacterData.allCharacters.length,
                          itemBuilder: (context, index) {
                            final char = CharacterData.allCharacters[index];
                            final charUnlocked = charCtrl.isUnlocked(char.id);
                            final charActive = charCtrl.isSelected(char.id);
                            final isCardSelected = _previewCharacter.id == char.id;

                            return _buildCharacterCard(
                              char: char,
                              unlocked: charUnlocked,
                              active: charActive,
                              isSelectedCard: isCardSelected,
                              onTap: () {
                                setState(() {
                                  _previewCharacter = char;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // RIGHT: Large Character Preview & Purchase Section
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildLargePreviewSection(
                          char: _previewCharacter,
                          isOwned: isOwned,
                          isSelected: isSelected,
                          charCtrl: charCtrl,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCharacterCard({
    required CharacterData char,
    required bool unlocked,
    required bool active,
    required bool isSelectedCard,
    required VoidCallback onTap,
  }) {
    Color borderColor = GameColors.uiGlassBorder;
    if (active) {
      borderColor = GameColors.foliageGlow;
    } else if (isSelectedCard) {
      borderColor = const Color(0xFF38BDF8);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelectedCard ? const Color(0xEE1E293B) : const Color(0xCC0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: active || isSelectedCard ? 2.0 : 1.0,
          ),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x444ADE80), blurRadius: 8)]
              : isSelectedCard
                  ? const [BoxShadow(color: Color(0x4438BDF8), blurRadius: 6)]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CharacterPreviewWidget(
                character: char,
                width: 38,
                height: 38,
                time: _time,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              char.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            if (active)
              const Text(
                'SELECTED',
                style: TextStyle(
                  color: GameColors.foliageGlow,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (unlocked)
              const Text(
                'OWNED',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 8.5),
                  const SizedBox(width: 2),
                  Text(
                    '${char.price}',
                    style: const TextStyle(
                      color: GameColors.coinGold,
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargePreviewSection({
    required CharacterData char,
    required bool isOwned,
    required bool isSelected,
    required CharacterProgressController charCtrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: char.eyeGlowColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: char.eyeGlowColor.withValues(alpha: 0.2),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            char.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            char.outfitTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: char.eyeGlowColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          // Animated Large Preview
          SizedBox(
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: char.eyeGlowColor.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(color: char.eyeGlowColor, blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                ),
                CharacterPreviewWidget(
                  character: char,
                  width: 95,
                  height: 95,
                  time: _time,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Text(
            char.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          // Action Button (BUY or SELECT or SELECTED)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0x334ADE80),
                      border: Border.all(color: GameColors.foliageGlow, width: 1.2),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: GameColors.foliageGlow, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '✓ SELECTED',
                            style: TextStyle(
                              color: GameColors.foliageGlow,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : isOwned
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          charCtrl.selectCharacter(char.id);
                          _showMessage('${char.name} Selected!', success: true);
                        },
                        icon: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 16),
                        label: const Text(
                          'SELECT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final success = await charCtrl.purchaseCharacter(char);
                          if (success) {
                            _showMessage('✨ UNLOCKED: ${char.name}!', success: true);
                          } else {
                            final missing = char.price - charCtrl.totalCoins;
                            _showMessage('Need $missing more 💰', success: false);
                          }
                        },
                        icon: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF422006), size: 16),
                        label: Text(
                          'BUY ${char.price} COINS',
                          style: const TextStyle(
                            color: Color(0xFF422006),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
