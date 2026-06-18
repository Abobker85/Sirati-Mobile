import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  static const _pages = [
    _Page(
      icon: Icons.description_outlined,
      title: 'سيرتي',
      body:
          'حلل سيرتك الذاتية واحصل على درجة ATS، أو أنشئ سيرة ذاتية احترافية بالذكاء الاصطناعي',
      colors: [Color(0xFF185FA5), Color(0xFF0C447C)],
    ),
    _Page(
      icon: Icons.bar_chart_rounded,
      title: 'تحليل ATS فوري',
      body:
          'احصل على درجة تفصيلية، الكلمات المفتاحية الناقصة، ونقاط القوة والضعف في ثوانٍ',
      colors: [Color(0xFF0F6E56), Color(0xFF085041)],
    ),
    _Page(
      icon: Icons.auto_awesome,
      title: 'توليد CV بالذكاء',
      body:
          'أدخل بياناتك وسيُنشئ الذكاء الاصطناعي سيرة ذاتية احترافية قابلة للتنزيل بصيغة PDF',
      colors: [Color(0xFF533AB7), Color(0xFF3C3489)],
    ),
  ];

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _PageView(page: _pages[i]),
          ),
          // Skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              child: TextButton(
                onPressed: _goToLogin,
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('تخطي', style: TextStyle(fontSize: 14)),
              ),
            ),
          // Bottom controls
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToLogin();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _pages[_currentPage].colors[0],
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  child: Text(_currentPage == _pages.length - 1
                      ? 'ابدأ الآن'
                      : 'التالي'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> colors;

  const _Page(
      {required this.icon,
      required this.title,
      required this.body,
      required this.colors});
}

class _PageView extends StatelessWidget {
  final _Page page;

  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: page.colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(24)),
                child: Icon(page.icon, size: 46, color: Colors.white),
              ),
              const SizedBox(height: 36),
              Text(
                page.title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2),
              ),
              const SizedBox(height: 14),
              Text(
                page.body,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 16, color: Colors.white70, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
