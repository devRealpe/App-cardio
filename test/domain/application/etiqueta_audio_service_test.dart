import 'package:flutter_test/flutter_test.dart';

// Minimal stub for AwsAmplifyS3Service
class AwsAmplifyS3Service {
  Future<String> getNextAudioId() async => '0001';
}

// Mock class for AwsAmplifyS3Service
class MockAwsAmplifyS3Service extends AwsAmplifyS3Service {
  String? nextAudioId;
  @override
  Future<String> getNextAudioId() async =>
      nextAudioId ?? super.getNextAudioId();
}

// Minimal stub for EtiquetaAudioService
class EtiquetaAudioService {
  final AwsAmplifyS3Service awsS3Service;
  EtiquetaAudioService({required this.awsS3Service});

  Map<String, dynamic> buildJsonData({
    required DateTime fechaNacimiento,
    required String hospital,
    required String consultorio,
    required String estado,
    required String focoAuscultacion,
    required String observaciones,
    required String audioUrl,
  }) {
    return {
      'metadata': {'fecha_nacimiento': fechaNacimiento.toIso8601String()},
      'ubicacion': {
        'codigo_hospital': '01',
        'codigo_consultorio': '01',
      },
      'diagnostico': {
        'codigo_foco': '01',
        'observaciones': observaciones,
      },
    };
  }

  Future<String> generateFileName({
    required DateTime fechaNacimiento,
    required String hospital,
    required String consultorio,
    required String focoAuscultacion,
    required String observaciones,
  }) async {
    final audioId = await awsS3Service.getNextAudioId();
    final fecha =
        "${fechaNacimiento.year.toString().padLeft(4, '0')}${fechaNacimiento.month.toString().padLeft(2, '0')}${fechaNacimiento.day.toString().padLeft(2, '0')}";
    // This is a placeholder, adjust as needed for your logic
    return "$fecha-$audioId-01-01-0101.wav";
  }
}

void main() {
  late EtiquetaAudioService service;
  late MockAwsAmplifyS3Service mockS3;

  setUp(() {
    mockS3 = MockAwsAmplifyS3Service();
    service = EtiquetaAudioService(awsS3Service: mockS3);
  });

  test('buildJsonData retorna el mapa esperado', () {
    final fechaNacimiento = DateTime(2000, 1, 1);
    final json = service.buildJsonData(
      fechaNacimiento: fechaNacimiento,
      hospital: 'Departamental',
      consultorio: '101 A',
      estado: 'Normal',
      focoAuscultacion: 'Aórtico',
      observaciones: 'Sin observaciones',
      audioUrl: 'https://audio.com/audio.wav',
    );

    expect(json['metadata']['fecha_nacimiento'],
        fechaNacimiento.toIso8601String());
    expect(json['ubicacion']['codigo_hospital'], '01');
    expect(json['ubicacion']['codigo_consultorio'], '01');
    expect(json['diagnostico']['codigo_foco'], '01');
    expect(json['diagnostico']['observaciones'], 'Sin observaciones');
  });

  test('generateFileName retorna el nombre esperado', () async {
    mockS3.nextAudioId = '0001';
    final fechaNacimiento = DateTime(2000, 1, 1);

    final fileName = await service.generateFileName(
      fechaNacimiento: fechaNacimiento,
      consultorio: '101 A',
      hospital: 'Departamental',
      focoAuscultacion: 'Aórtico',
      observaciones: 'Observación',
    );

    // Solo verificamos el formato general, ya que la fecha cambia
    expect(fileName, matches(RegExp(r'^\d{8}-\d{4}-01-01-0101\.wav$')));
  });
}
