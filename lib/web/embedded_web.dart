const String embeddedWebHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FLANB — Flutter LAN Build</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-main: #090d16;
      --card-bg: rgba(15, 23, 42, 0.85);
      --border-color: rgba(255, 255, 255, 0.08);
      --text-main: #f8fafc;
      --text-muted: #64748b;
      --accent-blue: #38bdf8;
      --accent-indigo: #818cf8;
      --success-green: #22c55e;
      --error-red: #ef4444;
      --warning-amber: #f59e0b;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    html, body {
      height: 100%;
      width: 100%;
      overflow: hidden;
      font-family: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
      background: var(--bg-main);
      color: var(--text-main);
    }

    .app-viewport {
      display: flex;
      flex-direction: column;
      height: 100vh;
      width: 100vw;
    }

    /* Compact Floating Appbar */
    .floating-appbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.55rem 1.25rem;
      background: var(--card-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border-bottom: 1px solid var(--border-color);
      z-index: 100;
      gap: 0.75rem;
      flex-shrink: 0;
      flex-wrap: wrap;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 0.6rem;
      flex-shrink: 0;
    }

    .brand-logo {
      width: 32px;
      height: 32px;
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-indigo));
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 1rem;
      color: #fff;
      box-shadow: 0 2px 10px rgba(56, 189, 248, 0.3);
    }

    .brand-text {
      display: flex;
      flex-direction: column;
    }

    .brand-title {
      font-size: 1.15rem;
      font-weight: 700;
      background: linear-gradient(90deg, #38bdf8, #818cf8);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      line-height: 1.1;
    }

    .brand-watermark {
      font-size: 0.68rem;
      color: var(--text-muted);
      font-weight: 500;
      letter-spacing: 0.03em;
    }

    .meta-pills {
      display: flex;
      align-items: center;
      gap: 0.4rem;
      flex-wrap: wrap;
    }

    .pill {
      display: inline-flex;
      align-items: center;
      gap: 0.3rem;
      background: rgba(255, 255, 255, 0.04);
      border: 1px solid var(--border-color);
      padding: 0.25rem 0.6rem;
      border-radius: 6px;
      font-size: 0.78rem;
    }

    .pill-label {
      color: var(--text-muted);
      font-size: 0.68rem;
      text-transform: uppercase;
      font-weight: 600;
    }

    .pill-val {
      font-weight: 600;
      color: #e2e8f0;
    }

    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      padding: 0.3rem 0.75rem;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .status-building {
      background: rgba(245, 158, 11, 0.15);
      color: var(--warning-amber);
      border: 1px solid rgba(245, 158, 11, 0.3);
    }

    .status-success, .status-serving {
      background: rgba(34, 197, 94, 0.15);
      color: var(--success-green);
      border: 1px solid rgba(34, 197, 94, 0.3);
    }

    .status-failed {
      background: rgba(239, 68, 68, 0.15);
      color: var(--error-red);
      border: 1px solid rgba(239, 68, 68, 0.3);
    }

    .pulse-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: currentColor;
      animation: pulse 1.5s infinite ease-in-out;
    }

    @keyframes pulse {
      0%, 100% { opacity: 0.3; transform: scale(0.8); }
      50% { opacity: 1; transform: scale(1.2); }
    }

    /* Download Banner */
    .download-banner {
      background: linear-gradient(90deg, rgba(34, 197, 94, 0.15), rgba(56, 189, 248, 0.15));
      border-bottom: 1px solid rgba(34, 197, 94, 0.3);
      padding: 0.5rem 1.25rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      flex-shrink: 0;
    }

    .download-title {
      font-size: 0.88rem;
      font-weight: 600;
      color: #fff;
    }

    .download-sub {
      font-size: 0.75rem;
      color: #94a3b8;
    }

    .download-btn {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      background: linear-gradient(135deg, #22c55e, #16a34a);
      color: #ffffff;
      font-size: 0.85rem;
      font-weight: 700;
      padding: 0.4rem 1.1rem;
      border-radius: 8px;
      text-decoration: none;
      box-shadow: 0 2px 12px rgba(34, 197, 94, 0.3);
      transition: all 0.2s ease;
      white-space: nowrap;
    }

    .download-btn:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 16px rgba(34, 197, 94, 0.5);
    }

    /* Full Body Console */
    .console-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      background: #060911;
      overflow: hidden;
    }

    .console-toolbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.4rem 1.25rem;
      background: #0f172a;
      border-bottom: 1px solid rgba(255, 255, 255, 0.05);
      font-size: 0.75rem;
      color: var(--text-muted);
    }

    .console-controls {
      display: flex;
      gap: 0.5rem;
    }

    .btn-small {
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid var(--border-color);
      color: #94a3b8;
      font-size: 0.72rem;
      padding: 0.2rem 0.55rem;
      border-radius: 5px;
      cursor: pointer;
      transition: background 0.2s;
    }

    .btn-small:hover {
      background: rgba(255, 255, 255, 0.12);
      color: #f8fafc;
    }

    .console-body {
      flex: 1;
      padding: 0.9rem 1.25rem;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.83rem;
      line-height: 1.55;
      color: #cbd5e1;
      overflow-y: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }

    .log-line-err { color: var(--error-red); }
    .log-line-success { color: var(--success-green); }

    @media (max-width: 768px) {
      .floating-appbar {
        padding: 0.5rem 0.75rem;
      }
      .meta-pills {
        font-size: 0.72rem;
      }
      .download-banner {
        flex-direction: column;
        align-items: flex-start;
      }
    }
  </style>
</head>
<body>
  <div class="app-viewport">
    <!-- Compact Floating Appbar -->
    <header class="floating-appbar">
      <div class="brand">
        <div class="brand-logo">⚡</div>
        <div class="brand-text">
          <div class="brand-title">FLANB</div>
          <div class="brand-watermark">by Nirmal Yohannan</div>
        </div>
      </div>

      <div class="meta-pills">
        <div class="pill">
          <span class="pill-label">Project</span>
          <span id="metaProject" class="pill-val">-</span>
        </div>
        <div class="pill">
          <span class="pill-label">Version</span>
          <span id="metaVersion" class="pill-val">-</span>
        </div>
        <div class="pill">
          <span class="pill-label">Flavor</span>
          <span id="metaFlavor" class="pill-val">default</span>
        </div>
        <div class="pill">
          <span class="pill-label">Entry</span>
          <span id="metaEntry" class="pill-val">lib/main.dart</span>
        </div>
        <div class="pill">
          <span class="pill-label">Mode</span>
          <span id="metaMode" class="pill-val">RELEASE</span>
        </div>
      </div>

      <div id="statusBadge" class="status-badge status-building">
        <div class="pulse-dot"></div>
        <span id="statusText">Initialising...</span>
      </div>
    </header>

    <!-- Download Banner (visible when build succeeds) -->
    <div id="downloadBanner" class="download-banner" style="display: none;">
      <div>
        <div class="download-title">Build Completed Successfully</div>
        <div id="apkMetadata" class="download-sub">Ready for installation on local Android devices</div>
      </div>
      <a id="downloadBtn" href="/download" class="download-btn">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Download APK
      </a>
    </div>

    <!-- Full Body Console -->
    <main class="console-container">
      <div class="console-toolbar">
        <div>LIVE BUILD CONSOLE</div>
        <div class="console-controls">
          <button id="clearLogsBtn" class="btn-small">Clear</button>
          <button id="autoScrollBtn" class="btn-small">Auto-scroll: ON</button>
        </div>
      </div>
      <div id="consoleBody" class="console-body"></div>
    </main>
  </div>

  <script>
    let autoScroll = true;
    const consoleBody = document.getElementById('consoleBody');
    const autoScrollBtn = document.getElementById('autoScrollBtn');
    const clearLogsBtn = document.getElementById('clearLogsBtn');
    const downloadBanner = document.getElementById('downloadBanner');
    const statusBadge = document.getElementById('statusBadge');
    const statusText = document.getElementById('statusText');

    const receivedLogs = new Set();

    autoScrollBtn.addEventListener('click', () => {
      autoScroll = !autoScroll;
      autoScrollBtn.textContent = `Auto-scroll: \${autoScroll ? 'ON' : 'OFF'}`;
    });

    clearLogsBtn.addEventListener('click', () => {
      consoleBody.textContent = '';
      receivedLogs.clear();
    });

    function appendLog(text) {
      if (!text) return;
      if (receivedLogs.has(text)) return;
      receivedLogs.add(text);

      const line = document.createElement('div');
      if (text.startsWith('[ERR]') || text.toLowerCase().includes('failed') || text.toLowerCase().includes('error')) {
        line.className = 'log-line-err';
      } else if (text.includes('✓') || text.includes('SUCCESS') || text.includes('finished successfully')) {
        line.className = 'log-line-success';
      }
      line.textContent = text;
      consoleBody.appendChild(line);
      if (autoScroll) {
        consoleBody.scrollTop = consoleBody.scrollHeight;
      }
    }

    function updateStatus(data) {
      if (data.projectName) document.getElementById('metaProject').textContent = data.projectName;
      if (data.projectVersion) document.getElementById('metaVersion').textContent = data.projectVersion;
      if (data.flavor) document.getElementById('metaFlavor').textContent = data.flavor;
      if (data.entryPoint) document.getElementById('metaEntry').textContent = data.entryPoint;
      if (data.mode) document.getElementById('metaMode').textContent = data.mode.toUpperCase();

      const status = (data.status || '').toLowerCase();

      statusBadge.className = 'status-badge ';
      if (status === 'building') {
        statusBadge.classList.add('status-building');
        statusText.textContent = 'Building...';
      } else if (status === 'success' || status === 'serving') {
        statusBadge.classList.add('status-success');
        statusText.textContent = 'Ready';
        if (data.apkAvailable) {
          downloadBanner.style.display = 'flex';
          const sizeMB = data.apkSize ? (data.apkSize / (1024 * 1024)).toFixed(1) + ' MB' : '';
          document.getElementById('apkMetadata').textContent = `File: \${data.apkName || 'app.apk'} \${sizeMB ? '• ' + sizeMB : ''}`;
        }
      } else if (status === 'failed') {
        statusBadge.classList.add('status-failed');
        statusText.textContent = 'Build Failed';
      } else {
        statusBadge.classList.add('status-building');
        statusText.textContent = status;
      }
    }

    // 1. Fetch initial log history via REST API
    async function fetchLogHistory() {
      try {
        const res = await fetch('/api/logs');
        if (res.ok) {
          const logs = await res.json();
          if (Array.isArray(logs)) {
            logs.forEach(appendLog);
          }
        }
      } catch (e) {
        console.error('Failed to fetch log history:', e);
      }
    }

    // 2. Connect Server-Sent Events (SSE) for live stream
    function connectSse() {
      const eventSource = new EventSource('/logs');
      eventSource.onmessage = (event) => {
        if (event.data) {
          appendLog(event.data);
        }
      };
    }

    // 3. Poll status periodically
    async function fetchStatus() {
      try {
        const res = await fetch('/status');
        if (res.ok) {
          const data = await res.json();
          updateStatus(data);
        }
      } catch (e) {}
    }

    // Initialize
    fetchLogHistory();
    connectSse();
    fetchStatus();
    setInterval(fetchStatus, 2000);
    setInterval(fetchLogHistory, 4000);
  </script>
</body>
</html>
''';
