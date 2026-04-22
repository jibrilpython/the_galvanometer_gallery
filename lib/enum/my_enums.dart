// ─── INSTRUMENT TYPE ──────────────────────────────────────────────────────────
enum InstrumentType {
  mirrorGalvanometer('Mirror Galvanometer'),
  tangentGalvanometer('Tangent Galvanometer'),
  ballisticGalvanometer('Ballistic Galvanometer'),
  movingCoilMeter('Moving Coil Meter'),
  astaticGalvanometer('Astatic Galvanometer'),
  electroscope('Electroscope'),
  wheatstoneBridge('Wheatstone Bridge'),
  hotWireInstrument('Hot-Wire Instrument'),
  other('Other');

  const InstrumentType(this.label);
  final String label;
}

// ─── OPERATING PRINCIPLE ────────────────────────────────────────────────────
enum OperatingPrinciple {
  movingCoil('Moving Coil (Electromagnetic)'),
  movingMagnet('Moving Magnet (Electromagnetic)'),
  electrostatic('Electrostatic'),
  thermalHotWire('Thermal — Hot Wire'),
  astaticPair('Astatic Needle Pair'),
  other('Other');

  const OperatingPrinciple(this.label);
  final String label;
}

// ─── SENSITIVITY CLASS ───────────────────────────────────────────────────────
enum SensitivityClass {
  microammeterClass('Microammeter Class'),
  milliammeterClass('Milliammeter Class'),
  ballistic('Ballistic'),
  mirrorOptical('Mirror / Optical'),
  astatic('Astatic'),
  other('Other');

  const SensitivityClass(this.label);
  final String label;
}

// ─── PRIMARY MATERIAL ────────────────────────────────────────────────────────
enum PrimaryMaterial {
  mahoganyBrass('Mahogany & Brass'),
  brassGlass('Brass & Glass'),
  castiron('Cast Iron'),
  eboniteWood('Ebonite & Wood'),
  glassGildedBrass('Glass & Gilded Brass'),
  mixed('Mixed / Unknown');

  const PrimaryMaterial(this.label);
  final String label;
}

// ─── CONDITION STATE ─────────────────────────────────────────────────────────
enum ConditionState {
  pristine('Pristine — Museum Quality'),
  coilIntact('Coil Intact — Fully Functional'),
  fiberBroken('Suspension Fiber Broken'),
  minorWear('Minor Wear — Original Lacquer'),
  restoredWorking('Restored — Working Condition'),
  incomplete('Incomplete — Parts Missing'),
  unknown('Unknown');

  const ConditionState(this.label);
  final String label;
}
