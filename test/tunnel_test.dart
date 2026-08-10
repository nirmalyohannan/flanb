import 'package:flanb/tunnel/tunnel_provider.dart';
import 'package:flanb/tunnel/tunnel_service.dart';
import 'package:test/test.dart';

void main() {
  group('TunnelProvider Tests', () {
    test('TunnelProvider.fromString maps correctly', () {
      expect(TunnelProvider.fromString('cloudflared'), TunnelProvider.cloudflared);
      expect(TunnelProvider.fromString('cloudflare'), TunnelProvider.cloudflared);
      expect(TunnelProvider.fromString('ngrok'), TunnelProvider.ngrok);
      expect(TunnelProvider.fromString('localtunnel'), TunnelProvider.localtunnel);
      expect(TunnelProvider.fromString('lt'), TunnelProvider.localtunnel);
      expect(TunnelProvider.fromString('ssh'), TunnelProvider.localhostRun);
      expect(TunnelProvider.fromString('localhost.run'), TunnelProvider.localhostRun);
      expect(TunnelProvider.fromString('none'), TunnelProvider.none);
      expect(TunnelProvider.fromString('invalid'), TunnelProvider.none);
    });
  });

  group('Tunnel URL Extraction Tests', () {
    test('Extracts Cloudflare Tunnel URL correctly', () {
      const line = '2026-08-10T18:00:00Z INF +--------------------------------------------------------------------------------------------+';
      const line3 = '2026-08-10T18:00:00Z INF |  https://random-words-123.trycloudflare.com                                                |';

      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.cloudflared, line3),
        'https://random-words-123.trycloudflare.com',
      );
      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.cloudflared, line),
        isNull,
      );
    });

    test('Extracts ngrok Tunnel URL correctly', () {
      const line = 'Forwarding                    https://abc-123.ngrok-free.app -> http://localhost:8080';
      const line2 = 'Forwarding                    https://xyz.ngrok.io -> http://localhost:8080';

      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.ngrok, line),
        'https://abc-123.ngrok-free.app',
      );
      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.ngrok, line2),
        'https://xyz.ngrok.io',
      );
    });

    test('Extracts Localtunnel URL correctly', () {
      const line = 'your url is: https://funny-cat-42.loca.lt';

      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.localtunnel, line),
        'https://funny-cat-42.loca.lt',
      );
    });

    test('Extracts SSH localhost.run URL correctly', () {
      const line = '9a1b2c3d.lhr.life tunnelled to https://9a1b2c3d.lhr.life';

      expect(
        TunnelService.extractUrlFromLine(TunnelProvider.localhostRun, line),
        'https://9a1b2c3d.lhr.life',
      );
    });
  });
}
