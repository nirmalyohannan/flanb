import 'dart:io';

class NetworkInterfaceInfo {
  final String interfaceName;
  final String ipAddress;

  NetworkInterfaceInfo({required this.interfaceName, required this.ipAddress});

  @override
  String toString() => '$interfaceName ($ipAddress)';
}

class NetworkUtils {
  /// Resolves private local IPv4 addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x).
  /// Prioritizes standard 192.168.x.x Wi-Fi router addresses FIRST so they are used
  /// for QR code rendering and local server primary URL output.
  static Future<List<NetworkInterfaceInfo>> getLanIps() async {
    final List<NetworkInterfaceInfo> results = [];

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final ip = addr.address;
          if (_isPrivateIPv4(ip)) {
            results.add(NetworkInterfaceInfo(
              interfaceName: interface.name,
              ipAddress: ip,
            ));
          }
        }
      }
    } catch (_) {}

    results.sort(_compareIpPriority);

    return results;
  }

  /// Prioritizes 192.168.x.x IPs first, followed by physical interfaces before virtual ones (utun, docker, etc.).
  static int _compareIpPriority(NetworkInterfaceInfo a, NetworkInterfaceInfo b) {
    final aIs192 = a.ipAddress.startsWith('192.168.');
    final bIs192 = b.ipAddress.startsWith('192.168.');

    if (aIs192 && !bIs192) return -1;
    if (!aIs192 && bIs192) return 1;

    final aName = a.interfaceName.toLowerCase();
    final bName = b.interfaceName.toLowerCase();

    final aIsVirtual = aName.startsWith('utun') ||
        aName.startsWith('docker') ||
        aName.startsWith('veth') ||
        aName.startsWith('vbox');
    final bIsVirtual = bName.startsWith('utun') ||
        bName.startsWith('docker') ||
        bName.startsWith('veth') ||
        bName.startsWith('vbox');

    if (!aIsVirtual && bIsVirtual) return -1;
    if (aIsVirtual && !bIsVirtual) return 1;

    return a.ipAddress.compareTo(b.ipAddress);
  }

  /// Checks if an IP address belongs to standard private IPv4 ranges.
  static bool _isPrivateIPv4(String ip) {
    if (ip == '127.0.0.1' || ip.startsWith('169.254.')) return false;

    final parts = ip.split('.').map(int.tryParse).toList();
    if (parts.length != 4 || parts.any((p) => p == null)) return false;

    final p0 = parts[0]!;
    final p1 = parts[1]!;

    // 10.0.0.0 - 10.255.255.255
    if (p0 == 10) return true;

    // 172.16.0.0 - 172.31.255.255
    if (p0 == 172 && p1 >= 16 && p1 <= 31) return true;

    // 192.168.0.0 - 192.168.255.255
    if (p0 == 192 && p1 == 168) return true;

    return false;
  }

  /// Attempts to find an available port starting at [preferredPort].
  static Future<int> findAvailablePort(int preferredPort) async {
    for (int port = preferredPort; port < preferredPort + 50; port++) {
      try {
        final socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        await socket.close();
        return port;
      } catch (_) {
        // Port is occupied, try next
      }
    }
    return preferredPort;
  }
}
