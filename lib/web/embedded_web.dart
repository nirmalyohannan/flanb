const String embeddedWebHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FLANB — Flutter LAN Build</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-main: #030712;
      --appbar-bg: rgba(8, 12, 22, 0.92);
      --border-color: rgba(255, 255, 255, 0.06);
      --text-main: #f1f5f9;
      --text-muted: #475569;
      --accent-blue: #38bdf8;
      --accent-violet: #a855f7;
      --success-green: #10b981;
      --error-red: #f43f5e;
      --warning-amber: #f59e0b;
      --console-bg: #010308;
      --toolbar-bg: #070c18;
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

    /* Compact Floating Appbar - Super Dark Glassmorphism */
    .floating-appbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.5rem 1.25rem;
      background: var(--appbar-bg);
      backdrop-filter: blur(20px);
      -webkit-backdrop-filter: blur(20px);
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
      width: 30px;
      height: 30px;
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-violet));
      border-radius: 7px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 0.95rem;
      color: #fff;
      box-shadow: 0 0 12px rgba(56, 189, 248, 0.4);
    }

    .brand-text {
      display: flex;
      flex-direction: column;
    }

    .brand-title {
      font-size: 1.1rem;
      font-weight: 700;
      background: linear-gradient(90deg, #38bdf8, #a855f7);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      line-height: 1.1;
    }

    .brand-watermark {
      font-size: 0.65rem;
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
      background: rgba(255, 255, 255, 0.02);
      border: 1px solid var(--border-color);
      padding: 0.2rem 0.55rem;
      border-radius: 6px;
      font-size: 0.75rem;
    }

    .pill-label {
      color: var(--text-muted);
      font-size: 0.65rem;
      text-transform: uppercase;
      font-weight: 600;
    }

    .pill-val {
      font-weight: 600;
      color: #cbd5e1;
    }

    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      padding: 0.28rem 0.7rem;
      border-radius: 20px;
      font-size: 0.72rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .status-building {
      background: rgba(245, 158, 11, 0.12);
      color: var(--warning-amber);
      border: 1px solid rgba(245, 158, 11, 0.25);
    }

    .status-success, .status-serving {
      background: rgba(16, 185, 129, 0.12);
      color: var(--success-green);
      border: 1px solid rgba(16, 185, 129, 0.25);
    }

    .status-failed {
      background: rgba(244, 63, 94, 0.12);
      color: var(--error-red);
      border: 1px solid rgba(244, 63, 94, 0.25);
    }

    .pulse-dot {
      width: 6px;
      height: 6px;
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
      background: linear-gradient(90deg, rgba(16, 185, 129, 0.12), rgba(56, 189, 248, 0.12));
      border-bottom: 1px solid rgba(16, 185, 129, 0.25);
      padding: 0.45rem 1.25rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      flex-shrink: 0;
    }

    .download-title {
      font-size: 0.85rem;
      font-weight: 600;
      color: #fff;
    }

    .download-sub {
      font-size: 0.72rem;
      color: #64748b;
    }

    .download-actions {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .download-btn {
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      background: linear-gradient(135deg, #10b981, #059669);
      color: #ffffff;
      font-size: 0.82rem;
      font-weight: 700;
      padding: 0.35rem 1rem;
      border-radius: 7px;
      text-decoration: none;
      box-shadow: 0 2px 10px rgba(16, 185, 129, 0.3);
      transition: all 0.2s ease;
      white-space: nowrap;
      border: none;
      cursor: pointer;
    }

    .download-btn:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 14px rgba(16, 185, 129, 0.5);
    }

    .qr-btn {
      background: linear-gradient(135deg, #38bdf8, #0284c7);
      box-shadow: 0 2px 10px rgba(56, 189, 248, 0.3);
    }

    .qr-btn:hover {
      box-shadow: 0 4px 14px rgba(56, 189, 248, 0.5);
    }

    /* QR Code Modal Overlay */
    .qr-modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background: rgba(3, 7, 18, 0.85);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      z-index: 1000;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .qr-modal-card {
      background: #0b0f19;
      border: 1px solid var(--border-color);
      border-radius: 16px;
      padding: 1.25rem;
      max-width: 320px;
      width: 90%;
      box-shadow: 0 20px 40px rgba(0,0,0,0.6);
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .qr-modal-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .qr-image-container {
      padding: 0.75rem;
      background: #ffffff;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .qr-image-container img {
      width: 200px;
      height: 200px;
    }

    /* Full Body Console — Super Dark */
    .console-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      background: var(--console-bg);
      overflow: hidden;
    }

    .console-toolbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.35rem 1.25rem;
      background: var(--toolbar-bg);
      border-bottom: 1px solid var(--border-color);
      font-size: 0.72rem;
      color: var(--text-muted);
      letter-spacing: 0.05em;
      font-weight: 600;
    }

    .console-controls {
      display: flex;
      align-items: center;
      gap: 0.4rem;
    }

    .btn-small {
      background: rgba(255, 255, 255, 0.03);
      border: 1px solid var(--border-color);
      color: #64748b;
      font-size: 0.7rem;
      padding: 0.18rem 0.5rem;
      border-radius: 4px;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-small:hover {
      background: rgba(255, 255, 255, 0.08);
      color: #f1f5f9;
    }

    .console-body {
      flex: 1;
      padding: 0.85rem 1.25rem;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.82rem;
      line-height: 1.55;
      color: #94a3b8;
      overflow-y: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }

    /* Blinking Thick Block Cursor */
    .console-cursor {
      display: inline-block;
      width: 8px;
      height: 1.15em;
      background-color: var(--accent-blue);
      vertical-align: text-bottom;
      margin-left: 2px;
      box-shadow: 0 0 6px rgba(56, 189, 248, 0.8);
      animation: blink 1s step-end infinite;
    }

    @keyframes blink {
      0%, 100% { opacity: 1; }
      50% { opacity: 0; }
    }

    .log-line-err { color: var(--error-red); }
    .log-line-success { color: var(--success-green); }

    @media (max-width: 768px) {
      .floating-appbar {
        padding: 0.4rem 0.65rem;
      }
      .meta-pills {
        font-size: 0.7rem;
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
      <div class="download-actions">
        <button id="qrModalBtn" class="download-btn qr-btn">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
          QR Code
        </button>
        <a id="downloadBtn" href="/download" class="download-btn">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Download APK
        </a>
      </div>
    </div>

    <!-- QR Code Modal Popup -->
    <div id="qrModal" class="qr-modal-overlay" style="display: none;">
      <div class="qr-modal-card">
        <div class="qr-modal-header">
          <div style="font-weight: 700; font-size: 0.95rem; color: #fff;">Scan to Download APK</div>
          <button id="closeQrModalBtn" class="btn-small">✕</button>
        </div>
        <div class="qr-image-container">
          <img id="qrImage" src="/qr" alt="Download APK QR Code" />
        </div>
        <div style="font-size: 0.72rem; color: #64748b; text-align: center;">Scan with your mobile camera connected to the same Wi-Fi</div>
      </div>
    </div>

    <!-- Full Body Console with Blinking Cursor -->
    <main class="console-container">
      <div class="console-toolbar">
        <div>LIVE BUILD CONSOLE</div>
        <div class="console-controls">
          <button id="notifyBtn" class="btn-small">🔔 Enable Notifications</button>
          <button id="clearLogsBtn" class="btn-small">Clear</button>
          <button id="autoScrollBtn" class="btn-small">Auto-scroll: ON</button>
        </div>
      </div>
      <div id="consoleBody" class="console-body">
        <span id="logLines"></span><span class="console-cursor"></span>
      </div>
    </main>
  </div>

  <script>
    let autoScroll = true;
    let previousStatus = null;
    let notificationPermissionRequested = false;

    const consoleBody = document.getElementById('consoleBody');
    const logLines = document.getElementById('logLines');
    const autoScrollBtn = document.getElementById('autoScrollBtn');
    const clearLogsBtn = document.getElementById('clearLogsBtn');
    const notifyBtn = document.getElementById('notifyBtn');
    const downloadBanner = document.getElementById('downloadBanner');
    const statusBadge = document.getElementById('statusBadge');
    const statusText = document.getElementById('statusText');

    const qrModalBtn = document.getElementById('qrModalBtn');
    const qrModal = document.getElementById('qrModal');
    const closeQrModalBtn = document.getElementById('closeQrModalBtn');

    const receivedLogs = new Set();

    autoScrollBtn.addEventListener('click', () => {
      autoScroll = !autoScroll;
      autoScrollBtn.textContent = `Auto-scroll: \${autoScroll ? 'ON' : 'OFF'}`;
    });

    clearLogsBtn.addEventListener('click', () => {
      logLines.textContent = '';
      receivedLogs.clear();
    });

    qrModalBtn.addEventListener('click', () => {
      qrModal.style.display = 'flex';
    });

    closeQrModalBtn.addEventListener('click', () => {
      qrModal.style.display = 'none';
    });

    qrModal.addEventListener('click', (e) => {
      if (e.target === qrModal) qrModal.style.display = 'none';
    });

    function updateNotifyBtn() {
      if (!('Notification' in window)) {
        notifyBtn.style.display = 'none';
        return;
      }
      if (Notification.permission === 'granted') {
        notifyBtn.textContent = '🔔 Notifications Enabled';
        notifyBtn.style.color = '#10b981';
      } else if (Notification.permission === 'denied') {
        notifyBtn.textContent = '🔕 Notifications Blocked';
        notifyBtn.style.color = '#f43f5e';
      } else {
        notifyBtn.textContent = '🔔 Enable Notifications';
      }
    }

    notifyBtn.addEventListener('click', async () => {
      if ('Notification' in window && Notification.permission !== 'granted') {
        await Notification.requestPermission();
        updateNotifyBtn();
      }
    });

    function sendWebNotification(title, options) {
      if ('Notification' in window && Notification.permission === 'granted') {
        try {
          new Notification(title, options);
        } catch (e) {
          console.warn('Failed to trigger web notification:', e);
        }
      }
    }

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
      logLines.appendChild(line);
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

      const currentStatus = (data.status || '').toLowerCase();

      // Trigger Web Notification on Status Transition
      if (previousStatus && previousStatus !== currentStatus) {
        const projectName = data.projectName || 'Flutter Project';
        const projectVersion = data.projectVersion ? ` (\${data.projectVersion})` : '';

        if (currentStatus === 'success' || currentStatus === 'serving') {
          sendWebNotification(`✓ Build Successful — \${projectName}\${projectVersion}`, {
            body: 'APK build finished cleanly and is ready for LAN download!',
            tag: 'flanb-build-notification'
          });
        } else if (currentStatus === 'failed') {
          sendWebNotification(`✗ Build Failed — \${projectName}\${projectVersion}`, {
            body: 'Flutter build failed. Check live console logs for details.',
            tag: 'flanb-build-notification'
          });
        }
      }

      // Auto-prompt once if building
      if (currentStatus === 'building' && 'Notification' in window && Notification.permission === 'default' && !notificationPermissionRequested) {
        notificationPermissionRequested = true;
        Notification.requestPermission().then(updateNotifyBtn);
      }

      previousStatus = currentStatus;

      statusBadge.className = 'status-badge ';
      if (currentStatus === 'building') {
        statusBadge.classList.add('status-building');
        statusText.textContent = 'Building...';
      } else if (currentStatus === 'success' || currentStatus === 'serving') {
        statusBadge.classList.add('status-success');
        statusText.textContent = 'Ready';
        if (data.apkAvailable) {
          downloadBanner.style.display = 'flex';
          const sizeMB = data.apkSize ? (data.apkSize / (1024 * 1024)).toFixed(1) + ' MB' : '';
          document.getElementById('apkMetadata').textContent = `File: \${data.apkName || 'app.apk'} \${sizeMB ? '• ' + sizeMB : ''}`;
        }
      } else if (currentStatus === 'failed') {
        statusBadge.classList.add('status-failed');
        statusText.textContent = 'Build Failed';
      } else {
        statusBadge.classList.add('status-building');
        statusText.textContent = currentStatus;
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
    updateNotifyBtn();
    fetchLogHistory();
    connectSse();
    fetchStatus();
    setInterval(fetchStatus, 2000);
    setInterval(fetchLogHistory, 4000);
  </script>
</body>
</html>
''';
