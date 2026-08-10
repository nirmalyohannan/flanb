import 'package:flanb/server/routes.dart';
import 'package:test/test.dart';

void main() {
  group('FlanbRoutes Content-Disposition Tests', () {
    test('buildContentDisposition formats standard ASCII filename correctly', () {
      const fileName = 'app-release.apk';
      final header = FlanbRoutes.buildContentDisposition(fileName);

      expect(header, 'attachment; filename="app-release.apk"; filename*=UTF-8\'\'app-release.apk');
    });

    test('buildContentDisposition handles non-ASCII Unicode and non-breaking spaces safely', () {
      const fileName = 'Masthishka Maranam (2026) Malayalam\u00A0TRUE WEB-DL - 1080p.mkv';
      final header = FlanbRoutes.buildContentDisposition(fileName);

      expect(header, contains('attachment; filename="Masthishka Maranam (2026) Malayalam_TRUE WEB-DL - 1080p.mkv"; filename*=UTF-8\'\''));
      expect(header, contains('Masthishka%20Maranam%20(2026)%20Malayalam%C2%A0TRUE%20WEB-DL%20-%201080p.mkv'));

      // Verify header contains ONLY valid ASCII characters
      expect(RegExp(r'^[^\x00-\x1F\x7F-\xFF]+$').hasMatch(header), isTrue);
    });
  });
}
