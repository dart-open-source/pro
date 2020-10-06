A Command line Api library for Dart developers.


## Usage
command line apps for small things...

your app.dart file example:

```dart
import 'package:alm/alm.dart';
import 'package:pro/pro.dart';

void main(List<String> arguments) async {
  /// actions [start stop restart status] available else running the loop
  if (!await Pro(arguments).checkAction()) return;

  Pro.log('hello world!!!');

  while (true) {
    await Alm.delaySecond();
    Pro.log('tick:${Alm.timeId()}');
  }
}

```


## Usage only Command Line

-  tested only linux and macos

```shell

$ dart example/app.dart

$ dart example/app.dart start

$ dart example/app.dart stop

$ dart example/app.dart restart

$ dart example/app.dart status

```
....