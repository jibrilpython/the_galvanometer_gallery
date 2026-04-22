import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:the_galvanometer_gallery/models/project_model.dart';
import 'package:the_galvanometer_gallery/providers/image_provider.dart';
import 'package:the_galvanometer_gallery/providers/input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<GalvanometerModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'tgg_entries_v1';
  final _uuid = const Uuid();

  void _sortEntries() {
    entries.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries =
            decodedList
                .map((item) => GalvanometerModel.fromJson(item))
                .toList();
        _sortEntries();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    final newEntry = GalvanometerModel(
      id: _uuid.v4(),
      laboratoryIdentifier: p.laboratoryIdentifier,
      instrumentType: p.instrumentType,
      manufacturer: p.manufacturer,
      countryOfOrigin: p.countryOfOrigin,
      eraOfProduction: p.eraOfProduction,
      operatingPrinciple: p.operatingPrinciple,
      sensitivityClass: p.sensitivityClass,
      internalResistance: p.internalResistance,
      sensitivityAndScale: p.sensitivityAndScale,
      primaryMaterial: p.primaryMaterial,
      dimensionsAndWeight: p.dimensionsAndWeight,
      conditionState: p.conditionState,
      includedAccessories: p.includedAccessories,
      markingsAndEngravings: p.markingsAndEngravings,
      provenance: p.provenance,
      notes: p.notes,
      photoPath:
          imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: DateTime.now(),
    );

    entries = [newEntry, ...entries];
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    final updatedEntry = GalvanometerModel(
      id: existing.id,
      laboratoryIdentifier: p.laboratoryIdentifier,
      instrumentType: p.instrumentType,
      manufacturer: p.manufacturer,
      countryOfOrigin: p.countryOfOrigin,
      eraOfProduction: p.eraOfProduction,
      operatingPrinciple: p.operatingPrinciple,
      sensitivityClass: p.sensitivityClass,
      internalResistance: p.internalResistance,
      sensitivityAndScale: p.sensitivityAndScale,
      primaryMaterial: p.primaryMaterial,
      dimensionsAndWeight: p.dimensionsAndWeight,
      conditionState: p.conditionState,
      includedAccessories: p.includedAccessories,
      markingsAndEngravings: p.markingsAndEngravings,
      provenance: p.provenance,
      notes: p.notes,
      photoPath:
          imgProv.resultImage.isNotEmpty
              ? imgProv.resultImage
              : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    final newList = List<GalvanometerModel>.from(entries);
    newList[index] = updatedEntry;
    entries = newList;

    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<GalvanometerModel>.from(entries);
    newList.removeAt(index);
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.laboratoryIdentifier = entry.laboratoryIdentifier;
    p.instrumentType = entry.instrumentType;
    p.manufacturer = entry.manufacturer;
    p.countryOfOrigin = entry.countryOfOrigin;
    p.eraOfProduction = entry.eraOfProduction;
    p.operatingPrinciple = entry.operatingPrinciple;
    p.sensitivityClass = entry.sensitivityClass;
    p.internalResistance = entry.internalResistance;
    p.sensitivityAndScale = entry.sensitivityAndScale;
    p.primaryMaterial = entry.primaryMaterial;
    p.dimensionsAndWeight = entry.dimensionsAndWeight;
    p.conditionState = entry.conditionState;
    p.includedAccessories = entry.includedAccessories;
    p.markingsAndEngravings = entry.markingsAndEngravings;
    p.provenance = entry.provenance;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
