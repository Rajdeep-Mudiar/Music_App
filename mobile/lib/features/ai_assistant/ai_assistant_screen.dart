import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/providers/study_provider.dart';

class ChatMessageItem {
  final String text;
  final bool isUser;
  final List<Map<String, dynamic>> toolCalls;
  final List<Track> tracks;

  ChatMessageItem({
    required this.text,
    required this.isUser,
    this.toolCalls = const [],
    this.tracks = const [],
  });
}

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessageItem> _messages = [
    ChatMessageItem(
      text: "Hello Rajdeep! I am your Resonance AI Music & Study Assistant. You can ask me to play coding beats, start a Pomodoro timer, or craft an exam study session playlist.",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    "Play something relaxing for coding",
    "I have a 4-hour DSA study session",
    "Start 25-minute Pomodoro",
    "Play trending campus music",
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessageItem(text: userMsg, isUser: true));
      _isLoading = true;
    });

    final aiService = ref.read(aiServiceProvider);
    final response = await aiService.sendChatMessage(userMsg);

    // Process tool calls
    for (var tool in response.toolCalls) {
      final name = tool['tool'];
      if (name == 'start_study_session') {
        ref.read(studyTimerProvider.notifier).startTimer();
      } else if (name == 'play_song' && response.suggestedTracks.isNotEmpty) {
        ref.read(playerProvider.notifier).playTrack(response.suggestedTracks[0], queue: response.suggestedTracks);
      }
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessageItem(
          text: response.reply,
          isUser: false,
          toolCalls: response.toolCalls,
          tracks: response.suggestedTracks,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.secondary, size: 20),
            SizedBox(width: 8),
            Text('AI Music Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Prompts row
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(prompt),
                    backgroundColor: AppTheme.darkSurface,
                    labelStyle: const TextStyle(fontSize: 12, color: AppTheme.primaryLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.darkBorder),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              },
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondary),
                ),
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
              border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic, color: AppTheme.secondary),
                  tooltip: 'Voice Command',
                  onPressed: () {
                    _sendMessage("Play something relaxing for coding");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice command detected: "Play something relaxing for coding"')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask for focus tunes, timers, or playlists...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primary),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageItem msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primary : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: msg.isUser ? AppTheme.primary : AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            // Tool badges
            if (msg.toolCalls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: msg.toolCalls.map((tool) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: AppTheme.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Executed: ${tool['tool']}()',
                          style: const TextStyle(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            // Suggested tracks mini-list
            if (msg.tracks.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...msg.tracks.take(2).map((t) {
                return GestureDetector(
                  onTap: () {
                    ref.read(playerProvider.notifier).playTrack(t, queue: msg.tracks);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill, color: AppTheme.secondary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${t.title} - ${t.artist}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
