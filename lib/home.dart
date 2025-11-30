import 'dart:math';
import 'dart:ui';
import 'package:brainjourney/temporallobe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
// ------------------------------------------------------
// BRAIN MAP (Level-Auswahl als Gehirn-Karte)
// ------------------------------------------------------
class BrainMapScreen extends StatefulWidget {
  const BrainMapScreen({super.key});

  @override
  State<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends State<BrainMapScreen> {
  // simple storage of completed levels
  final Set<String> _completed = {};
  late SharedPreferences _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs.getStringList('completedLevels') ?? [];
    setState(() {
      _completed.addAll(list);
      _loading = false;
    });
  }

  Future<void> _markCompleted(String id) async {
    setState(() {
      _completed.add(id);
    });
    await _prefs.setStringList('completedLevels', _completed.toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gehirn-Karte'),
        backgroundColor: Color(0xFF200D0B),
        foregroundColor: Colors.white,

      ),
      backgroundColor: Color(0xFFF8F2F8),
      body: Center(
        child: SizedBox(
          width: 380,
          height: 600,
          child: Stack(
            children: [
              // background "brain" silhouette (simple circle/oval)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 360,
                    height: 560,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(180),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
                    ),
                  ),
                ),
              ),

              // Amygdala (bottom-left)
              _brainIcon(
                left: 60,
                top: 360,
                label: 'Amygdala',
                id: 'amygdala',
                completed: _completed.contains('amygdala'),
                onTap: () {
                  // TODO: replace with real Amygdala page later
                  _openPlaceholder(context, 'Amygdala', 'amygdala');
                },
              ),

              // Hippocampus (center-left)
              _brainIcon(
                left: 90,
                top: 250,
                label: 'Hippocampus',
                id: 'hippocampus',
                completed: _completed.contains('hippocampus'),
                onTap: () {
                  _openPlaceholder(context, 'Hippocampus', 'hippocampus');
                },
              ),

              // Präfrontaler Cortex (top-center)
              _brainIcon(
                left: 150,
                top: 80,
                label: 'PFC',
                id: 'pfc',
                completed: _completed.contains('pfc'),
                onTap: () {
                  _openPlaceholder(context, 'Präfrontaler Cortex', 'pfc');
                },
              ),

              // Temporallappen (center-right) - our implemented level
              Positioned(
                left: 230,
                top: 230,
                child: GestureDetector(
                  onTap: () async {
                    // push the whole flow as one route and await a boolean result (true => completed)
                    final completed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const TemporalLobeFlow()),
                    );
                    if (completed == true) {
                      _markCompleted('temporal');
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: _completed.contains('temporal') ? Colors.green : Colors.deepPurple,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                        ),
                        child: const Icon(Icons.bubble_chart, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 86,
                        child: Text(
                          'Temporallappen',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Cerebellum (bottom-right)
              _brainIcon(
                left: 240,
                top: 380,
                label: 'Kleinhirn',
                id: 'cerebellum',
                completed: _completed.contains('cerebellum'),
                onTap: () {
                  _openPlaceholder(context, 'Kleinhirn', 'cerebellum');
                },
              ),

              // small legend

            ],
          ),
        ),
      ),
    );
  }

  Widget _brainIcon({
    required double left,
    required double top,
    required String label,
    required String id,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: completed ? Colors.pinkAccent : Color(0xFF200D0B),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
              ),
              child: Icon(
                Icons.bubble_chart,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 86,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openPlaceholder(BuildContext ctx, String title, String id) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title), backgroundColor: Colors.deepPurple),
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$title - noch nicht implementiert', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // mark as completed for testing if desired
                  _markCompleted(id);
                  Navigator.pop(ctx);
                },
                child: const Text('Als abgeschlossen markieren'),
              )
            ]),
          ),
        ),
      ),
    );
  }
}