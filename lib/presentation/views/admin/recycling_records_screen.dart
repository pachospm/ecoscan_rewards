import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/records_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/recycling_record_tile.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';

class RecyclingRecordsScreen extends StatefulWidget {
  const RecyclingRecordsScreen({super.key});

  @override
  State<RecyclingRecordsScreen> createState() =>
      _RecyclingRecordsScreenState();
}

class _RecyclingRecordsScreenState extends State<RecyclingRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<RecordsViewModel>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecordsViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Registros (${vm.records.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreenLight))
          : vm.records.isEmpty
              ? const EmptyState(
                  icon: Icons.recycling,
                  title: 'Sin registros',
                  subtitle: 'Aún no hay reciclajes guardados',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadAll(),
                  color: AppTheme.primaryGreenLight,
                  backgroundColor: AppTheme.cardDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: vm.records.length,
                    itemBuilder: (context, index) {
                      final record = vm.records[index];
                      return FadeSlideAnimation(
                        delay: Duration(milliseconds: 40 * index),
                        child: RecyclingRecordTile(
                          record: record,
                          userName: vm.getUserName(record.userId),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
