import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final String _appDownloadLink = "https://flexai.app/download";
  final String _activationCode = "8607f5ff-e9c6-494f-a711-a165108b64e5";
  bool _linkCopied = false;
  bool _codeCopied = false;

  void _copyToClipboard(String text, {bool isCode = false}) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      if (isCode) {
        _codeCopied = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _codeCopied = false);
        });
      } else {
        _linkCopied = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _linkCopied = false);
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCode ? "Activation code copied!" : "Link copied!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              const Text(
                'Share with Friends',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Invite friends to experience FlexAI!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // step indicator
              _buildStepCard(
                stepNumber: 1,
                title: "Share the App",
                description:
                    "Send the download link or download the app and share directly with your friend.",
                icon: Icons.share_rounded,
                iconColor: Colors.blue,
                color: Colors.grey,
                child: Column(
                  children: [
                    // download link card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _appDownloadLink,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(_appDownloadLink),
                            icon: Icon(
                              _linkCopied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              color: _linkCopied
                                  ? Colors.green
                                  : Colors.black54,
                              size: 20,
                            ),
                            tooltip: "Copy link",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // warning about sharing
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Always share the APK from this link, not your installed app. This ensures you can manage the shared app in your settings.",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // step 2
              _buildStepCard(
                stepNumber: 2,
                title: "Enter Activation Code",
                description:
                    "Your friend opens the app and enters this activation code.",
                icon: Icons.key_rounded,
                iconColor: Colors.orange,
                color: Colors.grey,
                child: Column(
                  children: [
                    // activation code display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _activationCode,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // copy code button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _copyToClipboard(_activationCode, isCode: true),
                        icon: Icon(
                          _codeCopied
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _codeCopied ? "Copied!" : "Copy Code",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _codeCopied
                              ? Colors.green
                              : Colors.orange,
                          side: BorderSide(
                            color: _codeCopied
                                ? Colors.green
                                : Colors.orange.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // info note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How it works",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Once your friend enters the activation code, they'll be connected to your FlexAI network and then you can control the app from your settings.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // helper widget for step cards
  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // step header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
