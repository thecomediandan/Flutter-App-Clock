import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(title: 'Mi Reloj'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _stateDay = "Dia";
  String _time = '';
  String _sec = '00:00:00';
  bool _swCrono = false;
  bool _swPause = false;
  IconData isPlayPause = Icons.play_arrow_outlined;

  int _cSegundos = -1;
  int _cMinutos = 0;
  int _cHoras = 0;

  String formatDate(int hour, int minute, int seconds) {
    String h = '00';
    String m = '00';
    String s = '00';

    hour < 10 ? h = '0$hour' : h = '$hour';
    minute < 10 ? m = '0$minute' : m = '$minute';
    seconds < 10 ? s = '0$seconds' : s = '$seconds';

    return '$h:$m:$s';
  }

  Stream<String> emitNumbers() {
    return Stream.periodic(const Duration(seconds: 1), (value) {
      // print( 'Desde Stream periodic $value' );
      DateTime date = DateTime.now();
      if ((date.hour <= 23) || (date.hour == 0)) _stateDay = 'Noche';
      if (date.hour <= 18) _stateDay = 'Tarde';
      if ((date.hour <= 12) && (date.hour != 0)) _stateDay = 'Mañana';

      // print(formatDate(date.hour, date.minute, date.second));
      return formatDate(date.hour, date.minute, date.second);
    });
  }

  Stream<String> cronometro(int s, int m, int h) {
    _cSegundos = s;
    _cMinutos = m;
    _cHoras = h;
    return Stream.periodic(const Duration(seconds: 1), (value) {
      // print( 'Desde Stream periodic $value' );
      if (_cSegundos == 59) {
        _cSegundos = 0;
        if (_cMinutos == 59) {
          _cMinutos = 0;
          if (_cHoras == 59) {
            _cHoras = 0;
          } else {
            _cHoras++;
          }
        } else {
          _cMinutos++;
        }
      } else {
        _cSegundos++;
      }

      // print(formatDate(date.hour, date.minute, date.second));
      return formatDate(_cHoras, _cMinutos, _cSegundos);
    }).takeWhile((element) => _swCrono);
  }

  @override
  Widget build(BuildContext context) {
    emitNumbers().listen((value) {
      setState(() {
        // ? Al utilizar setState se actualizan todos los cambios que se realizaron en los Widgets, incluyendo el de la hora aunque no lo pongamos en el cuerpo de esta funcion.
        _time = value;
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _time,
            style: const TextStyle(fontSize: 70),
          ),
          Text(
            _stateDay,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 40),
          Text(
            _sec,
            style: const TextStyle(fontSize: 50),
          ),
          const SizedBox(height: 40),
          const Image(
            image: AssetImage('img/dog.png'),
            width: 190,
          )
        ],
      )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              onPressed: () {
                _swCrono = true;
                if (!_swPause) {
                  _swPause = true;
                  isPlayPause = Icons.pause_circle_filled_outlined;
                  cronometro(_cSegundos, _cMinutos, _cHoras).listen((value) {
                    setState(() {
                      _sec = value;
                    });
                  });
                } else {
                  _swPause = false;
                  setState(() {
                    isPlayPause = Icons.play_arrow_outlined;
                    _swCrono = false;
                    _cSegundos == 0 ? _cSegundos = 59 : _cSegundos--;
                  });
                }
              },
              tooltip: 'Increment',
              child: Icon(isPlayPause)),
          const SizedBox(width: 20),
          FloatingActionButton(
              onPressed: () {
                setState(() {
                  isPlayPause = Icons.play_arrow_outlined;
                  _swCrono = false;
                  _sec = '00:00:00';
                  _cSegundos = -1;
                  _cMinutos = 0;
                  _cHoras = 0;
                });
              },
              tooltip: 'Increment',
              child: const Icon(Icons.replay_outlined))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
