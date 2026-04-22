import 'package:the_galvanometer_gallery/enum/my_enums.dart';

class GalvanometerModel {
  String id;
  String laboratoryIdentifier;
  InstrumentType instrumentType;
  String manufacturer;
  String countryOfOrigin;
  String eraOfProduction;
  OperatingPrinciple operatingPrinciple;
  SensitivityClass sensitivityClass;
  String internalResistance;
  String sensitivityAndScale;
  PrimaryMaterial primaryMaterial;
  String dimensionsAndWeight;
  ConditionState conditionState;
  String includedAccessories;
  String markingsAndEngravings;
  String provenance;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  GalvanometerModel({
    required this.id,
    required this.laboratoryIdentifier,
    required this.instrumentType,
    required this.manufacturer,
    required this.countryOfOrigin,
    required this.eraOfProduction,
    required this.operatingPrinciple,
    required this.sensitivityClass,
    required this.internalResistance,
    required this.sensitivityAndScale,
    required this.primaryMaterial,
    required this.dimensionsAndWeight,
    required this.conditionState,
    required this.includedAccessories,
    required this.markingsAndEngravings,
    required this.provenance,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'laboratoryIdentifier': laboratoryIdentifier,
        'instrumentType': instrumentType.name,
        'manufacturer': manufacturer,
        'countryOfOrigin': countryOfOrigin,
        'eraOfProduction': eraOfProduction,
        'operatingPrinciple': operatingPrinciple.name,
        'sensitivityClass': sensitivityClass.name,
        'internalResistance': internalResistance,
        'sensitivityAndScale': sensitivityAndScale,
        'primaryMaterial': primaryMaterial.name,
        'dimensionsAndWeight': dimensionsAndWeight,
        'conditionState': conditionState.name,
        'includedAccessories': includedAccessories,
        'markingsAndEngravings': markingsAndEngravings,
        'provenance': provenance,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory GalvanometerModel.fromJson(Map<String, dynamic> json) =>
      GalvanometerModel(
        id: json['id'] ?? '',
        laboratoryIdentifier: json['laboratoryIdentifier'] ?? '',
        instrumentType: InstrumentType.values.asNameMap()[json['instrumentType']] ?? InstrumentType.other,
        manufacturer: json['manufacturer'] ?? '',
        countryOfOrigin: json['countryOfOrigin'] ?? '',
        eraOfProduction: json['eraOfProduction'] ?? '',
        operatingPrinciple: OperatingPrinciple.values.asNameMap()[json['operatingPrinciple']] ?? OperatingPrinciple.other,
        sensitivityClass: SensitivityClass.values.asNameMap()[json['sensitivityClass']] ?? SensitivityClass.other,
        internalResistance: json['internalResistance'] ?? '',
        sensitivityAndScale: json['sensitivityAndScale'] ?? '',
        primaryMaterial: PrimaryMaterial.values.asNameMap()[json['primaryMaterial']] ?? PrimaryMaterial.mixed,
        dimensionsAndWeight: json['dimensionsAndWeight'] ?? '',
        conditionState: ConditionState.values.asNameMap()[json['conditionState']] ?? ConditionState.unknown,
        includedAccessories: json['includedAccessories'] ?? '',
        markingsAndEngravings: json['markingsAndEngravings'] ?? '',
        provenance: json['provenance'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
