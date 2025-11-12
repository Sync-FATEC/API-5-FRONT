import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/core/routing/role_router.dart';

void main() {
  group('Role redirect resolver', () {
    test('COORDENADOR_AGENDA vai para /appointments', () {
      expect(resolveRedirectRoute(Role.COORDENADOR_AGENDA), '/appointments');
    });

    test('PACIENTE vai para /appointments', () {
      expect(resolveRedirectRoute(Role.PACIENTE), '/appointments');
    });

    test('ADMIN vai para /users', () {
      expect(resolveRedirectRoute(Role.ADMIN), '/users');
    });

    test('SUPERVISOR vai para /home', () {
      expect(resolveRedirectRoute(Role.SUPERVISOR), '/home');
    });

    test('SOLDADO vai para /stock-selection', () {
      expect(resolveRedirectRoute(Role.SOLDADO), '/stock-selection');
    });

    test('roleFromString reconhece valores válidos', () {
      expect(roleFromString('admin'), Role.ADMIN);
      expect(roleFromString('SUPERVISOR'), Role.SUPERVISOR);
      expect(roleFromString('soldado'), Role.SOLDADO);
      expect(roleFromString('COORDENADOR_AGENDA'), Role.COORDENADOR_AGENDA);
      expect(roleFromString('paciente'), Role.PACIENTE);
    });

    test('roleFromString retorna null para valores inválidos', () {
      expect(roleFromString(null), isNull);
      expect(roleFromString(''), isNull);
      expect(roleFromString('DESCONHECIDO'), isNull);
    });

    test('resolveRedirectRoute retorna null para role null', () {
      expect(resolveRedirectRoute(null), isNull);
    });
  });
}

