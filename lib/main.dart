import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: DigitalPetApp()));

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "NAME";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;
  TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;

  @override
  void initState() {
    super.initState();
    // Auto-hunger timer: increases every 30 seconds
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel == 100 && happinessLevel <= 10) _showGameOver();
      });
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // --- Logic Helpers ---
  Color _getMoodColor() {
    if (happinessLevel > 70) return Colors.greenAccent;
    if (happinessLevel >= 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getMoodEmoji() {
    if (happinessLevel > 70) return "😊 Happy";
    if (happinessLevel >= 30) return "😐 Neutral";
    return "😢 Sad";
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 15).clamp(0, 100);
      happinessLevel = (happinessLevel + 5).clamp(0, 100);
    });
  }

  void _playWithPet() {
    setState(() {
      energyLevel = (energyLevel - 20).clamp(0, 100);
      happinessLevel = (happinessLevel + 15).clamp(0, 100);
      hungerLevel = (hungerLevel + 10).clamp(0, 100);
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("$petName needs more care! Try again?"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Restart"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Digital Pet", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Name Input Section ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: "Enter pet's name and press the blue button", border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.blueAccent),
                      onPressed: () => setState(() => petName = _nameController.text),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // --- The Pet Display ---
            // Requirement: Border changes color, not the image itself
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getMoodColor(), width: 8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/pet_image.png'),
              ),
            ),
            SizedBox(height: 20),
            Text(_getMoodEmoji(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(petName, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            
            SizedBox(height: 30),

            // --- Stats Section ---
            _buildStatBar("Happiness", happinessLevel / 100, Colors.pinkAccent),
            _buildStatBar("Hunger", hungerLevel / 100, Colors.orange),
            _buildStatBar("Energy", energyLevel / 100, Colors.blueAccent),

            SizedBox(height: 40),

            // --- Actions Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.restaurant, "Feed", _feedPet, Colors.green),
                _buildActionButton(Icons.sports_esports, "Play", _playWithPet, Colors.purple),
                _buildActionButton(Icons.bedtime, "Sleep", () {
                  setState(() => energyLevel = (energyLevel + 40).clamp(0, 100));
                }, Colors.blueGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Component Builders ---

  Widget _buildStatBar(String label, double value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}