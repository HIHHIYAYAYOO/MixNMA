import 'package:flutter/material.dart';

class NovelReaderSettings {
  static final ValueNotifier<double> fontSize = ValueNotifier(15.0);
  static final ValueNotifier<double> lineHeight = ValueNotifier(1.6);
  static final ValueNotifier<double> letterSpacing = ValueNotifier(0.5);
  static final ValueNotifier<double> paragraphSpacing = ValueNotifier(8.0);
  static final ValueNotifier<double> paragraphMargin = ValueNotifier(16.0);

  static void showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("調整閱讀設定", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildSlider("字體大小", fontSize, 10.0, 20.0, 20),
              const SizedBox(height: 16),
              _buildSlider("行間距離", lineHeight, 0.0, 2.0, 20),
              const SizedBox(height: 16),
              _buildSlider("文字間距", letterSpacing, 0.0, 2.0, 20),
              const SizedBox(height: 16),
              _buildSlider("段落間距", paragraphSpacing, 0.0, 20.0, 20),
              const SizedBox(height: 16),
              _buildSlider("段落邊距", paragraphMargin, 0.0, 20.0, 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSlider(String label, ValueNotifier<double> notifier, double min, double max, int divisions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Expanded(
          child: ValueListenableBuilder<double>(
            valueListenable: notifier,
            builder: (context, value, child) {
              return Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: value.toStringAsFixed(1),
                onChanged: (newValue) {
                  notifier.value = newValue;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
