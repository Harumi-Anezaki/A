import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/todo_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final completed = todos.where((t) => t.isCompleted).length;
    final total = todos.length;
    final incomplete = total - completed;

    return Scaffold(
      body: total == 0
          ? const Center(child: Text('No tasks to analyze'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: completed.toDouble(),
                            title: '$completed\nDone',
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: incomplete.toDouble(),
                            title: '$incomplete\nLeft',
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Completion Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    minHeight: 15,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 10),
                  Text('${((total == 0 ? 0 : completed / total) * 100).toStringAsFixed(1)}% Completed'),
                ],
              ),
            ),
    );
  }
}
