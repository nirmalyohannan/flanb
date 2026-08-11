import 'package:flanb/server/network.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkUtils IP Prioritization Tests', () {
    test('getLanIps returns sorted IP list with 192.168.x.x prioritized first', () async {
      final ips = await NetworkUtils.getLanIps();
      if (ips.length > 1) {
        final has192 = ips.any((info) => info.ipAddress.startsWith('192.168.'));
        if (has192) {
          expect(ips.first.ipAddress.startsWith('192.168.'), isTrue,
              reason: 'First LAN IP should start with 192.168. if available');
        }
      }
    });
  });
}
