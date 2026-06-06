import 'package:chumley_navigator/screens/login/cubit/login_cubit.dart';
import 'package:chumley_navigator/screens/login/cubit/login_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../utils/routes.dart';

// ─── Design-frame constants (Figma frame: 390 × 844) ───────────────
const double _kScreenH = 844.0;
const double _kVideoTopPct = 237.0 / _kScreenH; // 28.08 %
const double _kWordmarkBottomPct = (_kScreenH - 780.0) / _kScreenH; // 7.58 %
const double _kWordmarkFontSize = 25.583;
const _kOutroDuration = Duration(milliseconds: 700);
const _kVideoFadeDuration = Duration(milliseconds: 500);
const _kRootFadeDuration = Duration(milliseconds: 400);
const _kOutroEasing = Cubic(0.4, 0.0, 0.2, 1.0);
// ───────────────────────────────────────────────────────────────────

enum _Phase { play, outro, exit }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── video ────────────────────────────────────────────────────────
  late final VideoPlayerController _videoCtrl;

  // ── root fade-out ────────────────────────────────────────────────
  late final AnimationController _rootFadeCtrl;
  late final Animation<double> _rootFadeAnim;

  // ── video outro  (opacity 1→0, scale 1→1.08) ────────────────────
  late final AnimationController _videoOutroCtrl;
  late final Animation<double> _videoOpacityAnim;
  late final Animation<double> _videoScaleAnim;

  // ── wordmark outro  (translateY 0→−38 vh, scale 1→1.55) ─────────
  late final AnimationController _wordmarkCtrl;
  late final Animation<double> _wordmarkTranslateAnim;
  late final Animation<double> _wordmarkScaleAnim;

  _Phase _phase = _Phase.play;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initVideo();
  }

  // ── init helpers ─────────────────────────────────────────────────

  void _initAnimations() {
    // root fade
    _rootFadeCtrl = AnimationController(
      vsync: this,
      duration: _kRootFadeDuration,
    );
    _rootFadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _rootFadeCtrl, curve: Curves.easeInOut));

    // video outro
    _videoOutroCtrl = AnimationController(
      vsync: this,
      duration: _kVideoFadeDuration,
    );
    _videoOpacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _videoOutroCtrl, curve: _kOutroEasing));
    _videoScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _videoOutroCtrl, curve: _kOutroEasing));

    // wordmark outro
    _wordmarkCtrl = AnimationController(vsync: this, duration: _kOutroDuration);
    _wordmarkTranslateAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _wordmarkCtrl, curve: _kOutroEasing));
    _wordmarkScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.55,
    ).animate(CurvedAnimation(parent: _wordmarkCtrl, curve: _kOutroEasing));

    // when wordmark finishes rising → start root exit
    _wordmarkCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && _phase == _Phase.outro) {
        _startExit();
      }
    });
  }

  void _initVideo() {
    _videoCtrl =
        VideoPlayerController.asset(
            'assets/videos/navigator-splash.mp4',
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) async {
            if (!mounted) return;

            setState(() {});

            await _videoCtrl.setVolume(0.0);

            await _videoCtrl.setLooping(false);
            await _videoCtrl.play();

            _videoCtrl.addListener(_onVideoTick);
          });
    // _videoCtrl = VideoPlayerController.asset(
    //   'assets/videos/navigator-splash.mp4',
    // )..initialize().then((_) {
    //   if (!mounted) return;
    //   setState(() {});
    //   _videoCtrl
    //     ..setLooping(false)
    //     ..setVolume(0.0)
    //     ..play()
    //     ..addListener(_onVideoTick);
    // });
  }

  // ── video listener ────────────────────────────────────────────────

  void _onVideoTick() {
    if (!_videoCtrl.value.isInitialized) return;
    final pos = _videoCtrl.value.position;
    final dur = _videoCtrl.value.duration;
    if (dur > Duration.zero && pos >= dur && _phase == _Phase.play) {
      _videoCtrl.removeListener(_onVideoTick);
      _startOutro();
    }
  }

  // ── phase transitions ─────────────────────────────────────────────

  void _startOutro() {
    if (!mounted) return;
    setState(() => _phase = _Phase.outro);
    _videoOutroCtrl.forward();
    _wordmarkCtrl.forward();
  }

  Future<void> _startExit() async {
    if (!mounted) return;
    setState(() => _phase = _Phase.exit);
    await _rootFadeCtrl.forward();
    if (mounted) {
      final loginCubit = context.read<LoginCubit>();
      await loginCubit.checkAuthStatus();
      if (!mounted) return;

      final route = loginCubit.state is LoginAuthenticated
          ? AppRoutes.home
          : AppRoutes.login;

      Navigator.pushReplacementNamed(context, route);
    }
  }

  // ── dispose ───────────────────────────────────────────────────────

  @override
  void dispose() {
    _videoCtrl
      ..removeListener(_onVideoTick)
      ..dispose();
    _rootFadeCtrl.dispose();
    _videoOutroCtrl.dispose();
    _wordmarkCtrl.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return FadeTransition(
      opacity: _rootFadeAnim,
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: Stack(children: [_buildVideo(screenH), _buildWordmark(screenH)]),
      ),
    );
  }

  // ── video layer ───────────────────────────────────────────────────

  Widget _buildVideo(double screenH) {
    return Positioned(
      top: screenH * _kVideoTopPct,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _videoOutroCtrl,
        builder: (context, child) => Opacity(
          opacity: _videoOpacityAnim.value,
          child: Transform.scale(scale: _videoScaleAnim.value, child: child),
        ),
        child: _videoCtrl.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoCtrl.value.aspectRatio,
                child: VideoPlayer(_videoCtrl),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ── wordmark layer ────────────────────────────────────────────────

  Widget _buildWordmark(double screenH) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedBuilder(
      animation: _wordmarkCtrl,
      builder: (context, child) {
        final translateY = -screenH * 0.38 * _wordmarkTranslateAnim.value;

        return Positioned(
          left: 0,
          right: 0,
          bottom: screenH * _kWordmarkBottomPct + bottomInset,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: _wordmarkScaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: _kWordmarkFontSize,
              letterSpacing: _kWordmarkFontSize * -0.02,
              height: 1.0,
            ),
            children: [
              // "chumley" — dark purple
              const TextSpan(
                text: 'chumley',
                style: TextStyle(color: AppColors.primaryTextPurple),
              ),
              // "navigator" — red → orange gradient
              WidgetSpan(
                baseline: TextBaseline.alphabetic,
                alignment: PlaceholderAlignment.baseline,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.gradientPromoStart,
                      AppColors.gradientPromoEnd,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'navigator',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: _kWordmarkFontSize,
                      letterSpacing: _kWordmarkFontSize * -0.02,
                      height: 1.0,
                      color: Colors.white,
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
