import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateSpawnExample extends StatefulWidget {
  const IsolateSpawnExample({super.key});

  @override
  State<IsolateSpawnExample> createState() => _IsolateSpawnExampleState();
}

class _IsolateSpawnExampleState extends State<IsolateSpawnExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _callbackValue = 'Sem dados';
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(
          seconds: 5,
        ))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * 3.14159,
                  child: child,
                );
              },
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 5,
                    ),
                  ),
                  child: const FlutterLogo(size: 200)),
            ),
            const SizedBox(height: 100),
            Text(
              _callbackValue,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Row(
        children: [
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: _isolateMain,
            child: const Text(
              'Isolate Main',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: _isolateRun,
            child: const Text('Isolate Run',
                style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: _isolateSpawn,
            child: const Text('Isolate Spawn',
                style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _isolateMain() async {
    setState(() {
      _callbackValue = 'Isolate Main: Processando...';
    });
    int loop = _longLoop();
    setState(() {
      _callbackValue = 'Isolate Main: $loop';
    });
  }

  void _isolateRun() async {
    setState(() {
      _callbackValue = 'Isolate Run: Processando...';
    });
    final loopResult = Isolate.run(_longLoop);
    final loop = await loopResult;
    setState(() {
      _callbackValue = 'Isolate Run: $loop';
    });
  }

  // void _isolateRun() async {
  //   final loopResult = Isolate.run(_longLoop);
  //   final loop = await loopResult;
  //   print(loop);
  // }

  void _isolateSpawn() {
    setState(() {
      _callbackValue = 'Isolate Spawn: Processando...';
    });
    final receivePort = ReceivePort();
    Isolate.spawn(_isolateEntry, receivePort.sendPort);
    receivePort.listen((message) {
      setState(() {
        _callbackValue = 'Isolate Spawn: $message';
      });
    });
  }

  // void _isolateSpawn() {
  //   final receivePort = ReceivePort();
  //   Isolate.spawn(_isolateEntry, receivePort.sendPort);
  //   receivePort.listen((message) {
  //     print(message);
  //   });
  // }

  static void _isolateEntry(SendPort sendPort) {
    final loop = _longLoop();
    sendPort.send(loop);
  }

  // void _isolateRun() async {
  //   final loopResult = Isolate.run(_longLoop);
  //   final loop = await loopResult;
  //   print(loop);
  // }

  static int _longLoop() {
    int count = 0;
    for (int i = 0; i < 1000000000; i++) {
      count++;
    }
    return count;
  }
}
