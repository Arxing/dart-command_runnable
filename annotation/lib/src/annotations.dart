import 'package:meta/meta.dart';

@immutable
class CommandRunnable {

  const CommandRunnable();
}

@immutable
class CommandAction {
  final String name;
  final String description;
  final bool asynchronous;

  const CommandAction({
    this.name,
    this.description,
    this.asynchronous = false,
  });
}

@immutable
class CommandOption {
  final String optionName;
  final String help;

  const CommandOption({
    this.optionName,
    this.help,
  });
}
