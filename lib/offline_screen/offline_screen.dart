
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careingo/offline_screen/chess/chess_screen.dart';
import 'package:careingo/offline_screen/date_calculator/date_calculator_screen.dart';
import 'package:careingo/offline_screen/game_2048/game_2048_screen.dart';
import 'package:careingo/offline_screen/notepad/notepad_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class OfflineScreen extends StatefulWidget {
  final bool isPremium;
  const OfflineScreen({super.key, this.isPremium = false});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isPremium) {
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (!context.mounted) return;
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
          title: const Text('دعم استوديو أرتياتك'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('الرجاء إدخال قيمة الدعم بالدرهم (الحد الأدنى 1000):'),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "القيمة بالدرهم"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('تبرع'),
              onPressed: () {
                final String amountText = amountController.text;
                if (amountText.isNotEmpty) {
                  final int? amount = int.tryParse(amountText);
                  if (amount != null && amount >= 1000) {
                    final String ussdCode = '*122*0922813618*$amount*1%23';
                    _launchUrl(context, 'tel:$ussdCode');
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الحد الأدنى للدعم هو 1000 درهم'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
        title: const Text('الميزات بدون إنترنت'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (!canPop)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'عذراً، أنت غير متصل بالإنترنت.. يمكنك الاستمتاع بهذه الميزات ريثما يعود الاتصال.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.note_alt_outlined),
                          label: const Text('المذكرة اليومية'),
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
                          label: const Text('لعبة 2048'),
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
                          label: const Text('الشطرنج'),
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
                          label: const Text('حاسبة التواريخ'),
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
                          'تواصل معنا',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(context, 'https://wa.me/218929196425', FontAwesomeIcons.whatsapp as IconData, Colors.green),
                            const SizedBox(width: 15),
                            _buildSocialButton(context, 'https://www.instagram.com/artiatechstudio', FontAwesomeIcons.instagram as IconData, Colors.purple),
                            const SizedBox(width: 15),
                            _buildSocialButton(context, 'https://www.youtube.com/@artiatechstudio', FontAwesomeIcons.youtube as IconData, Colors.red),
                            const SizedBox(width: 15),
                            _buildSocialButton(context, 'https://twitter.com/artiatechstudio', FontAwesomeIcons.x as IconData, Colors.black),
                            const SizedBox(width: 15),
                            _buildSocialButton(context, 'https://artiatechstudio.com.ly', FontAwesomeIcons.globe as IconData, Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          label: const Text('الدعم المالي'),
                          onPressed: () => _showDonationDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
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
            ),
            if (!widget.isPremium && _isAdLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
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
          icon as FaIconData?,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
