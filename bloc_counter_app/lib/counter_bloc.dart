import 'dart:async';

import 'counter_event.dart';

class CounterBloc {
  int _count = 0;
  final _events = StreamController<CounterEvent>();
  final _states = StreamController<int>();

  CounterBloc() {
    _events.stream
        .transform(StreamTransformer.fromHandlers(
      handleData: (event, sink){
        if(event == CounterEvent.decrement && _count == -1){
          sink.add(CounterEvent.reset);
        }
        else{
          sink.add(event);
        }
      }
    ))
        .listen((event) {
      switch (event) {
        case CounterEvent.increment:
          _count++;
          break;
        case CounterEvent.decrement:
          _count--;
          break;
          case CounterEvent.reset:
            _count = 0;
            break;
      }
      _states.add(_count);
    });
  }

 late final  Stream<int>  counter = _states.stream
  .transform(StreamTransformer.fromHandlers(
    handleData: (event,sink){
      if( event == 7){
        sink.add(10000);
      }
      else{
        sink.add(event);
      }
    }
  ));

  void dispose() {
    _events.close();
    _states.close();
  }

  void add(CounterEvent event) => _events
      .add(event);
}
