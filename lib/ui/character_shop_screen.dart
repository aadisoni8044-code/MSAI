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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xCC0F172A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'LOBBY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
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
                            'CHARACTER SHOP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),

                        // Coin Balance Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCC0F172A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: GameColors.coinGold, width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0x44FFD166), blurRadius: 10, spreadRadius: 1),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                '${charCtrl.totalCoins}',
                                style: const TextStyle(
                                  color: GameColors.coinGold,
                                  fontSize: 16,
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
                  top: 70,
                  left: screenSize.width * 0.25,
                  right: screenSize.width * 0.25,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isSuccessMessage ? const Color(0xEE065F46) : const Color(0xEE991B1B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccessMessage ? const Color(0xFF34D399) : const Color(0xFFF87171),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isSuccessMessage ? const Color(0x6634D399) : const Color(0x66F87171),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(
                        _messageText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Main Content (Left: Character Grid, Right: Large Detail Preview)
              Positioned(
                top: 72,
                left: 20,
                right: 20,
                bottom: 16,
                child: Row(
                  children: [
                    // LEFT: Character Grid
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x880F172A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GameColors.uiGlassBorder, width: 1.2),
                        ),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
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

                    const SizedBox(width: 16),

                    // RIGHT: Large Character Preview & Purchase Section
                    Expanded(
                      flex: 4,
                      child: _buildLargePreviewSection(
                        char: _previewCharacter,
                        isOwned: isOwned,
                        isSelected: isSelected,
                        charCtrl: charCtrl,
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: active || isSelectedCard ? 2.5 : 1.2,
          ),
          boxShadow: active
              ? const [BoxShadow(color: Color(0x664ADE80), blurRadius: 10, spreadRadius: 1)]
              : isSelectedCard
                  ? const [BoxShadow(color: Color(0x6638BDF8), blurRadius: 8)]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Character Mini Render
            Expanded(
              child: CharacterPreviewWidget(
                character: char,
                width: 60,
                height: 60,
                time: _time,
              ),
            ),

            // Name
            Text(
              char.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),

            // Status or Price Badge
            if (active)
              const Text(
                'SELECTED',
                style: TextStyle(
                  color: GameColors.foliageGlow,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (unlocked)
              const Text(
                'OWNED',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: GameColors.coinGold, size: 10),
                  const SizedBox(width: 2),
                  Text(
                    '${char.price}',
                    style: const TextStyle(
                      color: GameColors.coinGold,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: char.eyeGlowColor.withValues(alpha: 0.6), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: char.eyeGlowColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      char.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Animated Large Preview
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: char.eyeGlowColor.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(color: char.eyeGlowColor, blurRadius: 36, spreadRadius: 6),
                    ],
                  ),
                ),
                CharacterPreviewWidget(
                  character: char,
                  width: 130,
                  height: 130,
                  time: _time,
                ),
              ],
            ),
          ),

          // Description
          Text(
            char.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Action Button (BUY or SELECT or SELECTED)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0x334ADE80),
                      border: Border.all(color: GameColors.foliageGlow, width: 1.5),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: GameColors.foliageGlow, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '✓ SELECTED',
                            style: TextStyle(
                              color: GameColors.foliageGlow,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          charCtrl.selectCharacter(char.id);
                          _showMessage('${char.name} Selected!', success: true);
                        },
                        icon: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'SELECT CHARACTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final success = await charCtrl.purchaseCharacter(char);
                          if (success) {
                            _showMessage('✨ CHARACTER UNLOCKED: ${char.name}!', success: true);
                          } else {
                            final missing = char.price - charCtrl.totalCoins;
                            _showMessage('Not enough coins! Need $missing more 💰', success: false);
                          }
                        },
                        icon: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF422006), size: 20),
                        label: Text(
                          'BUY FOR ${char.price} COINS',
                          style: const TextStyle(
                            color: Color(0xFF422006),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
