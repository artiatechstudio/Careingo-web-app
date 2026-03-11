
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/offline_screen/chess/chess_screen.dart';
import 'package:myapp/offline_screen/date_calculator/date_calculator_screen.dart';
import 'package:myapp/offline_screen/game_2048/game_2048_screen.dart';
import 'package:myapp/offline_screen/notepad/notepad_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> _showDonationDialog(BuildContext context) async {
    final amountController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Support Artiatech Studio'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter the donation amount in LYD:'),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Amount"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Donate'),
              onPressed: () {
                final String amount = amountController.text;
                if (amount.isNotEmpty) {
                  final String ussdCode = '*120*0922813618*$amount*1#';
                  _launchUrl(context, 'tel:$ussdCode');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if this screen can be popped (i.e., it was pushed by another screen)
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features & More'),
        // Only show the back button if the screen can be popped
        automaticallyImplyLeading: canPop,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!canPop) // Show this text only when it's the main screen (offline)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'You are offline. Enjoy these features while you wait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.note_alt_outlined),
                  label: const Text('Daily Notepad'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotepadScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.games),
                  label: const Text('2048 Game'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Game2048Screen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.gamepad),
                  label: const Text('Chess'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChessScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Date Calculator'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DateCalculatorScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Connect with us',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(context, 'https://wa.me/218929196425', FontAwesomeIcons.whatsapp, Colors.green),
                    const SizedBox(width: 15),
                    _buildSocialButton(context, 'https://www.instagram.com/artiatechstudio', FontAwesomeIcons.instagram, Colors.purple),
                    const SizedBox(width: 15),
                    _buildSocialButton(context, 'https://www.youtube.com/@artiatechstudio', FontAwesomeIcons.youtube, Colors.red),
                    const SizedBox(width: 15),
                    _buildSocialButton(context, 'https://twitter.com/artiatechstudio', FontAwesomeIcons.twitter, Colors.blue),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('Financial Support'),
                  onPressed: () => _showDonationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // background color
                    foregroundColor: Colors.black, // foreground color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String url, IconData icon, Color color) {
    return InkWell(
      onTap: () => _launchUrl(context, url),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: FaIcon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
