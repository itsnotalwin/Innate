#!/usr/bin/env python3
"""Test actual Godot Web export over HTTP in desktop and touch-emulated Chromium."""
import asyncio,json,os
from pathlib import Path
from PIL import Image, ImageChops
from playwright.async_api import async_playwright
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'tests/evidence'
URL=os.environ.get('INNATE_TEST_URL','http://127.0.0.1:8000/')
async def main():
 messages=[];failures=[];checks=[]
 def check(ok,label):
  checks.append({'check':label,'passed':bool(ok)})
  if not ok:failures.append(label)
 def changed(a,b):
  return ImageChops.difference(Image.open(a).convert('RGB'),Image.open(b).convert('RGB')).getbbox() is not None
 async with async_playwright() as p:
  browser=await p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--enable-unsafe-swiftshader'])
  async def open_game(context):
   page=await context.new_page()
   page.on('console',lambda m:messages.append({'type':m.type,'text':m.text}))
   page.on('pageerror',lambda e:messages.append({'type':'pageerror','text':str(e)}))
   await page.goto(URL)
   await page.wait_for_function("!document.getElementById('status') || document.getElementById('status').style.display === 'none'",timeout=45000)
   await page.wait_for_timeout(1000)
   return page
  desktop=await browser.new_context(viewport={'width':1152,'height':648})
  page=await open_game(desktop)
  await page.screenshot(path=str(OUT/'desktop-spawn.png'))
  check(await page.locator('canvas').is_visible(),'Godot initializes and renders its canvas')
  check(await page.evaluate("document.activeElement.id === 'canvas'"),'canvas has keyboard focus')
  await page.keyboard.down('ArrowRight');await page.wait_for_timeout(2000);await page.keyboard.up('ArrowRight');await page.wait_for_timeout(350)
  await page.screenshot(path=str(OUT/'desktop-tree.png'))
  check(changed(OUT/'desktop-spawn.png',OUT/'desktop-tree.png'),'arrow-key walking changes rendered world')
  await page.keyboard.down('d');await page.wait_for_timeout(2900);await page.keyboard.up('d');await page.wait_for_timeout(400)
  await page.screenshot(path=str(OUT/'desktop-pond.png'))
  check(changed(OUT/'desktop-tree.png',OUT/'desktop-pond.png'),'WASD walking and camera follow work in Web export')
  await page.keyboard.down('w');await page.keyboard.down('a');await page.wait_for_timeout(250);await page.keyboard.up('w');await page.keyboard.up('a');await page.wait_for_timeout(500)
  await page.screenshot(path=str(OUT/'desktop-diagonal.png'))
  check(changed(OUT/'desktop-pond.png',OUT/'desktop-diagonal.png'),'simultaneous diagonal keyboard input moves player')
  await page.screenshot(path='/tmp/innate-idle-1.png');await page.wait_for_timeout(350);await page.screenshot(path='/tmp/innate-idle-2.png')
  check(not changed('/tmp/innate-idle-1.png','/tmp/innate-idle-2.png'),'keyboard release returns to stable idle')
  check(await page.evaluate('scrollX === 0 && scrollY === 0'),'movement keys do not scroll page')
  mobile=await browser.new_context(viewport={'width':844,'height':390},has_touch=True,is_mobile=True,device_scale_factor=1)
  m=await open_game(mobile)
  await m.screenshot(path=str(OUT/'mobile-landscape.png'))
  cdp=await mobile.new_cdp_session(m)
  # Fixed 384x216 Godot viewport is letterboxed into 844x390.
  scale=390/216;left=(844-384*scale)/2
  x=left+46*scale;y=170*scale
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x,'y':y,'id':0}]})
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchMove','touchPoints':[{'x':x+40,'y':y-28,'id':0}]})
  await m.wait_for_timeout(900)
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]})
  await m.wait_for_timeout(500)
  await m.screenshot(path=str(OUT/'mobile-after-touch.png'))
  check(changed(OUT/'mobile-landscape.png',OUT/'mobile-after-touch.png'),'browser touch drag moves player diagonally')
  await m.screenshot(path='/tmp/innate-touch-idle-1.png');await m.wait_for_timeout(350);await m.screenshot(path='/tmp/innate-touch-idle-2.png')
  check(not changed('/tmp/innate-touch-idle-1.png','/tmp/innate-touch-idle-2.png'),'browser touch release stops movement')
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x+38,'y':y,'id':0}]})
  await m.wait_for_timeout(250)
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchCancel','touchPoints':[]})
  await m.wait_for_timeout(600)
  await m.screenshot(path='/tmp/innate-cancel-1.png');await m.wait_for_timeout(350);await m.screenshot(path='/tmp/innate-cancel-2.png')
  check(not changed('/tmp/innate-cancel-1.png','/tmp/innate-cancel-2.png'),'browser touch cancellation stops movement')
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchStart','touchPoints':[{'x':x+38,'y':y,'id':0}]})
  await m.set_viewport_size({'width':390,'height':844})
  await m.wait_for_timeout(650)
  await m.screenshot(path=str(OUT/'mobile-portrait.png'))
  await m.screenshot(path='/tmp/innate-resize-1.png');await m.wait_for_timeout(350);await m.screenshot(path='/tmp/innate-resize-2.png')
  check(not changed('/tmp/innate-resize-1.png','/tmp/innate-resize-2.png'),'resize during held touch leaves no stuck movement')
  await cdp.send('Input.dispatchTouchEvent',{'type':'touchEnd','touchPoints':[]})
  errors=[entry for entry in messages if entry['type'] in ['error','pageerror']]
  check(not errors,'no browser console errors or uncaught exceptions')
  await browser.close()
 report={'checks':checks,'failures':failures,'console':messages,'real_device_tested':False}
 (OUT/'browser-results.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({'passed':len(checks)-len(failures),'total':len(checks),'failures':failures},indent=2))
 if failures:raise SystemExit(1)
asyncio.run(main())
