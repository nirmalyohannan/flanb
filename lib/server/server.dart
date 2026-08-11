import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../build/build_config.dart';
import '../build/build_manager.dart';
import 'log_stream.dart';
import 'network.dart';
import 'routes.dart';

class LanServer {
  final String projectName;
  final String projectVersion;
  final BuildConfig buildConfig;
  final BuildManager buildManager;
  final LogManager logManager;
  final File? Function() getApkFile;
  final int requestedPort;
  String? tunnelUrl;
  String? primaryLanUrl;
  final File? customSharedFile;

  HttpServer? _server;
  int? _actualPort;

  LanServer({
    required this.projectName,
    required this.projectVersion,
    required this.buildConfig,
    required this.buildManager,
    required this.logManager,
    required this.getApkFile,
    this.requestedPort = 8080,
    this.tunnelUrl,
    this.primaryLanUrl,
    this.customSharedFile,
  });

  int get port => _actualPort ?? requestedPort;

  /// Starts the Shelf HTTP server bound to 0.0.0.0.
  Future<int> start() async {
    _actualPort = await NetworkUtils.findAvailablePort(requestedPort);

    if (primaryLanUrl == null || primaryLanUrl!.isEmpty) {
      final lanIps = await NetworkUtils.getLanIps();
      if (lanIps.isNotEmpty) {
        primaryLanUrl = 'http://${lanIps.first.ipAddress}:$_actualPort';
      } else {
        primaryLanUrl = 'http://localhost:$_actualPort';
      }
    }

    final routes = FlanbRoutes(
      projectName: projectName,
      projectVersion: projectVersion,
      buildConfig: buildConfig,
      buildManager: buildManager,
      logManager: logManager,
      getApkFile: getApkFile,
      getTunnelUrl: () => tunnelUrl,
      getPrimaryLanUrl: () => primaryLanUrl,
      customSharedFile: customSharedFile,
    );

    // CORS & quiet pipeline without logRequests() to avoid terminal bloat from web polling
    final pipeline = const Pipeline()
        .addMiddleware((innerHandler) {
          return (request) async {
            if (request.method == 'OPTIONS') {
              return Response.ok('', headers: {
                'access-control-allow-origin': '*',
                'access-control-allow-methods': 'GET, POST, OPTIONS',
                'access-control-allow-headers': '*',
              });
            }
            final response = await innerHandler(request);
            return response.change(headers: {
              'access-control-allow-origin': '*',
              'access-control-allow-methods': 'GET, POST, OPTIONS',
              'access-control-allow-headers': '*',
            });
          };
        })
        .addHandler(routes.router.call);

    _server = await shelf_io.serve(
      pipeline,
      InternetAddress.anyIPv4,
      _actualPort!,
    );

    return _actualPort!;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
