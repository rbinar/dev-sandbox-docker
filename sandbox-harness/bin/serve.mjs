// Picker sayfasını sunan minik statik sunucu. Bağımlılık yok, dışarıya istek yok.
// Ayrıca /api/status ile hangi harness'ın kurulu olduğunu bildirir.
import http from 'node:http'
import fs from 'node:fs'
import path from 'node:path'
import { execFile } from 'node:child_process'

const PORT = Number(process.argv[2] || 3060)
const ROOT = process.argv[3] || '/opt/harness/web'

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
}

const HARNESSES = [
  { id: 'claude', label: 'Claude Code', port: 3061, cmd: 'claude' },
  { id: 'codex', label: 'Codex', port: 3062, cmd: 'codex' },
  { id: 'antigravity', label: 'Antigravity', port: 3063, cmd: 'agy' },
  { id: 'opencode', label: 'OpenCode', port: 3064, cmd: 'opencode' },
  { id: 'copilot', label: 'GitHub Copilot', port: 3065, cmd: 'copilot' },
]

function which(cmd) {
  return new Promise((resolve) => {
    execFile('/usr/bin/env', ['which', cmd], (err, stdout) => {
      resolve(err ? null : String(stdout).trim() || null)
    })
  })
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost')

  if (url.pathname === '/api/status') {
    const rows = await Promise.all(
      HARNESSES.map(async (h) => ({ ...h, installed: Boolean(await which(h.cmd)) }))
    )
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' })
    res.end(JSON.stringify({ harnesses: rows }))
    return
  }

  // Yalnızca ROOT altındaki dosyalar; path traversal'a kapalı.
  const rel = url.pathname === '/' ? 'index.html' : url.pathname.replace(/^\/+/, '')
  const file = path.resolve(ROOT, rel)
  if (!file.startsWith(path.resolve(ROOT))) {
    res.writeHead(403).end('forbidden')
    return
  }
  fs.readFile(file, (err, buf) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' }).end('not found')
      return
    }
    res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream' })
    res.end(buf)
  })
})

server.listen(PORT, '0.0.0.0', () => {
  console.log(`picker on ${PORT} (root=${ROOT})`)
})
