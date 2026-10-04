import 'package:bloc_counter_app/counter_bloc.dart';
import 'package:bloc_counter_app/counter_cubit.dart';
import 'package:bloc_counter_app/counter_event.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.indigo),
        ),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final CounterBloc _bloc = CounterBloc();
  final CounterCubit _cubit = CounterCubit();

  @override
  void dispose() {
    _cubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bloc Counter App")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<int>(
            stream: _cubit.counter,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasData) {
                return Text(
                  "The counter is ${asyncSnapshot.data}",
                  style: TextStyle(fontSize: 24),
                );
              } else if (asyncSnapshot.hasError) {
                return Text("Error: ${asyncSnapshot.error}");
              }

              return Text("....");
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  _cubit.increment();
                },
                label: Text("Increment"),
                icon: Icon(Icons.add),
              ),
              TextButton.icon(
                onPressed: () {
                  _cubit.decrement();
                },
                label: Text("Decrement"),
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
