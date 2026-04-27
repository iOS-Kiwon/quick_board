import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../notifiers/yacht_notifier.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../widgets/yacht_button.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _playerCount = 3;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(8, (_) => TextEditingController());
    _focusNodes = List.generate(8, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _increment() {
    if (_playerCount < 8) setState(() => _playerCount++);
  }

  void _decrement() {
    if (_playerCount > 2) setState(() => _playerCount--);
  }

  void _startGame() {
    final players = List.generate(_playerCount, (i) {
      final name = _controllers[i].text.trim();
      return name.isEmpty ? 'P${i + 1}' : name;
    });
    ref.read(yachtProvider.notifier).startGame(players);
    context.go('/score');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: YachtColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.appName, style: YachtTextStyles.appTitle),
              const SizedBox(height: 24),
              Text(l.setupTitle, style: YachtTextStyles.heading),
              const SizedBox(height: 16),
              _PlayerCountRow(
                count: _playerCount,
                label: l.playerCount,
                onIncrement: _increment,
                onDecrement: _decrement,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(_playerCount, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i < _playerCount - 1 ? 10 : 0),
                          child: FocusTraversalOrder(
                            order: NumericFocusOrder(i.toDouble()),
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              style: YachtTextStyles.body,
                              textInputAction: i < _playerCount - 1
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onSubmitted: (_) {
                                if (i < _playerCount - 1) {
                                  _focusNodes[i + 1].requestFocus();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: l.playerName(i + 1),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              YachtButton(label: l.startGame, onPressed: _startGame),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCountRow extends StatelessWidget {
  const _PlayerCountRow({
    required this.count,
    required this.label,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int count;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: YachtTextStyles.body),
        const Spacer(),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline, color: YachtColors.primary),
        ),
        Text('$count', style: YachtTextStyles.heading),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline, color: YachtColors.primary),
        ),
      ],
    );
  }
}
