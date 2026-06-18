import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ScanRecord {
  final String? id;
  final String imagePath;
  final String plantName;
  final String? imageUrl;
  final String confidence;
  final String status;
  final DateTime scanTime;
  final String? diseaseName;
  final String? description;
  final String? treatment;

  ScanRecord({
    this.id,
    required this.imagePath,
    required this.plantName,
    required this.confidence,
    this.imageUrl,
    required this.status,
    required this.scanTime,
    this.diseaseName,
    this.description,
    this.treatment,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrl'] as List?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images.first as String : null;
    final decision = (json['finalDecision'] ?? '').toString().toLowerCase();
    final rawConf = json['averageConfidence'] ?? json['confidence'] ?? 0;
    final confidence = (rawConf is num)
        ? rawConf.toStringAsFixed(0) : rawConf.toString();
    DateTime scanTime;
    try {
      scanTime = DateTime.parse(json['createdAt'] as String);
    } catch (_) {
      scanTime = DateTime.now();
    }
    final results = json['results'] as List?;
    final firstResult = results?.isNotEmpty == true ? results!.first : null;
    return ScanRecord(
      id: json['_id'] as String?,
      imagePath: '',
      imageUrl: imageUrl,
      plantName: 'Lettuce',
      status: decision == 'healthy' ? 'Healthy' : 'Diseased',
      confidence: confidence,
      scanTime: scanTime,
      diseaseName: firstResult?['disease_name'] as String?,
      description: firstResult?['description'] as String?,
      treatment: firstResult?['treatment'] is List
          ? (firstResult!['treatment'] as List).join('|||')
          : firstResult?['treatment'] as String?,
    );
  }
}

class ScansState extends ChangeNotifier {
  final List<ScanRecord> _scans = [];

  List<ScanRecord> get scans => List.unmodifiable(_scans);

  void add(ScanRecord record) { _scans.add(record); notifyListeners(); }
  void remove(int index) { _scans.removeAt(index); notifyListeners(); }
  void clear() { _scans.clear(); notifyListeners(); }
  void setAll(List<ScanRecord> records) {
    _scans..clear()..addAll(records);
    notifyListeners();
  }

  int get length => _scans.length;
  bool get isEmpty => _scans.isEmpty;
  bool get isNotEmpty => _scans.isNotEmpty;
}

final scansState = ScansState();

Future<void> saveScans() async {
  final prefs = await SharedPreferences.getInstance();
  final list = scansState.scans.map((s) => {
    'id': s.id ?? '', 'imagePath': s.imagePath, 'imageUrl': s.imageUrl ?? '',
    'plantName': s.plantName, 'status': s.status, 'confidence': s.confidence,
    'scanTime': s.scanTime.toIso8601String(), 'diseaseName': s.diseaseName ?? '',
    'description': s.description ?? '', 'treatment': s.treatment ?? '',
  }).toList();
  await prefs.setString('recentScans', jsonEncode(list));
}

Future<void> loadScans() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('recentScans');
    if (data == null) return;
    final List decoded = jsonDecode(data);
    scansState.setAll(decoded.map((s) => ScanRecord(
      id: s['id'], imagePath: s['imagePath'] ?? '',
      imageUrl: s['imageUrl'], plantName: s['plantName'],
      confidence: s['confidence'] ?? '—', status: s['status'],
      scanTime: DateTime.parse(s['scanTime']),
      diseaseName: s['diseaseName'], description: s['description'],
      treatment: s['treatment'],
    )).toList());
  } catch (_) { scansState.clear(); }
}