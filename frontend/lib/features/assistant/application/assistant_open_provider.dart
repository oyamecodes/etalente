import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the assistant popup is currently open.
///
/// Lives in `application/` rather than beside the widget so any page
/// (Job Board, Job Details) can watch it to hide the chat FAB while
/// the popup is mounted — without taking a dependency on the widget
/// file that owns the popup UI.
final assistantOpenProvider = StateProvider<bool>((ref) => false);
