import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() => _isPressed = true);
    _glowController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
    print('🎤 开始录音');
    context.read<DecidyState>().startRecording();
  }

  void _onPressEnd() async {
    setState(() => _isPressed = false);
    _glowController.stop();
    
    final appState = context.read<DecidyState>();
    await appState.stopRecording();
    await appState.playRecording();
    print('🛑 停止录音');    

    appState.setSpokenText('模拟语音识别文本');

    Future.delayed(Duration(milliseconds: 500), () {
      context.read<DecidyState>().decisionResult =
          '当然要！我听懂你说了：${context.read<DecidyState>().spokenText}';

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => ResultPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) => _onPressStart(),
          onLongPressEnd: (_) => _onPressEnd(),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            opacity: _isPressed ? 0.7 : 1.0,
            child: AnimatedScale(
              duration: Duration(milliseconds: 100),
              scale: _isPressed ? 0.9 : 1.0,
              curve: Curves.easeOut,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing ripple
                  if (_isPressed)
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (_, __) {
                        final glow = Tween(
                          begin: 0.0,
                          end: 60.0,
                        ).animate(_glowController);
                        final opacity = Tween(
                          begin: 0.5,
                          end: 0.0,
                        ).animate(_glowController);
                        return Container(
                          width: 200 + glow.value,
                          height: 200 + glow.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.withOpacity(opacity.value),
                          ),
                        );
                      },
                    ),

                  // Mic button
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.mic, size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
