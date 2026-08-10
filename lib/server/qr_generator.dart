import 'package:qr/qr.dart';

class QrGenerator {
  /// Renders a UTF-8 ANSI string representation of a QR code for terminal output.
  static String renderTerminalQr(String data) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );
      final qrImage = QrImage(qrCode);
      final count = qrImage.moduleCount;
      final buffer = StringBuffer();

      // White quiet zone margin
      final margin = '  ' * (count + 4);
      buffer.writeln(margin);

      for (int r = 0; r < count; r += 2) {
        buffer.write('    '); // Left padding
        for (int c = 0; c < count; c++) {
          final top = qrImage.isDark(r, c);
          final bottom = (r + 1 < count) ? qrImage.isDark(r + 1, c) : false;

          if (top && bottom) {
            buffer.write('█');
          } else if (top && !bottom) {
            buffer.write('▀');
          } else if (!top && bottom) {
            buffer.write('▄');
          } else {
            buffer.write(' ');
          }
        }
        buffer.writeln();
      }

      buffer.writeln(margin);
      return buffer.toString();
    } catch (e) {
      return '';
    }
  }

  /// Renders an SVG image representation of a QR code for the web UI.
  static String renderSvgQr(String data) {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );
      final qrImage = QrImage(qrCode);
      final count = qrImage.moduleCount;
      final buffer = StringBuffer();

      buffer.write(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-2 -2 ${count + 4} ${count + 4}" shape-rendering="crispEdges">',
      );
      buffer.write(
        '<rect x="-2" y="-2" width="${count + 4}" height="${count + 4}" fill="#ffffff" rx="2"/>',
      );

      for (int r = 0; r < count; r++) {
        for (int c = 0; c < count; c++) {
          if (qrImage.isDark(r, c)) {
            buffer.write(
              '<rect x="$c" y="$r" width="1" height="1" fill="#090d16"/>',
            );
          }
        }
      }
      buffer.write('</svg>');
      return buffer.toString();
    } catch (e) {
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><text x="10" y="50" fill="#red">QR Error</text></svg>';
    }
  }
}
