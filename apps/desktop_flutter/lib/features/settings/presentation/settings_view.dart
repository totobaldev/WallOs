import 'package:flutter/material.dart';

import '../../wallpapers/presentation/wallos_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final WallOsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Ajustes', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Configuracion inicial del MVP para rotacion automatica y experiencia de escritorio.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Intervalo de rotacion', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Cada ${controller.rotationMinutes} minutos',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Slider(
                  min: 5,
                  max: 120,
                  divisions: 23,
                  value: controller.rotationMinutes.toDouble(),
                  label: '${controller.rotationMinutes} min',
                  onChanged: controller.updateRotationMinutes,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
