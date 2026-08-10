enum TunnelProvider {
  none(
    displayName: 'No Tunnel (Local LAN Server only)',
    executableName: null,
    installHint: null,
  ),
  cloudflared(
    displayName: 'Cloudflare Tunnel (cloudflared)',
    executableName: 'cloudflared',
    installHint: 'brew install cloudflared',
  ),
  ngrok(
    displayName: 'ngrok Tunnel (ngrok)',
    executableName: 'ngrok',
    installHint: 'brew install ngrok',
  ),
  localtunnel(
    displayName: 'Localtunnel (lt)',
    executableName: 'lt',
    installHint: 'npm install -g localtunnel',
  ),
  localhostRun(
    displayName: 'SSH Tunnel (localhost.run)',
    executableName: 'ssh',
    installHint: 'Pre-installed (ssh)',
  );

  final String displayName;
  final String? executableName;
  final String? installHint;

  const TunnelProvider({
    required this.displayName,
    this.executableName,
    this.installHint,
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
