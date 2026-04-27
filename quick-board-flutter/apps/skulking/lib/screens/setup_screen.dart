import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../notifiers/skulking_notifier.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _playerCount = 5;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers(_playerCount, []);
  }

  List<TextEditingController> _buildControllers(int count, List<TextEditingController> old) {
    return List.generate(
      count,
      (i) => TextEditingController(
        text: old.length > i ? old[i].text : '',
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPlayerCountChanged(int? value) {
    if (value == null) return;
    final old = _controllers;
    setState(() {
      _playerCount = value;
      _controllers = _buildControllers(value, old);
    });
    for (final c in old) {
      c.dispose();
    }
  }

  void _startGame() {
    final players = List.generate(
      _playerCount,
      (i) {
        final name = _controllers[i].text.trim();
        return name.isEmpty ? '플레이어 ${i + 1}' : name;
      },
    );
    ref.read(skulkingProvider.notifier).startGame(players);
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                '☠️ 게임 설정',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text('플레이어 수', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _playerCount,
                dropdownColor: AppColors.card,
                style: AppTextStyles.body,
                isExpanded: true,
                items: List.generate(7, (i) => i + 2)
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n명')))
                    .toList(),
                onChanged: _onPlayerCountChanged,
              ),
              const SizedBox(height: 24),
              Text('플레이어 이름', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...List.generate(
                _playerCount,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlayerNameInput(
                    label: '플레이어 ${i + 1} 이름',
                    controller: _controllers[i],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: '⚓ 게임 시작',
                onPressed: _startGame,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
