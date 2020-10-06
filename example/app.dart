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
