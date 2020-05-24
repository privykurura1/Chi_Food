
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class SelectionEvent extends Equatable {
  const SelectionEvent();

  @override
  List<Object> get props => [];
}

class LoadingSelection extends SelectionEvent{}

class LoadSelectionSuccess extends SelectionEvent{}

class LoadCategory extends SelectionEvent{

}

class LoadCusines extends SelectionEvent{
  final int city_id;
  final double lat;
  final double lon;

  LoadCusines({@required this.city_id, this.lat, this.lon});

}

class LoadEstablishment extends SelectionEvent{
  final int city_id;
  final double lat;
  final double lon;

  LoadEstablishment({@required this.city_id, this.lat, this.lon});
}

class LoadSelectionFail extends SelectionEvent{}
