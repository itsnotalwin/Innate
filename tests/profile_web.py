#!/usr/bin/env python3
"""Sample browser frame pacing; software WebGL numbers are not real-phone FPS."""
import argparse
import asyncio
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import subprocess
from threading import Thread
import time
from playwright.async_api import async_playwright

ROOT = Path(__file__).resolve().parents[1]


async def profile(urls):
    results = []
    async with async_playwright() as p:
        for label, url in urls:
            for width, height, density in [(390, 844, 3), (1152, 648, 1)]:
                browser = await p.chromium.launch(executable_path='/usr/bin/chromium', headless=True,
                    args=['--no-sandbox', '--enable-unsafe-swiftshader'])
                page = await browser.new_page(viewport={'width': width, 'height': height},
                                             has_touch=True, device_scale_factor=density)
                start = time.perf_counter()
                await page.goto(url)
                await page.wait_for_function("document.querySelector('canvas') && !document.getElementById('status')", timeout=60000)
                load_ms = (time.perf_counter() - start) * 1000
                await page.wait_for_timeout(500)
                buffer = await page.locator('canvas').evaluate('(c) => [c.width, c.height]')
                await page.keyboard.down('d')
                samples = await page.evaluate('''() => new Promise(resolve => {
                    const samples=[]; let last=performance.now(); const end=last+4000;
                    function tick(now) { samples.push(now-last); last=now;
                        if(now<end) requestAnimationFrame(tick); else resolve(samples.slice(2)); }
                    requestAnimationFrame(tick);
                })''')
                samples.sort()
                results.append({'build': label, 'viewport': [width, height], 'device_pixel_ratio': density,
                    'render_buffer': buffer, 'local_ready_ms': round(load_ms),
                    'mean_frame_ms': round(sum(samples)/len(samples), 2),
                    'p95_frame_ms': round(samples[int(len(samples)*.95)], 2),
                    'frames_over_33ms': sum(x > 33.5 for x in samples), 'samples': len(samples)})
                await browser.close()
    return {'method': 'Single 4-second moving samples, fresh Chromium processes, local HTTP, software WebGL. Not real-device measurements.', 'results': results}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline-ref', help='Optional Git revision containing the old docs/index.html and index.pck')
    args = parser.parse_args()
    class QuietHandler(SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass
    server = ThreadingHTTPServer(('127.0.0.1', 0), partial(QuietHandler, directory=str(ROOT)))
    Thread(target=server.serve_forever, daemon=True).start()
    base_url = f'http://127.0.0.1:{server.server_port}'
    urls = []
    if args.baseline_ref:
        baseline = ROOT / 'build/performance-baseline'
        baseline.mkdir(parents=True, exist_ok=True)
        for name in ('index.html', 'index.pck', 'index.js', 'index.wasm', 'index.png', 'index.audio.worklet.js', 'index.audio.position.worklet.js'):
            data = subprocess.check_output(['git', 'show', f'{args.baseline_ref}:docs/{name}'], cwd=ROOT)
            (baseline / name).write_bytes(data)
        urls.append(('baseline ' + args.baseline_ref, base_url + '/build/performance-baseline/'))
    urls.append(('portrait update', base_url + '/docs/'))
    try:
        report = asyncio.run(profile(urls))
    finally:
        server.shutdown()
    (ROOT / 'tests/evidence/performance-comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
