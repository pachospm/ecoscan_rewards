import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/records_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/recycling_record_tile.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';

class RecyclingHistoryScreen extends StatefulWidget {
  const RecyclingHistoryScreen({super.key});

  @override
  State<RecyclingHistoryScreen> createState() => _RecyclingHistoryScreenState();
}

class _RecyclingHistoryScreenState extends State<RecyclingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) {
      context.read<RecordsViewModel>().loadByUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordsViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Historial de reciclaje'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreenLight),
            )
          : vm.records.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'Sin registros aún',
                  subtitle:
                      'Tus reciclajes aparecerán aquí después de escanear',
                )
              : RefreshIndicator(
                  onRefresh: () async => _load(),
                  color: AppTheme.primaryGreenLight,
                  backgroundColor: AppTheme.cardDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: vm.records.length,
                    itemBuilder: (context, index) {
                      return FadeSlideAnimation(
                        delay: Duration(milliseconds: 40 * index),
                        child: RecyclingRecordTile(record: vm.records[index]),
                      );
                    },
                  ),
                ),
    );
  }
}
