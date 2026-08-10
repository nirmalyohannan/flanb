enum TunnelProvider {
  none(
    displayName: 'No Tunnel (Local LAN Server only)',
    executableName: null,
  ),
  cloudflared(
    displayName: 'Cloudflare Tunnel (cloudflared)',
    executableName: 'cloudflared',
  ),
  ngrok(
    displayName: 'ngrok Tunnel (ngrok)',
    executableName: 'ngrok',
  ),
  localtunnel(
    displayName: 'Localtunnel (lt)',
    executableName: 'lt',
  ),
  localhostRun(
    displayName: 'SSH Tunnel (localhost.run)',
    executableName: 'ssh',
  );

  final String displayName;
  final String? executableName;

  const TunnelProvider({
    required this.displayName,
    this.executableName,
  });

  static TunnelProvider fromString(String val) {
    final clean = val.trim().toLowerCase();
    switch (clean) {
      case 'cloudflared':
      case 'cloudflare':
        return TunnelProvider.cloudflared;
      case 'ngrok':
        return TunnelProvider.ngrok;
      case 'localtunnel':
      case 'lt':
        return TunnelProvider.localtunnel;
      case 'localhostrun':
      case 'ssh':
      case 'localhost.run':
        return TunnelProvider.localhostRun;
      case 'none':
      case 'false':
      default:
        return TunnelProvider.none;
    }
  }
}
