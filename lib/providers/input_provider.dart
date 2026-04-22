import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_galvanometer_gallery/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _laboratoryIdentifier = '';
  InstrumentType _instrumentType = InstrumentType.mirrorGalvanometer;
  String _manufacturer = '';
  String _countryOfOrigin = '';
  String _eraOfProduction = '';
  OperatingPrinciple _operatingPrinciple = OperatingPrinciple.movingCoil;
  SensitivityClass _sensitivityClass = SensitivityClass.microammeterClass;
  String _internalResistance = '';
  String _sensitivityAndScale = '';
  PrimaryMaterial _primaryMaterial = PrimaryMaterial.brassGlass;
  String _dimensionsAndWeight = '';
  ConditionState _conditionState = ConditionState.unknown;
  String _includedAccessories = '';
  String _markingsAndEngravings = '';
  String _provenance = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  // Getters
  String get laboratoryIdentifier => _laboratoryIdentifier;
  InstrumentType get instrumentType => _instrumentType;
  String get manufacturer => _manufacturer;
  String get countryOfOrigin => _countryOfOrigin;
  String get eraOfProduction => _eraOfProduction;
  OperatingPrinciple get operatingPrinciple => _operatingPrinciple;
  SensitivityClass get sensitivityClass => _sensitivityClass;
  String get internalResistance => _internalResistance;
  String get sensitivityAndScale => _sensitivityAndScale;
  PrimaryMaterial get primaryMaterial => _primaryMaterial;
  String get dimensionsAndWeight => _dimensionsAndWeight;
  ConditionState get conditionState => _conditionState;
  String get includedAccessories => _includedAccessories;
  String get markingsAndEngravings => _markingsAndEngravings;
  String get provenance => _provenance;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  // Setters
  set laboratoryIdentifier(String v) { _laboratoryIdentifier = v; notifyListeners(); }
  set instrumentType(InstrumentType v) { _instrumentType = v; notifyListeners(); }
  set manufacturer(String v) { _manufacturer = v; notifyListeners(); }
  set countryOfOrigin(String v) { _countryOfOrigin = v; notifyListeners(); }
  set eraOfProduction(String v) { _eraOfProduction = v; notifyListeners(); }
  set operatingPrinciple(OperatingPrinciple v) { _operatingPrinciple = v; notifyListeners(); }
  set sensitivityClass(SensitivityClass v) { _sensitivityClass = v; notifyListeners(); }
  set internalResistance(String v) { _internalResistance = v; notifyListeners(); }
  set sensitivityAndScale(String v) { _sensitivityAndScale = v; notifyListeners(); }
  set primaryMaterial(PrimaryMaterial v) { _primaryMaterial = v; notifyListeners(); }
  set dimensionsAndWeight(String v) { _dimensionsAndWeight = v; notifyListeners(); }
  set conditionState(ConditionState v) { _conditionState = v; notifyListeners(); }
  set includedAccessories(String v) { _includedAccessories = v; notifyListeners(); }
  set markingsAndEngravings(String v) { _markingsAndEngravings = v; notifyListeners(); }
  set provenance(String v) { _provenance = v; notifyListeners(); }
  set notes(String v) { _notes = v; notifyListeners(); }
  set photoPath(String v) { _photoPath = v; notifyListeners(); }
  set tags(List<String> v) { _tags = v; notifyListeners(); }
  set dateAdded(DateTime v) { _dateAdded = v; notifyListeners(); }

  void clearAll() {
    _laboratoryIdentifier = '';
    _instrumentType = InstrumentType.mirrorGalvanometer;
    _manufacturer = '';
    _countryOfOrigin = '';
    _eraOfProduction = '';
    _operatingPrinciple = OperatingPrinciple.movingCoil;
    _sensitivityClass = SensitivityClass.microammeterClass;
    _internalResistance = '';
    _sensitivityAndScale = '';
    _primaryMaterial = PrimaryMaterial.brassGlass;
    _dimensionsAndWeight = '';
    _conditionState = ConditionState.unknown;
    _includedAccessories = '';
    _markingsAndEngravings = '';
    _provenance = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
