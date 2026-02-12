import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importiere deine Navigationsleiste
import 'package:brainjourney/brain_bottom_navigation.dart';

class Collection extends StatefulWidget {
  final bool fromPage;

  const Collection({super.key, required this.fromPage});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final Set<String> _completed = {};
  bool _loading = true;

  // Index für das Sammelbuch in der Bottom Bar (laut deiner Logik meistens 3)
  final int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedLevels') ?? [];
    if (mounted) {
      setState(() {
        _completed.addAll(list);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      // Wir nutzen Stack, um die Bottom Bar über den Hintergrund zu legen
      body: Stack(
        children: [
          // 1. Hintergrund
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),

          // 2. Das Buch (PageView)
          // Padding unten hinzufügen, damit das Buch nicht hinter der Bar verschwindet
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: PageView(
              controller: _pageController,
              children: [
                _buildCover(),
                _buildPage(
                  title: "Brain regions",
                  subtitle: "Explore the trails",
                  badges: [
                    _badgeItem("pfc", "assets/images/pfcBadge.png", "Reason"),
                    _badgeItem("amygdala", "assets/images/amygdalaBadge.png", "Emotions"),
                    _badgeItem("temporal", "assets/images/temporalBadge.png", "Language"),
                    _badgeItem("kleinhirn", "assets/images/cerebellumBadge.png", "Movement"),
                    _badgeItem("hippocampus", "assets/images/hippocampusBadge.png", "Memories"),
                  ],
                ),
                _buildPage(
                  title: "Mental Health",
                  subtitle: "Understand the woods",
                  badges: [
                    _badgeItem("anxiety", "assets/images/anxietyBadge.png", "Courage"),
                    _badgeItem("adhs", "assets/images/adhdBadge.png", "Focus"),
                    _badgeItem("depression", "assets/images/depressionBadge.png", "Hope"),
                    _badgeItem("addiction", "assets/images/addictionBadge.png", "Freedom"),
                    _badgeItem("trauma", "assets/images/traumaBadge.png", "Healing"),
                  ],
                ),
              ],
            ),
          ),

          // 3. Die Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BrainNavigationBar(
              currentIndex: _currentIndex, mental: widget.fromPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeItem(String id, String imagePath, String label) {
    final bool isUnlocked = _completed.contains(id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
          colorFilter: isUnlocked
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.4,
            child: Image.asset(imagePath, height: 50, errorBuilder: (c, o, s) => const Icon(Icons.lock, size: 40)),
          ),
        ),
        const SizedBox(height: 5),
        Text(isUnlocked ? label : "???", style: TextStyle(fontSize: 10, fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal, color: Colors.brown[900])),
      ],
    );
  }

  Widget _buildCover() {
    return _bookFrame(
      child: SizedBox(
        width: double.infinity, // Zwingt die Column auf die volle Breite
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "My\nCollection",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset("assets/images/brainMain.png", height: 100),
            const SizedBox(height: 50),
            const Text(
              "Swipe to turn the page",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.brown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required List<Widget> badges}) {
    return _bookFrame(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          Text(subtitle, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.brown)),
          const Divider(color: Colors.brown, height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              children: badges,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookFrame({required Widget child}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40), child: child),
          ],
        ),
      ),
    );
  }
}