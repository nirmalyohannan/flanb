const String embeddedWebHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FLANB — Flutter LAN Build</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-gradient: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%);
      --card-bg: rgba(30, 41, 59, 0.7);
      --card-border: rgba(255, 255, 255, 0.1);
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --accent-blue: #38bdf8;
      --accent-indigo: #6366f1;
      --success-green: #22c55e;
      --success-bg: rgba(34, 197, 94, 0.15);
      --error-red: #ef4444;
      --error-bg: rgba(239, 68, 68, 0.15);
      --warning-amber: #f59e0b;
      --warning-bg: rgba(245, 158, 11, 0.15);
      --code-bg: #090d16;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
      background: var(--bg-gradient);
      color: var(--text-main);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 2rem 1rem;
    }

    .container {
      width: 100%;
      max-width: 860px;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 1rem 1.5rem;
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }

    .brand-logo {
      width: 38px;
      height: 38px;
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-indigo));
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 1.2rem;
      color: #fff;
      box-shadow: 0 4px 12px rgba(56, 189, 248, 0.3);
    }

    .brand-title {
      font-size: 1.4rem;
      font-weight: 700;
      letter-spacing: -0.02em;
      background: linear-gradient(90deg, #38bdf8, #818cf8);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .brand-subtitle {
      font-size: 0.75rem;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.1em;
      font-weight: 500;
    }

    .status-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.4rem 0.9rem;
      border-radius: 20px;
      font-size: 0.85rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .status-building {
      background: var(--warning-bg);
      color: var(--warning-amber);
      border: 1px solid rgba(245, 158, 11, 0.3);
    }

    .status-success, .status-serving {
      background: var(--success-bg);
      color: var(--success-green);
      border: 1px solid rgba(34, 197, 94, 0.3);
    }

    .status-failed {
      background: var(--error-bg);
      color: var(--error-red);
      border: 1px solid rgba(239, 68, 68, 0.3);
    }

    .pulse-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: currentColor;
      animation: pulse 1.5s infinite ease-in-out;
    }

    @keyframes pulse {
      0%, 100% { opacity: 0.3; transform: scale(0.8); }
      50% { opacity: 1; transform: scale(1.2); }
    }

    .card {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 1.5rem;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }

    .meta-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 1rem;
    }

    .meta-item {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }

    .meta-label {
      font-size: 0.75rem;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .meta-value {
      font-size: 1rem;
      font-weight: 600;
      color: var(--text-main);
      word-break: break-all;
    }

    .download-card {
      background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(56, 189, 248, 0.1));
      border: 1px solid rgba(34, 197, 94, 0.3);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      gap: 1rem;
      padding: 2rem 1.5rem;
    }

    .download-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.75rem;
      background: linear-gradient(135deg, #22c55e, #16a34a);
      color: #ffffff;
      font-size: 1.1rem;
      font-weight: 700;
      padding: 0.9rem 2rem;
      border-radius: 12px;
      text-decoration: none;
      box-shadow: 0 4px 20px rgba(34, 197, 94, 0.4);
      transition: all 0.2s ease;
    }

    .download-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 25px rgba(34, 197, 94, 0.6);
    }

    .console-card {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .console-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .console-title {
      font-size: 0.9rem;
      font-weight: 600;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .console-controls {
      display: flex;
      gap: 0.5rem;
    }

    .btn-small {
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid var(--card-border);
      color: var(--text-muted);
      font-size: 0.75rem;
      padding: 0.25rem 0.6rem;
      border-radius: 6px;
      cursor: pointer;
      transition: background 0.2s;
    }

    .btn-small:hover {
      background: rgba(255, 255, 255, 0.15);
      color: var(--text-main);
    }

    .console-output {
      background: var(--code-bg);
      border: 1px solid rgba(255, 255, 255, 0.05);
      border-radius: 10px;
      padding: 1rem;
      font-family: 'JetBrains Mono', monospace;
      font-size: 0.82rem;
      line-height: 1.5;
      color: #cbd5e1;
      height: 380px;
      overflow-y: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }

    .log-line-err {
      color: var(--error-red);
    }

    .log-line-success {
      color: var(--success-green);
    }

    footer {
      text-align: center;
      font-size: 0.8rem;
      color: var(--text-muted);
      margin-top: 1rem;
    }

    @media (max-width: 600px) {
      header {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.75rem;
      }
      .status-badge {
        align-self: flex-start;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="brand">
        <div class="brand-logo">⚡</div>
        <div>
          <div class="brand-title">FLANB</div>
          <div class="brand-subtitle">Flutter LAN Build</div>
        </div>
      </div>
      <div id="statusBadge" class="status-badge status-building">
        <div class="pulse-dot"></div>
        <span id="statusText">Initialising...</span>
      </div>
    </header>

    <div class="card">
      <div class="meta-grid">
        <div class="meta-item">
          <div class="meta-label">Project</div>
          <div id="metaProject" class="meta-value">-</div>
        </div>
        <div class="meta-item">
          <div class="meta-label">Flavor</div>
          <div id="metaFlavor" class="meta-value">Default</div>
        </div>
        <div class="meta-item">
          <div class="meta-label">Entry Point</div>
          <div id="metaEntry" class="meta-value">lib/main.dart</div>
        </div>
        <div class="meta-item">
          <div class="meta-label">Build Mode</div>
          <div id="metaMode" class="meta-value">Release</div>
        </div>
      </div>
    </div>

    <div id="downloadCard" class="card download-card" style="display: none;">
      <h2 style="font-size: 1.4rem; font-weight: 700; color: #fff;">Build Completed Successfully</h2>
      <p id="apkMetadata" style="color: var(--text-muted); font-size: 0.9rem;">Ready for installation on local Android devices</p>
      <a id="downloadBtn" href="/download" class="download-btn">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Download APK
      </a>
    </div>

    <div class="card console-card">
      <div class="console-header">
        <div class="console-title">Live Build Logs</div>
        <div class="console-controls">
          <button id="clearLogsBtn" class="btn-small">Clear</button>
          <button id="autoScrollBtn" class="btn-small">Auto-scroll: ON</button>
        </div>
      </div>
      <div id="consoleOutput" class="console-output">Connecting to build log stream...\n</div>
    </div>

    <footer>
      FLANB — Local Network Build & Distribution Server
    </footer>
  </div>

  <script>
    let autoScroll = true;
    const consoleOutput = document.getElementById('consoleOutput');
    const autoScrollBtn = document.getElementById('autoScrollBtn');
    const clearLogsBtn = document.getElementById('clearLogsBtn');
    const downloadCard = document.getElementById('downloadCard');
    const statusBadge = document.getElementById('statusBadge');
    const statusText = document.getElementById('statusText');

    autoScrollBtn.addEventListener('click', () => {
      autoScroll = !autoScroll;
      autoScrollBtn.textContent = `Auto-scroll: \${autoScroll ? 'ON' : 'OFF'}`;
    });

    clearLogsBtn.addEventListener('click', () => {
      consoleOutput.textContent = '';
    });

    function appendLog(text) {
      const line = document.createElement('div');
      if (text.startsWith('[ERR]')) {
        line.className = 'log-line-err';
      } else if (text.includes('✓') || text.includes('SUCCESS')) {
        line.className = 'log-line-success';
      }
      line.textContent = text;
      consoleOutput.appendChild(line);
      if (autoScroll) {
        consoleOutput.scrollTop = consoleOutput.scrollHeight;
      }
    }

    function updateStatus(data) {
      if (data.projectName) document.getElementById('metaProject').textContent = data.projectName;
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
          downloadCard.style.display = 'flex';
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

    // Connect Server-Sent Events (SSE) for build logs
    const eventSource = new EventSource('/logs');
    eventSource.onopen = () => {
      consoleOutput.textContent = '';
    };
    eventSource.onmessage = (event) => {
      appendLog(event.data);
    };

    // Poll status periodically
    async function fetchStatus() {
      try {
        const res = await fetch('/status');
        if (res.ok) {
          const data = await res.json();
          updateStatus(data);
        }
      } catch (e) {}
    }

    fetchStatus();
    setInterval(fetchStatus, 3000);
  </script>
</body>
</html>
''';
