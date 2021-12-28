import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/app_widget.dart';

Future main() async {
  await dotenv.load();
  runApp(
    const ProviderScope(
      child: AppWidget(),
    ),
  );
}
