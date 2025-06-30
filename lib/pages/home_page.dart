import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'result_page.dart';
import '../ai_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _showTextField = false;
  late AnimationController _glowController;
  final TextEditingController _textController = TextEditingController();

  final AIService ai = AIService(
    endpoint: 'https://api.openai.com/v1/chat/completions', // or your own proxy
    apiKey: 'test key', // store securely in real apps!
  );

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
    _textController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() => _isPressed = true);
    _glowController.repeat(reverse: true);
    HapticFeedback.lightImpact(); // subtle haptic feedback
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

  Widget _buildMicButton() {
    return GestureDetector(
      onLongPressStart: (_) => _onPressStart(),
      onLongPressEnd: (_) => _onPressEnd(),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: _isPressed ? 0.7 : 1.0,
        child: AnimatedScale(
          duration: Duration(milliseconds: 200),
          scale: _isPressed ? 0.9 : 1.0,
          curve: Curves.easeOut,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isPressed)
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (_, __) {
                    final glow = Tween(begin: 0.0, end: 60.0).animate(_glowController);
                    final opacity = Tween(begin: 0.5, end: 0.0).animate(_glowController);
                    return Container(
                      width: 200 + glow.value,
                      height: 200 + glow.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple.withOpacity(opacity.value),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(opacity.value),
                            blurRadius: glow.value,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<DecidyState>();

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSlide(
                  duration: Duration(milliseconds: 300),
                  offset: _showTextField ? Offset(0, -0.2) : Offset(0, 0),
                  child: _buildMicButton(),
                ),
                SizedBox(height: 20),
                IconButton(
                  icon: Icon(Icons.keyboard_alt),
                  onPressed: () {
                    setState(() {
                      _showTextField = !_showTextField;
                    });
                  },
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showTextField
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: '输入你的问题...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  appState.spokenText = value;
                                  appState.decisionResult = '这是你手动输入的：$value';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ResultPage()),
                                  );
                                },
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  final value = _textController.text.trim();
                                  if (value.isNotEmpty) {
                                    appState.spokenText = value;

                                    final response = await ai.getDecision(value);

                                    appState.decisionResult = response;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ResultPage()),
                                    );
                                  }
                                },
                                child: Text('提交'),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
