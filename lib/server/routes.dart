import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../build/build_config.dart';
import '../build/build_manager.dart';
import '../web/embedded_web.dart';
import 'log_stream.dart';

class FlanbRoutes {
  final String projectName;
  final BuildConfig buildConfig;
  final BuildManager buildManager;
  final LogManager logManager;
  final File? Function() getApkFile;

  FlanbRoutes({
    required this.projectName,
    required this.buildConfig,
    required this.buildManager,
    required this.logManager,
    required this.getApkFile,
  });

  Router get router {
    final app = Router();

    // Serve web dashboard HTML
    app.get('/', (Request request) {
      return Response.ok(
        embeddedWebHtml,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    // Serve JSON build status
    app.get('/status', (Request request) {
      final apkFile = getApkFile();
      final apkExists = apkFile != null && apkFile.existsSync();

      final data = {
        'status': buildManager.status.name,
        'projectName': projectName,
        'flavor': buildConfig.flavor ?? 'default',
        'entryPoint': buildConfig.entryPoint,
        'mode': buildConfig.mode.name,
        'apkAvailable': apkExists,
        'apkName': apkExists ? p.basename(apkFile.path) : null,
        'apkSize': apkExists ? apkFile.lengthSync() : null,
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

    // Stream APK file download
    app.get('/download', (Request request) {
      final apkFile = getApkFile();

      if (apkFile == null || !apkFile.existsSync()) {
        return Response.notFound(
          'APK file not found. Make sure the build succeeded.',
        );
      }

      final fileName = p.basename(apkFile.path);
      final fileSize = apkFile.lengthSync();

      return Response.ok(
        apkFile.openRead(),
        headers: {
          'content-type': 'application/vnd.android.package-archive',
          'content-disposition': 'attachment; filename="$fileName"',
          'content-length': fileSize.toString(),
        },
      );
    });

    return app;
  }
}
