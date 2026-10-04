import 'dart:async';

class CounterCubit {
  int _count = 0;
  final StreamController<int> _states = StreamController<int>();
  void increment(){
    _count++;
    _states.add(_count);
  }
  void decrement(){
    _count--;
    _states.add(_count);
  }
 late final Stream<int> counter = _states.stream;
  void dispose(){
    _states.close();
  }

}