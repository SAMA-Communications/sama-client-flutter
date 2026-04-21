import 'package:equatable/equatable.dart';

sealed class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();
}

final class TextChanged extends GlobalSearchEvent {
  const TextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChanged { text: $text }';
}
