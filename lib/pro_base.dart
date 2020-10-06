import 'dart:io';
import 'package:process_run/process_run.dart' as pr;
import 'package:alm/alm.dart';

import 'tempCon.dart';

class Pro {
  final List<String> arguments;
  static String path = '.pro/';
  static String exe = 'lib/app.dart';
  static String get currentExe => Platform.script.path.replaceAll(Directory.current.path, '').substring(1);
  static String name = 'DART#PRO';

  static Function(dynamic) log=(o){print('Pro[${Alm.timestamp()}] $o');};

  int _pidOld = -1;

  static File file(String s) =>Alm.file([path, s].join(),autoDir: true);

  Pro(this.arguments, {String path, String exe, String name}) {
    if(path!=null) Pro.path = path;
    if(name!=null) Pro.name = name;
    Pro.exe=exe??currentExe;

    Alm.gitIgnoreUpdate(File('.gitignore'), Pro.path);
    if (!file('cli').existsSync()) {
      file('cli').writeAsStringSync(tempCli.replaceAll('#head#', '#${Alm.timestampStr()}'));
    }
  }

  int pidOld([int r]) {
    var pidFile = file('.pid');
    if (r != null) {
      pidFile.writeAsStringSync(r.toString());
      return r;
    }
    return pidFile.existsSync() ? Alm.any2int(pidFile.readAsStringSync()) : -1;
  }

  Future<bool> isPidRunning(int id, {bool isLog = false}) async {
    if (id == -1) return false;
    var res = await pr.run('ps', ['-p', id.toString()]);
    var chou = res.stdout.toString().trim().split('\n');
    if (isLog) log(res.stdout.toString());
    if (chou.length >= 2) return true;
    return false;
  }

  Future<void> _start() async {
    log('Start...[$_pidOld]');
    if (await isPidRunning(_pidOld)) {
      log('already start at:$_pidOld');
    } else {
      var cmd = '$path/cli $exe ${name} $path/${Alm.timeymd()}'.replaceAll('//', '/');
      log('cmd:$cmd');
      var res = await pr.run('sh', cmd.split(' '));
      log('stdout:${res.stdout}');
      log('stderr:${res.stderr}');
      var o = 0;
      while (true) {
        log('...:${pidOld()}');
        await Future.delayed(Duration(seconds: 1));
        o++;
        if (o > 10) break;
        if (pidOld() != -1) break;
      }
      if (pidOld() != -1) {
        log('now start at:${pidOld()}');
      } else {
        log('start is failed!!!');
        await _stop();
      }
    }
  }

  Future<void> _stop() async {
    log('Stop...[$_pidOld]');
    if (await isPidRunning(_pidOld)) {
      await pr.run('kill', [_pidOld.toString()]);
      log('now stop at:$_pidOld');
    } else {
      log('already stop!');
    }
    pidOld(-1);
  }

  Future<void> _status() async {
    log('Status...[$_pidOld]');
    if (await isPidRunning(_pidOld, isLog: true)) {
      log('status:${_pidOld} is running;');
    } else {
      log('status:${_pidOld} is stop;');
    }
  }

  Future<bool> checkAction() async {
    var action = arguments.isNotEmpty ? arguments.first : name;
    _pidOld = pidOld();
    if (action == 'start') await _start();
    if (action == 'stop') await _stop();
    if (action == 'restart') {
      await _stop();
      await Alm.delaySecond(3);
      await _start();
    }
    if (action == 'status') await _status();
    if (action == name) {
      log('Run...[$_pidOld]');
      if (await isPidRunning(_pidOld)) {
        log('already running at:${_pidOld}');
      } else {
        pidOld(pid);
        log('currently run at:$pid');
        return true;
      }
    }
    return false;
  }
}
