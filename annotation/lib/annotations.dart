import 'package:meta/meta.dart';

@immutable
class RetrofitCommandable {
  const RetrofitCommandable();
}

@immutable
class Command {
  final String name;
  final String description;

  const Command({
    this.name,
    this.description,
  });
}
