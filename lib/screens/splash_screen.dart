import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kBg         = Color(0xFF0F1729);
const _kBlue       = Color(0xFF2563EB);
const _kDarkBlue   = Color(0xFF1A4FA8);
const _kPurple     = Color(0xFF6C63FF);
const _kCyan       = Color(0xFF48B9F8);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Phase: 0=init, 1=bookOpen, 2=writeLines, 3=brandReveal, 4=exit
  int _phase = 0;

  // ── Controllers ──────────────────────────────────────────────────────────
  late final AnimationController _coverCtrl;   // book cover flip
  late final AnimationController _linesCtrl;   // lines write-on
  late final AnimationController _brandCtrl;   // brand fade+slide
  late final AnimationController _glowCtrl;    // ambient glow pulse
  late final AnimationController _loadCtrl;    // loading bar
  late final AnimationController _exitCtrl;    // exit fade+scale
  late final AnimationController _particleCtrl;// floating dots

  // ── Animations ───────────────────────────────────────────────────────────
  late final Animation<double> _coverFlip;
  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;
  late final Animation<double> _loadBar;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Book cover flip (rotateY simulation via scaleX)
    _coverCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _coverFlip = CurvedAnimation(
      parent: _coverCtrl,
      curve: Curves.easeInOutBack,
    );

    // Lines write-on
    _linesCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );

    // Brand reveal
    _brandCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _brandOpacity = CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOut);
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _brandCtrl, curve: Curves.easeOutBack));

    // Glow pulse
    _glowCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _glowOpacity = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);

    // Loading bar
    _loadCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    );
    _loadBar = CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOut);

    // Floating particles
    _particleCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat();

    // Exit
    _exitCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale = Tween<double>(begin: 1, end: 1.04)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  void _startSequence() async {
    // Phase 1 — book opens
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _phase = 1);
    _coverCtrl.forward();

    // Phase 2 — lines write
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _phase = 2);
    _linesCtrl.forward();

    // Phase 3 — brand reveals
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _phase = 3);
    _brandCtrl.forward();
    _glowCtrl.forward();
    _loadCtrl.forward();

    // Phase 4 — exit
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _phase = 4);
    await _exitCtrl.forward();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _coverCtrl.dispose();
    _linesCtrl.dispose();
    _brandCtrl.dispose();
    _glowCtrl.dispose();
    _loadCtrl.dispose();
    _exitCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_exitCtrl, _particleCtrl]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              backgroundColor: _kBg,
              body: Stack(
                children: [
                  _buildGlow(),
                  _buildParticles(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Ambient glow ──────────────────────────────────────────────────────────
  Widget _buildGlow() {
    return AnimatedBuilder(
      animation: _glowOpacity,
      builder: (_, __) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        left: MediaQuery.of(context).size.width * 0.5 - 200,
        child: Opacity(
          opacity: _glowOpacity.value * 0.6,
          child: Container(
            width: 400, height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x1F6C63FF), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Floating particles ────────────────────────────────────────────────────
  Widget _buildParticles() {
    if (_phase < 3) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    final colors = [_kPurple, _kCyan, _kPurple, _kCyan, _kPurple, _kCyan];
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        return Stack(
          children: List.generate(6, (i) {
            final t = (_particleCtrl.value + i / 6) % 1.0;
            final dy = sin(t * 2 * pi) * 10;
            return Positioned(
              left: size.width * (0.1 + i * 0.15),
              top: size.height * (0.15 + (i % 3) * 0.2) + dy,
              child: AnimatedOpacity(
                opacity: _phase >= 3 ? 0.5 : 0,
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────
  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBook(),
          const SizedBox(height: 36),
          _buildBrand(),
        ],
      ),
    );
  }

  // ── Book ──────────────────────────────────────────────────────────────────
  Widget _buildBook() {
    return SizedBox(
      width: 140, height: 180,
      child: Stack(
        children: [
          // Back cover / spine
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kDarkBlue, Color(0xFF0D3070)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x661A4FA8),
                    blurRadius: 40, offset: Offset(0, 16),
                  ),
                ],
              ),
            ),
          ),

          // Pages (white inside)
          Positioned(
            left: 4, right: 6, top: 4, bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: _buildPageLines(),
            ),
          ),

          // Front cover — animates open
          AnimatedBuilder(
            animation: _coverFlip,
            builder: (_, __) {
              // Simulate page flip: scale from 1→0 (first half) then hide
              final flip = _coverFlip.value;
              final scaleX = flip < 0.5 ? (1 - flip * 2) : 0.0;
              return Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()..scale(scaleX, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kBlue, _kDarkBlue],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart\nKhatabook',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Page lines (inside book) ──────────────────────────────────────────────
  Widget _buildPageLines() {
    final lineColors = [
      [const Color(0xFF6C63FF), const Color(0xFF8B83FF)],
      [const Color(0xFF1A4FA8), const Color(0xFF4878D4)],
      [const Color(0xFF48B9F8), const Color(0xFF7DD4FC)],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        return Row(
          children: [
            // Red margin
            Container(width: 1, height: 10, color: const Color(0xFFFFB3B3)),
            const SizedBox(width: 5),
            // Line
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF0),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: AnimatedBuilder(
                  animation: _linesCtrl,
                  builder: (_, __) {
                    final delay = i * 0.1;
                    final progress = (((_linesCtrl.value - delay) / (1 - delay))
                        .clamp(0.0, 1.0));
                    final width = (0.5 + (i * 0.07 % 0.45));
                    return _phase >= 2
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: width * progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: lineColors[i % 3],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Brand ─────────────────────────────────────────────────────────────────
  Widget _buildBrand() {
    return AnimatedBuilder(
      animation: _brandCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _brandOpacity,
        child: SlideTransition(
          position: _brandSlide,
          child: Column(
            children: [
              const Text(
                'Smart Khatabook',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TRACK · MANAGE · PROFIT',
                style: TextStyle(
                  color: _kPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              // Loading bar
              Container(
                width: 130, height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedBuilder(
                  animation: _loadBar,
                  builder: (_, __) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _loadBar.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPurple, _kCyan],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}