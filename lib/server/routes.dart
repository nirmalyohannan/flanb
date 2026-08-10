import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../build/build_config.dart';
import '../build/build_manager.dart';
import '../web/embedded_web.dart';
import 'log_stream.dart';
import 'qr_generator.dart';

class FlanbRoutes {
  final String projectName;
  final String projectVersion;
  final BuildConfig buildConfig;
  final BuildManager buildManager;
  final LogManager logManager;
  final File? Function() getApkFile;
  final String? tunnelUrl;
  final String? primaryLanUrl;
  final File? customSharedFile;

  FlanbRoutes({
    required this.projectName,
    required this.projectVersion,
    required this.buildConfig,
    required this.buildManager,
    required this.logManager,
    required this.getApkFile,
    this.tunnelUrl,
    this.primaryLanUrl,
    this.customSharedFile,
  });

  /// Builds RFC 6266 / RFC 5987 compliant Content-Disposition header.
  /// Uses a safe ASCII fallback for older clients and URI percent-encoding
  /// (`filename*=UTF-8''...`) to safely support full UTF-8 & Unicode filenames.
  static String buildContentDisposition(String fileName) {
    final safeAsciiName = fileName
        .replaceAll('"', '_')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '_');
    final encodedUtf8Name = Uri.encodeComponent(fileName);
    return 'attachment; filename="$safeAsciiName"; filename*=UTF-8\'\'$encodedUtf8Name';
  }

  Router get router {
    final app = Router();

    // Serve web dashboard HTML
    app.get('/', (Request request) {
      return Response.ok(
        embeddedWebHtml,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    // Serve JSON build / file share status
    app.get('/status', (Request request) {
      if (customSharedFile != null && customSharedFile!.existsSync()) {
        final fileName = p.basename(customSharedFile!.path);
        final fileSize = customSharedFile!.lengthSync();

        final data = {
          'isFileSharing': true,
          'status': 'serving',
          'projectName': 'FLANB File Sharer',
          'projectVersion': '0.6.5',
          'fileName': fileName,
          'fileSize': fileSize,
          'apkAvailable': true,
          'apkName': fileName,
          'apkSize': fileSize,
          'tunnelUrl': tunnelUrl,
          'primaryLanUrl': primaryLanUrl,
          'serverMode': tunnelUrl != null && tunnelUrl!.isNotEmpty
              ? 'Public Tunnel'
              : 'Local LAN Server',
        };

        return Response.ok(
          jsonEncode(data),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      final apkFile = getApkFile();
      final apkExists = apkFile != null && apkFile.existsSync();

      final data = {
        'isFileSharing': false,
        'status': buildManager.status.name,
        'projectName': projectName,
        'projectVersion': projectVersion,
        'flavor': buildConfig.flavor ?? 'default',
        'entryPoint': buildConfig.entryPoint,
        'mode': buildConfig.mode.name,
        'apkAvailable': apkExists,
        'apkName': apkExists ? p.basename(apkFile.path) : null,
        'apkSize': apkExists ? apkFile.lengthSync() : null,
        'tunnelUrl': tunnelUrl,
        'primaryLanUrl': primaryLanUrl,
        'serverMode': tunnelUrl != null && tunnelUrl!.isNotEmpty
            ? 'Public Tunnel'
            : 'Local LAN Server',
      };

      return Response.ok(
        jsonEncode(data),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    // Serve all historical logs in JSON format
    app.get('/api/logs', (Request request) {
      return Response.ok(
        jsonEncode(logManager.history),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    // Serve SSE live build log stream (Stream<List<int>>)
    app.get('/logs', (Request request) {
      return Response.ok(
        logManager.sseByteStream,
        headers: {
          'content-type': 'text/event-stream; charset=utf-8',
          'cache-control': 'no-cache, no-transform',
          'connection': 'keep-alive',
          'x-accel-buffering': 'no',
        },
      );
    });

    // Serve SVG QR code for the given target URL (defaults to /download)
    app.get('/qr', (Request request) {
      final queryUrl = request.requestedUri.queryParameters['url'];
      String targetUrl;
      if (queryUrl != null && queryUrl.isNotEmpty) {
        targetUrl = queryUrl;
      } else if (tunnelUrl != null && tunnelUrl!.isNotEmpty) {
        targetUrl = '$tunnelUrl/download';
      } else if (primaryLanUrl != null && primaryLanUrl!.isNotEmpty) {
        targetUrl = '$primaryLanUrl/download';
      } else {
        targetUrl = request.requestedUri.resolve('/download').toString();
      }

      final svgContent = QrGenerator.renderSvgQr(targetUrl);

      return Response.ok(
        svgContent,
        headers: {'content-type': 'image/svg+xml; charset=utf-8'},
      );
    });

    // Stream APK or custom shared file download
    app.get('/download', (Request request) {
      final targetFile = customSharedFile ?? getApkFile();

      if (targetFile == null || !targetFile.existsSync()) {
        return Response.notFound(
          'File not found. Make sure the file exists or the build succeeded.',
        );
      }

      final fileName = p.basename(targetFile.path);
      final fileSize = targetFile.lengthSync();

      return Response.ok(
        targetFile.openRead(),
        headers: {
          'content-type': 'application/octet-stream',
          'content-disposition': buildContentDisposition(fileName),
          'content-length': fileSize.toString(),
        },
      );
    });

    return app;
  }
}
