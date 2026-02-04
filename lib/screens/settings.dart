import 'package:flexai/main.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- PROVIDERS (State Management) ---

// 1. Owner Text Provider
final ownerNameProvider = StateProvider<String>((ref) => "");

// 2. AI Instruction Mode (false = Simple/Guided, true = Advanced/Full)
final isAdvancedModeProvider = StateProvider<bool>((ref) => false);

// 3. Simple Mode Characteristics
final personaNameProvider = StateProvider<String>((ref) => "");
final selectedToneProvider = StateProvider<String>((ref) => "Friendly");
final selectedVibeProvider = StateProvider<String>((ref) => "Professional");
final selectedIdentityProvider = StateProvider<String>((ref) => "Assistant");
final selectedLanguageProvider = StateProvider<String>((ref) => "English");
final selectedApproachProvider = StateProvider<String>((ref) => "Supportive");

// 4. Creator social links
final portfolioLinkProvider = StateProvider<String>((ref) => "");

// 5. Advanced Mode Full Text
final customInstructionProvider = StateProvider<String>((ref) => "");

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  final _supabaseService = SupabaseService();
  bool _isSaving = false;

  // controllers to handle text input without cursor jumping
  late TextEditingController _ownerController;
  late TextEditingController _customInstructionController;
  late TextEditingController _personaNameController;
  late TextEditingController _portfolioController;
  late TextEditingController _footerTextController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current provider state
    _ownerController = TextEditingController(text: ref.read(ownerNameProvider));
    _customInstructionController = TextEditingController(
      text: ref.read(customInstructionProvider),
    );
    _personaNameController = TextEditingController(
      text: ref.read(personaNameProvider),
    );
    _portfolioController = TextEditingController(
      text: ref.read(portfolioLinkProvider),
    );
    _footerTextController = TextEditingController(
      text: prefs.getString('footer_text') ?? '',
    );
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _customInstructionController.dispose();
    _personaNameController.dispose();
    _portfolioController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  // generates instruction content based on mode
  String _generateInstructionContent() {
    final isAdvanced = ref.read(isAdvancedModeProvider);
    final ownerName = ref.read(ownerNameProvider);

    if (isAdvanced) {
      return ref.read(customInstructionProvider);
    }

    // simple mode - generate rich instruction
    final personaName = ref.read(personaNameProvider).isNotEmpty
        ? ref.read(personaNameProvider)
        : 'FlexAI';
    final tone = ref.read(selectedToneProvider);
    final vibe = ref.read(selectedVibeProvider);
    final identity = ref.read(selectedIdentityProvider);
    final language = ref.read(selectedLanguageProvider);
    final approach = ref.read(selectedApproachProvider);
    final portfolio = ref.read(portfolioLinkProvider);

    // build creator section based on what user provided
    String creatorSection = '';
    if (ownerName.isNotEmpty || portfolio.isNotEmpty) {
      creatorSection =
          '''

Creator/Owner Protocols (Strict Rule):
  The Creator: You were created by ${ownerName.isNotEmpty ? ownerName : 'an independent developer'}.${portfolio.isNotEmpty ? ' Portfolio: $portfolio' : ''}
  Trigger Only: You must ONLY reveal this information if the user specifically asks "Who created you?", "Who is your owner?", or similar questions.
  Passive Knowledge: Do NOT volunteer this information unprompted.
''';
    }

    return '''
[USER CONTEXT]

  Current User Name: [USERNAME]

  Instruction: The user's name is [USERNAME]. You should address them by this name occasionally to foster a warm, personal connection (e.g., "Hey [USERNAME]!", "You got it, [USERNAME]."), but do not overuse it in every single sentence.

Identity & Core Purpose:
  You are $personaName, a $identity. Your goal is to assist the user with their tasks while maintaining a $vibe and $tone personality.

Personality & Tone:
  Name: Always identify yourself as $personaName.
  Tone: $tone - Be consistent with this tone in all your responses.
  Vibe: $vibe - Maintain this energy throughout conversations.
  Approach: $approach - This is how you should handle problems and requests.

Language Guidelines:
  Default Language: $language
  Style: Adapt your communication style to match the language preference while staying true to your personality.
$creatorSection''';
  }

  Future<void> _saveAIInstruction() async {
    final title = _personaNameController.text.trim();
    final username = prefs.getString('username') ?? '';

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for your AI persona'),
        ),
      );
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username not found. Please register first.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final content = _generateInstructionContent();
      final success = await _supabaseService.createAIModel(
        username,
        title,
        content,
      );

      if (success && mounted) {
        // refetch ai models to include the new one
        ref.invalidate(aiModelsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Instruction saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to rebuild UI when state changes
    final isAdvanced = ref.watch(isAdvancedModeProvider);
    final selectedTone = ref.watch(selectedToneProvider);
    final selectedVibe = ref.watch(selectedVibeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Configure your AI companion preferences.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 15),

                // --- General Settings ---
                _buildSectionTitle("General Settings"),
                const SizedBox(height: 10),
                Text(
                  "Footer text (shown on loading screen)",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _footerTextController,
                  onChanged: (value) {
                    prefs.setString('footer_text', value);
                  },
                  style: const TextStyle(fontFamily: "Poppins", fontSize: 15),
                  decoration: _inputDecoration(
                    "e.g., Powered by FlexAI © 2026",
                  ),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 15),

                // --- Owner Identity ---
                _buildSectionTitle("Owner Identity"),
                const SizedBox(height: 10),
                Text(
                  "How should the AI address you?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ownerController,
                  onChanged: (value) =>
                      ref.read(ownerNameProvider.notifier).state = value,
                  style: const TextStyle(fontFamily: "Poppins", fontSize: 15),
                  decoration: _inputDecoration("e.g., Your Name"),
                ),
                const SizedBox(height: 15),
                Text(
                  "Your portfolio or social link (optional)",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _portfolioController,
                  onChanged: (value) =>
                      ref.read(portfolioLinkProvider.notifier).state = value,
                  style: const TextStyle(fontFamily: "Poppins", fontSize: 15),
                  decoration: _inputDecoration(
                    "e.g., https://yourportfolio.com",
                  ),
                ),
                const SizedBox(height: 15),

                const SizedBox(height: 30),

                // --- SECTION 2: AI INSTRUCTIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("AI Persona"),
                    // Toggle Switch for Mode
                    Row(
                      children: [
                        Text(
                          isAdvanced ? "Advanced" : "Simple",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: isAdvanced,
                          activeThumbColor: Colors.blueAccent,
                          onChanged: (value) {
                            ref.read(isAdvancedModeProvider.notifier).state =
                                value;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // CONDITIONAL UI: Simple vs Advanced
                AnimatedCrossFade(
                  firstChild: _buildSimpleModeUI(
                    ref,
                    selectedTone,
                    selectedVibe,
                  ),
                  secondChild: _buildAdvancedModeUI(ref),
                  crossFadeState: isAdvanced
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 20),

                // --- SECTION 3: SAVE AI INSTRUCTION ---
                const Divider(),
                const SizedBox(height: 15),
                // warning note about one-model limit
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "You can only create ONE AI persona. Saving will overwrite the previous instruction.",
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
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAIInstruction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Save AI Instruction",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Simple Mode (Chips) ---
  Widget _buildSimpleModeUI(WidgetRef ref, String tone, String vibe) {
    final identity = ref.watch(selectedIdentityProvider);
    final language = ref.watch(selectedLanguageProvider);
    final approach = ref.watch(selectedApproachProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // persona name input
        _buildLabel("Persona Name"),
        TextField(
          controller: _personaNameController,
          onChanged: (value) =>
              ref.read(personaNameProvider.notifier).state = value,
          style: const TextStyle(fontFamily: "Poppins", fontSize: 15),
          decoration: _inputDecoration("e.g., Tita AI, Buddy, Coach"),
        ),
        const SizedBox(height: 15),

        // identity
        _buildLabel("Identity"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ["Assistant", "Mentor", "Friend", "Coach", "Advisor", "Companion"]
                  .map(
                    (option) => ChoiceChip(
                      label: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      selected: identity == option,
                      selectedColor: const Color.fromARGB(48, 0, 150, 135),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedIdentityProvider.notifier).state =
                              option;
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 15),

        // tone
        _buildLabel("Tone"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ["Friendly", "Strict", "Funny", "Empathetic", "Formal", "Caring"]
                  .map(
                    (option) => ChoiceChip(
                      label: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      selected: tone == option,
                      selectedColor: const Color.fromARGB(50, 68, 137, 255),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedToneProvider.notifier).state =
                              option;
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 15),

        // vibe
        _buildLabel("Vibe"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ["Professional", "Casual", "Warm", "Cool", "Playful", "Classy"]
                  .map(
                    (option) => ChoiceChip(
                      label: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      selected: vibe == option,
                      selectedColor: const Color.fromARGB(45, 223, 64, 251),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedVibeProvider.notifier).state =
                              option;
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 15),

        // language
        _buildLabel("Language"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ["English", "Filipino", "Taglish", "Bisaya"]
              .map(
                (option) => ChoiceChip(
                  label: Text(
                    option,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  ),
                  selected: language == option,
                  selectedColor: const Color.fromARGB(38, 76, 175, 79),
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedLanguageProvider.notifier).state =
                          option;
                    }
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),

        // approach
        _buildLabel("Approach"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    "Supportive",
                    "Direct",
                    "Encouraging",
                    "Analytical",
                    "Nurturing",
                    "Witty",
                  ]
                  .map(
                    (option) => ChoiceChip(
                      label: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      selected: approach == option,
                      selectedColor: const Color.fromARGB(29, 255, 193, 7),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedApproachProvider.notifier).state =
                              option;
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // --- WIDGET HELPER: Advanced Mode (Full Text) ---
  Widget _buildAdvancedModeUI(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Write the exact system instruction for the AI.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _customInstructionController,
          maxLines: 8,
          onChanged: (value) =>
              ref.read(customInstructionProvider.notifier).state = value,
          style: const TextStyle(fontFamily: "Poppins", fontSize: 14),
          decoration: _inputDecoration("Enter full prompt here..."),
        ),
      ],
    );
  }

  // --- STYLING HELPERS ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 14,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.all(15),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
    );
  }
}
