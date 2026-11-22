// Checks the page in a headless browser over the DevTools protocol, in real time. Each plan starts the
// program on a port of its own, opens its page, does what the plan says, and prints what it saw.
// Usage: node drive.js <chrome.exe> <profile dir> <out dir> <plan name> <the program>
// The plans: start, backdoor, wide, moths, web, buy, shelf, lives, grab, during, again.
// Uses nothing but Node's own modules (the WebSocket and fetch that Node 22 ships).
const { spawn } = require('child_process');
const fs = require('fs'), path = require('path');
const [chrome, profile, outDir, planName, program] = process.argv.slice(2);
const PORT = 9333 + Math.floor(Math.random() * 500);
const sleep = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  const proc = spawn(chrome, ['--headless=new', '--disable-gpu', '--no-first-run', '--hide-scrollbars',
    '--remote-debugging-port=' + PORT, '--user-data-dir=' + profile, '--window-size=900,600', 'about:blank'], { stdio: 'ignore' });
  let target = null;
  for (let i = 0; i < 50 && !target; i++) {
    await sleep(200);
    try { target = (await (await fetch('http://127.0.0.1:' + PORT + '/json')).json()).find(t => t.type === 'page'); } catch (e) {}
  }
  if (!target) { console.log('NO TARGET'); proc.kill(); process.exit(1); }
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise(r => { ws.onopen = r; });
  let id = 0; const waiting = new Map(), problems = [], handlers = {};
  ws.onmessage = ev => {
    const m = JSON.parse(ev.data);
    if (m.id && waiting.has(m.id)) { waiting.get(m.id)(m.result || m.error); waiting.delete(m.id); }
    if (m.method && handlers[m.method]) handlers[m.method](m.params);
    if (m.method === 'Runtime.exceptionThrown') problems.push('EXCEPTION ' + JSON.stringify(m.params.exceptionDetails).slice(0, 400));
    if (m.method === 'Runtime.consoleAPICalled' && /error|warning/.test(m.params.type)) problems.push('CONSOLE ' + JSON.stringify(m.params.args).slice(0, 300));
  };
  const send = (method, params) => new Promise(r => { const n = ++id; waiting.set(n, r); ws.send(JSON.stringify({ id: n, method, params: params || {} })); });
  const shot = async name => {
    const r = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(outDir, name + '.png'), Buffer.from(r.data, 'base64'));
  };
  const state = async () => (await send('Runtime.evaluate', { expression: "document.getElementById('state').textContent" })).result.value;
  const mouse = (type, x, y, extra) => send('Input.dispatchMouseEvent', Object.assign({ type, x, y, button: 'none', pointerType: 'mouse' }, extra || {}));
  const size = (w, h, dpr) => send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: dpr || 1, mobile: false });
  // where the spider's body is on the screen: the game keeps its own units, and the window only decides how large they are drawn
  const BODY = "(() => { const r = document.getElementById('page').getBoundingClientRect(); return [r.left + spider.body.x * r.width / world.edge.w, r.top + spider.body.y * r.height / world.edge.h]; })()";

  await send('Runtime.enable'); await send('Page.enable');
  const plans = {
    // the game runs in the program, the page is a screen, and the backdoor writes into the state
    start: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const ribbon = () => js("document.getElementById('ribbon').textContent + ' | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent + ' | ' + [...document.querySelectorAll('#ring0 button, #ring1 button')].map(b => b.textContent + ' ' + (b.className || '?')).join(', ')");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 150)).join('\\n      ')");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      const body = () => js("fetch('/backdoor', { method: 'POST', body: 'spider.body.x; spider.body.y; spider.body.state' }).then(r => r.text()).then(t => t.split('\\n').join(', '))");
      await size(1300, 900); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2500);
      console.log('at the start:      ', await ribbon(), '| body', await body());
      const box = await js("(() => { const r = document.getElementById('page').getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; })()");
      for (let i = 0; i <= 30; i++) { await mouse('mouseMoved', box[0] + box[2] * (0.2 + 0.02 * i), box[1] + box[3] * 0.25); await sleep(60); }
      await sleep(2500);
      console.log('pointer top left:  ', await ribbon(), '| body', await body());
      await shot('start_walking');
      await type('spider.body.x += 150'); await sleep(250);
      console.log('typed at the backdoor:  spider.body.x += 150\n      ' + (await backdoor(3)));
      console.log('  a moment later:  ', await ribbon());
      await shot('start_halted');
      await sleep(1500);
      console.log('  1.5 s later:     ', await ribbon(), '\n      ' + (await backdoor(2)));
      await type('spider.legs[*].x += 40; spider.ring[*].alive = false'); await sleep(2000);
      console.log('every foot moved and every observer stopped, in one line:\n      ' + (await backdoor(4)));
      await type("spider.body.x = 'left'"); await sleep(300);
      console.log('a text written where a number goes:\n      ' + (await backdoor(1)));
      await type('spider.ring[3]'); await sleep(300);
      console.log('reading the coordinator:\n      ' + (await backdoor(1)));
      await sleep(3000);
      console.log('three seconds on:  ', await ribbon());
      srv.kill(); await sleep(1800);
      console.log('server stopped:    ', await ribbon());
      await shot('start_end');
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // the backdoor's help: the state shown on the right, and what is offered as a line is typed
    backdoor: async () => {
      const port = 8300 + Math.floor(Math.random() * 500);
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] });
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const hints = () => js("[...document.querySelectorAll('#hints button')].map(b => b.textContent).join(' | ')");
      const line = () => js("document.getElementById('backdoor').value");
      const key = async k => { await send('Input.dispatchKeyEvent', { type: 'keyDown', key: k, code: k, windowsVirtualKeyCode: k === 'Tab' ? 9 : 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k, windowsVirtualKeyCode: k === 'Tab' ? 9 : 13 }); await sleep(120); };
      const typed = async text => { await send('Input.insertText', { text }); await sleep(150); };
      await size(1300, 900); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2500);
      console.log('placeholder:', await js("document.getElementById('backdoor').placeholder"));
      console.log('the state shown: ' + (await js("document.querySelectorAll('#state details').length")) + ' groups, ' + (await js("document.querySelectorAll('#state .field').length")) + ' fields | body: ' + (await js("[...document.querySelectorAll('#state details')[0].querySelectorAll('.field')].slice(0, 5).map(b => b.textContent).join(', ')")));
      await js("document.getElementById('backdoor').focus(); 0"); await sleep(150);
      console.log('nothing typed      ->', await hints());
      await typed('sp'); console.log('"sp"               ->', await hints());
      await key('Tab'); console.log('Tab                ->', JSON.stringify(await line()), '->', await hints());
      await typed('l'); console.log('then "l"           ->', await hints());
      await key('Tab'); console.log('Tab                ->', JSON.stringify(await line()), '->', await hints());
      await typed('*'); await key('Tab'); console.log('"*" and Tab        ->', JSON.stringify(await line()), '->', await hints());
      await typed('x'); console.log('then "x"           ->', await hints());
      await typed('+'); await key('Tab'); console.log('"+" and Tab        ->', JSON.stringify(await line()), '->', await hints());
      await shot('backdoor_hints');
      await typed('40'); await key('Enter'); await sleep(1700);
      console.log('"40" and Enter     ->', await js("[...document.getElementById('said').children].slice(-3).map(d => d.textContent.slice(0, 90)).join(' / ')"));
      await js("document.querySelectorAll('#state details')[0].querySelectorAll('.field')[8].click(); 0"); await sleep(200);
      console.log('a click on a field of the body ->', JSON.stringify(await line()), '->', await hints());
      await shot('backdoor_state');
      srv.kill(); await sleep(200);
    },

    // how the page fills windows of several shapes
    wide: async () => {
      const port = 8300 + Math.floor(Math.random() * 500);
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] });
      const js = async expression => (await send('Runtime.evaluate', { expression, returnByValue: true })).result.value;
      await sleep(900);
      for (const [w, h] of [[2543, 1263], [1920, 950], [1300, 900], [1100, 1000]]) {
        await size(w, h);
        await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(1800);
        console.log(w + ' by ' + h + ':', await js("(() => { const r = q => { const b = document.querySelector(q).getBoundingClientRect(); return [Math.round(b.left), Math.round(b.right), Math.round(b.width)]; }; const a = document.querySelectorAll('.panel'); const L = a[0].getBoundingClientRect(), R = a[1].getBoundingClientRect(), S = document.querySelector('.stage').getBoundingClientRect(), D = document.querySelector('.backdoor').getBoundingClientRect(); return 'left panel ' + Math.round(L.width) + ' wide, gap ' + Math.round(S.left - L.right) + ', game ' + Math.round(S.width) + ' by ' + Math.round(S.height) + ', gap ' + Math.round(R.left - S.right) + ', state panel ' + Math.round(R.width) + ' wide | game to backdoor ' + Math.round(D.top - S.bottom) + ' | backdoor ' + Math.round(D.height) + ' tall | sideways scroll ' + (document.documentElement.scrollWidth > innerWidth); })()"));
        await shot('wide_' + w);
      }
      srv.kill(); await sleep(200);
    },

    // the moths, the food and the world's ring
    moths: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const ribbon = () => js("document.getElementById('ribbon').textContent + ' | moths ' + document.getElementById('n-moths').textContent + ', food ' + document.getElementById('food').getAttribute('aria-valuenow') + ' (' + document.getElementById('n-food').textContent + ') | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent + ' | ' + [...document.querySelectorAll('#ring0 button, #ring1 button')].map(b => b.textContent + ' ' + (b.className || '?')).join(', ')");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 150)).join('\\n      ')");
      const ask = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text()).then(t => t.split('\\n').join(', ').slice(0, 300))");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      const groups = () => js("(() => { const d = [...document.querySelectorAll('#state details')]; return d.length + ' groups, ' + document.querySelectorAll('#state .field').length + ' fields: ' + d.map(x => x.querySelector('summary').textContent).filter(t => !/legs/.test(t)).join(' | '); })()");
      const hints = () => js("[...document.querySelectorAll('#hints button')].map(b => b.textContent).join(' | ')");
      const key = async k => { await send('Input.dispatchKeyEvent', { type: 'keyDown', key: k, code: k, windowsVirtualKeyCode: 9 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k, windowsVirtualKeyCode: 9 }); await sleep(120); };
      await size(1500, 950); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2000);
      console.log('at the start:      ', await ribbon());
      for (let i = 0; i < 20 && Number(await ask('world.tally.caught')) < 2; i++) await sleep(1500);
      console.log('after some hunting:', await ribbon());
      console.log('the state shown:   ', await groups());
      await shot('moths_hunting');

      const tries = [
        ['world.moths.push()', 'a moth added from outside'],
        ['world.tally.caught = 1000000', 'the count written'],
        ['world.edge.inset = 300', 'the edge moved in'],
        ['spider.body.food = 1; spider.body.full = true', 'the spider fed from outside'],
        ['world.ring[*].alive = false', 'every observer of the world stopped'],
        ['world.ring[1].copies[4] = \'\'; world.tally.caught += 5', 'the moths observer\'s copy and the count together'],
        ['world.moths[*].x = NaN', 'every moth sent nowhere'],
        ['world.tally.caught = \'many\'', 'a text where a number goes'],
      ];
      for (const [line, what] of tries) {
        while (line.includes('moths[') && !(Number(await ask('world.tally.caught')) >= 0 && /id/.test(await ask('world.moths')))) await sleep(1000);
        const was = await ask('world.tally.caught');
        await type(line); await sleep(250);
        const mid = await ribbon();
        if (line.includes('push')) await shot('moths_halted');
        await sleep(1500);
        console.log(what + ':  ' + line + '\n      ' + (await backdoor(3)) + '\n      at once:  ' + mid + '\n      1.5 s on: ' + (await ribbon()) + '\n      the count before ' + was + ', after ' + (await ask('world.tally.caught')));
      }
      console.log('the state shown:   ', await groups());

      await js("document.getElementById('backdoor').focus(); 0"); await sleep(150);
      await send('Input.insertText', { text: 'wo' }); await sleep(150); console.log('"wo"            ->', await hints());
      await key('Tab'); console.log('Tab             ->', JSON.stringify(await js("document.getElementById('backdoor').value")), '->', await hints());
      await send('Input.insertText', { text: 'moths.' }); await sleep(150); console.log('then "moths."   ->', await hints());
      await send('Input.insertText', { text: 'p' }); await sleep(150); console.log('then "p"        ->', await hints());
      await js("document.getElementById('backdoor').value = ''; 0");
      await send('Input.insertText', { text: 'world.tally.' }); await sleep(150); console.log('"world.tally."  ->', await hints());
      await js("document.getElementById('backdoor').value = ''; 0");
      await sleep(4000);
      console.log('four seconds on:   ', await ribbon());
      await shot('moths_end');
      srv.kill(); await sleep(1800);
      console.log('server stopped:    ', await ribbon());
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // the web, and the three ways a halt can end
    web: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const ribbon = () => js("document.getElementById('ribbon').textContent + ' | moths ' + document.getElementById('n-moths').textContent + ', webs ' + document.getElementById('n-webs').textContent + ' | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent");
      const chips = () => js("['ring0', 'ring1'].map(id => [...document.querySelectorAll('#' + id + ' button')].map(b => b.textContent + ' ' + (b.className || '?')).join(', ')).join(' | ')");
      const how = () => js("[...document.querySelectorAll('#how button')].map(b => b.textContent + (b.getAttribute('aria-pressed') === 'true' ? ' (set)' : '')).join(', ') + ' | the button: ' + (document.getElementById('right').hidden ? 'not shown' : document.getElementById('right').disabled ? 'shown, cannot be clicked' : 'shown, can be clicked')");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 150)).join('\\n      ')");
      const ask = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text()).then(t => t.split('\\n').join(', ').slice(0, 300))");
      const whole = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text())");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      const press = sel => js("document.querySelector(" + JSON.stringify(sel) + ").click(); 0");
      const onScreen = async (x, y) => { const r = await js("(() => { const r = document.getElementById('page').getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; })()"); return [r[0] + x * r[2] / 1200, r[1] + y * r[3] / 800]; };
      await size(1500, 950); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2500);
      console.log('at the start:        ', await ribbon());
      console.log('the observers:       ', await chips());
      console.log('how a halt ends:     ', await how());

      console.log('\n-- after a pause (as it starts)');
      await type('spider.body.x += 150'); await sleep(250);
      console.log('a quarter second on: ', await ribbon());
      await sleep(1300);
      console.log('1.5 s on:            ', await ribbon(), '\n      ' + (await backdoor(4)));

      console.log('\n-- at once');
      await press('#how button[data-how="at once"]'); await sleep(300);
      console.log('how a halt ends:     ', await how());
      const x0 = Number(await ask('spider.body.x'));
      await type('spider.body.x += 150'); await sleep(250);
      console.log('a quarter second on: ', await ribbon(), '| the body is ' + Math.abs(Number(await ask('spider.body.x')) - x0).toFixed(1) + ' from where it was', '\n      ' + (await backdoor(4)));
      await shot('web_at_once');
      await type('world.web.made = 0; world.tally.caught = 500; spider.ring[*].alive = false'); await sleep(250);
      console.log('three at once:       ', await ribbon(), '| the count is ' + (await ask('world.tally.caught')), '\n      ' + (await backdoor(5)));

      console.log('\n-- on a click');
      await press('#how button[data-how="on a click"]'); await sleep(300);
      console.log('how a halt ends:     ', await how());
      await type('world.tally.caught = 999'); await sleep(3000);
      console.log('three seconds on:    ', await ribbon(), '|', await how(), '| the count is ' + (await ask('world.tally.caught')));
      await type('world.web.on = false'); await sleep(1000);
      console.log('and the web taken:   ', await ribbon());
      await shot('web_on_a_click');
      await press('#right'); await sleep(300);
      console.log('the button clicked:  ', await ribbon(), '|', await how(), '| the count is ' + (await ask('world.tally.caught')) + ', the web is there: ' + (await ask('world.web.on')), '\n      ' + (await backdoor(2)));
      await press('#how button[data-how="after a pause"]'); await sleep(300);
      console.log('how a halt ends:     ', await how());

      console.log('\n-- the web');
      await sleep(15000);
      console.log('a while on:          ', await ribbon(), '| web:', await ask('world.web'));
      await shot('web_making');
      let held = '';
      for (let i = 0; i < 200 && !held; i++) { await sleep(1500); held = JSON.parse(await ask('world.ring[1].held')); }
      console.log('a moth in the web:    held = ' + JSON.stringify(held), '|', await ribbon());
      await sleep(300);
      if (held) {
        const id = held.split(',')[0], moths = JSON.parse(await whole('world.moths')), moth = moths.find(m => String(m.id) === id);
        const before = (await ask('world.tally')) + ' torn ' + (await ask('world.web.torn'));
        if (moth) {
          const [px, py] = await onScreen(moth.x, moth.y);
          await mouse('mouseMoved', px + 3, py + 3); await sleep(300);
          console.log('the pointer over it:  cursor ' + (await js("document.getElementById('page').style.cursor")));
          await shot('web_moth_held');
          await mouse('mousePressed', px + 3, py + 3, { button: 'left', clickCount: 1 }); await mouse('mouseReleased', px + 3, py + 3, { button: 'left', clickCount: 1 }); await sleep(400);
          console.log('a click on it:        before ' + before + '\n                      after  ' + (await ask('world.tally')) + ' torn ' + (await ask('world.web.torn')) + ' | still there: ' + JSON.parse(await whole('world.moths')).some(m => String(m.id) === id));
          await mouse('mouseMoved', 20, 20);
        } else console.log('the moth had gone before it could be clicked (eaten)');
      }
      console.log('                     ', await ribbon());
      await type('world.web.made = 0'); await sleep(250);
      console.log('the web unmade:      ', await ribbon(), '|', await chips());
      await sleep(1500);
      console.log('1.5 s on:            ', await ribbon(), '\n      ' + (await backdoor(3)));
      await press('#ring1 button:nth-child(3)'); await sleep(1500);
      console.log('the web observer stopped by its button:\n      ' + (await backdoor(4)));
      console.log('the state shown:      ' + (await js("(() => { const d = [...document.querySelectorAll('#state details')]; return d.length + ' groups, ' + document.querySelectorAll('#state .field').length + ' fields: ' + d.map(x => x.querySelector('summary').textContent).filter(t => !/legs|moths\\[/.test(t)).join(' | '); })()")));
      await sleep(2000);
      await shot('web_end');
      console.log('at the end:          ', await ribbon(), '|', await chips());
      srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // the shop: what is shown, buying, and moths written in from outside
    buy: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const top = () => js("document.getElementById('n-moths').textContent + document.getElementById('n-tenths').textContent + ' moths | a minute ' + document.getElementById('n-rate').textContent + ', webs made ' + document.getElementById('n-webs').textContent + ', moths caught ' + document.getElementById('n-meals').textContent + ' | food: ' + document.getElementById('n-food').textContent + ' | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent");
      const shelf = () => js("[...document.querySelectorAll('#shelf .upgrade')].map(r => r.querySelector('span').textContent + ' [' + r.querySelector('button').textContent + (r.querySelector('button').disabled ? ', cannot be clicked' : '') + ']').join(' | ')");
      const ask = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text()).then(t => t.split('\\n').join(', ').slice(0, 300))");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 150)).join('\\n      ')");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      const press = sel => js("document.querySelector(" + JSON.stringify(sel) + ").click(); 0");
      await size(1500, 1150); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2500);
      console.log('at the start:      ', await top());
      console.log('the shelf:         ', await shelf());

      console.log('\n-- moths written in from outside buy nothing');
      await type('world.tally.gained = 1000000'); await sleep(250);
      console.log('a quarter second on:', await top(), '\n                    ', await shelf());
      const want = () => js("fetch('/buy', { method: 'POST', body: 'spawn' }).then(r => r.status)");
      console.log('more moths asked for while it is halted:', await want()); await sleep(1300);
      console.log('1.5 s on:           ', await top(), '| the shop: ' + (await ask('world.shop')), '\n      ' + (await backdoor(3)));
      await press('#how button[data-how="at once"]'); await sleep(300);
      await type('world.tally.gained = 1000000; world.shop.spider = 90'); await want(); await sleep(100); await want(); await sleep(400);
      console.log('at once, and more moths asked for twice straight after:', await top(), '| the shop: ' + (await ask('world.shop')), '| the counts: ' + (await ask('world.tally')), '\n      ' + (await backdoor(2)));
      await press('#how button[data-how="after a pause"]'); await sleep(300);

      console.log('\n-- buying with moths that were caught');
      let have = 0;
      for (let i = 0; i < 300 && have < 1000; i++) { await sleep(1500); const t = JSON.parse(await ask('world.tally')); have = t.gained - 100 * t.spent; }
      console.log('moths enough:       ', await top(), '\n                    ', await shelf());
      await shot('buy_before');
      await press('#shelf .upgrade:nth-child(1) button'); await sleep(400);
      console.log('the first bought:   ', await top(), '| the shop: ' + (await ask('world.shop')), '| the counts: ' + (await ask('world.tally')), '\n                    ', await shelf());
      await press('#shelf .upgrade:nth-child(1) button'); await sleep(400);
      console.log('asked for again with too few moths (the button cannot be clicked, so this is a made-up click):', await ask('world.shop'));
      await js("fetch('/buy', { method: 'POST', body: 'spawn' }).then(r => r.status)"); await sleep(300);
      console.log('asked for by a request with no button:', await ask('world.shop'), '| the counts: ' + (await ask('world.tally')));
      console.log('the state shown:     ' + (await js("[...document.querySelectorAll('#state details')].filter(d => /shop|tally/.test(d.querySelector('summary').textContent)).map(d => d.querySelector('summary').textContent + ': ' + [...d.querySelectorAll('.field')].map(f => f.textContent).join(' ')).join(' | ')")));
      await shot('buy_after');
      console.log('at the end:         ', await top());
      srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // how the rows of the shop fit, in windows of several widths
    shelf: async () => {
      const port = 8300 + Math.floor(Math.random() * 500);
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] });
      const js = async expression => (await send('Runtime.evaluate', { expression, returnByValue: true })).result.value;
      await sleep(900);
      for (const [w, h] of [[2543, 1263], [2523, 1263], [2500, 1263], [2300, 1263], [1920, 950], [1500, 950], [1300, 900]]) {
        await size(w, h);
        await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(1500);
        console.log(w + ' by ' + h + ': the card is ' + (await js("Math.round(document.getElementById('shelf').getBoundingClientRect().width)")) + ' wide | ' + (await js("[...document.querySelectorAll('#shelf .upgrade')].map(r => { const t = r.querySelector('span').getBoundingClientRect(), b = r.querySelector('button').getBoundingClientRect(), row = r.getBoundingClientRect(), n = r.querySelector('strong').getBoundingClientRect(), v = r.querySelector('span > span').getBoundingClientRect(); return r.querySelector('strong').textContent + ': ' + (b.top >= t.bottom - 2 ? 'BUTTON UNDER' : 'button beside') + (v.top >= n.bottom - 2 ? ', amount under the name' : '') + ', ' + Math.round(row.right - b.right) + ' from the right, row ' + Math.round(row.height) + ' tall, ' + Math.round(b.left - v.right) + ' to spare'; }).join(' | ')")));
        if (w === 2523 || w === 1920 || w === 1300) await shot('shelf_' + w);
      }
      srv.kill(); await sleep(200);
    },

    // the spider growing old, dying, and the next one walking in at that moment
    lives: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const top = () => js("document.getElementById('ribbon').textContent + ' | ' + [...document.querySelectorAll('.stats.game div')].map(d => d.querySelector('dt').textContent + ' ' + d.querySelector('dd').textContent).join(', ') + ' | food: ' + document.getElementById('n-food').textContent + ' | halts ' + document.getElementById('n-halts').textContent");
      const ask = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text()).then(t => t.split('\\n').join(', ').slice(0, 4000))");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 150)).join('\\n      ')");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      await size(1500, 1150); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(2500);
      console.log('at the start:       ', await top());
      // what the page says and shows of the spider's observers, noted each time it changes
      await js("window.__seen = []; window.__was = ''; setInterval(() => { const now = document.getElementById('ribbon').textContent.slice(0, 110) + ' | ' + [...document.querySelectorAll('#ring0 button')].map(b => b.className).join(' ') + ' | dead spiders ' + document.getElementById('n-dead').textContent; if (now !== window.__was) { window.__was = now; window.__seen.push((performance.now() / 1000).toFixed(2) + ' s  ' + now); } }, 15); 0");

      await type('spider.body.age = 299'); await sleep(250);
      console.log('its age written to the end of its life:', await top());
      await sleep(1500);
      console.log('1.5 s on:           ', await top(), '\n      ' + (await backdoor(3)));

      let body = JSON.parse(await ask('spider.body'));
      console.log('a minute in...'); await sleep(60000);
      console.log('                    ', await top());
      for (let i = 0; i < 400 && body.gen < 2; i++) { await sleep(body.age > 294 || body.food < 0.2 ? 60 : 2000); body = JSON.parse(await ask('spider.body')); }
      await shot('lives_handover');
      const husk = JSON.parse(await ask('spider.old'));
      console.log('the next spider:     no. ' + body.gen + ', age ' + body.age.toFixed(2) + ', size ' + body.size.toFixed(1) + ', at ' + body.x.toFixed(0) + ', ' + body.y.toFixed(0) + ', ' + body.state + ' | the old one: ' + JSON.stringify(husk));
      console.log('                    ', await top());
      console.log('what the page said and showed, each time it changed, over the last of it:\n      ' + (await js("window.__seen.slice(-14).join('\\n      ')")));
      await sleep(700); await shot('lives_walking_in');
      let husks = 0;
      for (let i = 0; i < 60 && husks < 1; i++) { await sleep(500); husks = JSON.parse(await ask('spider.body')).husks; }
      await sleep(300);
      console.log('the old one eaten:  ', await top());
      await shot('lives_eaten');
      await type('spider.old.on = true; spider.body.boost = 0.5'); await sleep(1600);
      console.log('a body and a boost written in:', await top(), '\n      ' + (await backdoor(3)));
      console.log('the state shown:     ' + (await js("[...document.querySelectorAll('#state details')].filter(d => /spider.old|ring\\[0\\]/.test(d.querySelector('summary').textContent)).map(d => d.querySelector('summary').textContent + ': ' + [...d.querySelectorAll('.field')].map(f => f.textContent).join(' ')).join(' | ').slice(0, 500)")));
      srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // the spider picked up by its body, dragged by a leg, and held until it dies
    grab: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const cursor = () => js("document.getElementById('page').style.cursor || 'default'");
      const top = () => js("document.getElementById('ribbon').textContent + ' | cursor ' + (document.getElementById('page').style.cursor || 'default') + ' | dead spiders ' + document.getElementById('n-dead').textContent + ' | food: ' + document.getElementById('food').getAttribute('aria-valuenow') + ' | halts ' + document.getElementById('n-halts').textContent");
      const ask = line => js("fetch('/backdoor', { method: 'POST', body: " + JSON.stringify(line) + " }).then(r => r.text())");
      const spider = async () => JSON.parse(await ask('spider.body'));
      const says = b => 'the spider is ' + b.state + ', grip ' + b.grip + ', at ' + b.x.toFixed(0) + ', ' + b.y.toFixed(0);
      const onScreen = async (x, y) => { const r = await js("(() => { const r = document.getElementById('page').getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; })()"); return [r[0] + x * r[2] / 1200, r[1] + y * r[3] / 800]; };
      const held = { button: 'left', buttons: 1 }, press = { button: 'left', buttons: 1, clickCount: 1 }, lift = { button: 'left', clickCount: 1 };
      const drag = async (fromX, fromY, toX, toY, steps) => { for (let i = 1; i <= steps; i++) { const [px, py] = await onScreen(fromX + (toX - fromX) * i / steps, fromY + (toY - fromY) * i / steps); await mouse('mouseMoved', px, py, held); await sleep(30); } };
      // The pointer put on the spider's body, a little ahead of it as it walks, and pressed there once the page shows that it can be taken hold of.
      const takeBody = async () => {
        for (let i = 0; i < 40; i++) {
          const b = await spider(), [px, py] = await onScreen(b.x + b.v * Math.cos(b.h) * 0.07, b.y + b.v * Math.sin(b.h) * 0.07);
          await mouse('mouseMoved', px, py); await sleep(70);
          if ((await cursor()) !== 'grab') continue;
          const seen = await top();
          await mouse('mousePressed', px, py, press); await sleep(120);
          if ((await cursor()) === 'grabbing') return [await spider(), seen];
          await mouse('mouseReleased', px, py, lift); await sleep(60);
        }
        return null;
      };
      // Held, the spider's food runs down fast. Between one holding and the next, wait until it has eaten.
      const fed = async () => { for (let i = 0; i < 120; i++) { const b = await spider(); if (b.food > 0.7 && (b.state === 'walking' || b.state === 'resting')) return; await sleep(1000); } };
      await size(1500, 1150); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(4000);
      console.log('at the start:        ', await top());

      console.log('\n-- by the body');
      let took = await takeBody();
      if (!took) { console.log('THE BODY COULD NOT BE TAKEN HOLD OF'); srv.kill(); return; }
      let b = took[0];
      console.log('the pointer over it: ', took[1]);
      await shot('grab_over');
      await sleep(300);
      console.log('pressed, not moved:  ', await top(), '|', says(await spider()));
      await drag(b.x, b.y, 900, 250, 12); await sleep(600);
      console.log('moved to 900, 250:   ', await top(), '|', says(await spider()));
      await shot('grab_carried');
      await drag(900, 250, -80, -60, 14); await sleep(700);
      console.log('taken past the corner:', await top(), '|', says(await spider()));
      const [ux, uy] = await onScreen(-80, -60);
      await mouse('mouseReleased', ux, uy, lift); await sleep(250);
      console.log('let go:              ', await top(), '|', says(await spider()));
      await sleep(900);
      console.log('a second on:         ', await top(), '|', says(await spider()));

      console.log('\n-- by a leg');
      await fed();
      console.log('fed again:           ', await top());
      let foot = null;
      for (let i = 0; i < 40 && !foot; i++) {           // a foot that is on the ground, with the pointer put on it and pressed
        const legs = JSON.parse(await ask('spider.legs')), k = legs.findIndex(l => !l.up);
        if (k < 0) { await sleep(60); continue; }
        const [fx, fy] = await onScreen(legs[k].x, legs[k].y);
        await mouse('mouseMoved', fx, fy); await sleep(50);
        await mouse('mousePressed', fx, fy, press); await sleep(120);
        if ((await cursor()) === 'grabbing') foot = { k, x: legs[k].x, y: legs[k].y }; else { await mouse('mouseReleased', fx, fy, lift); await sleep(60); }
      }
      if (!foot) { console.log('NO FOOT COULD BE TAKEN HOLD OF'); srv.kill(); return; }
      await drag(foot.x, foot.y, foot.x < 600 ? foot.x + 420 : foot.x - 420, foot.y < 400 ? foot.y + 200 : foot.y - 200, 30); await sleep(300);
      b = await spider();
      console.log('pressed on the foot of leg ' + foot.k + ' and drawn away:', await top(), '|', says(b));
      await shot('grab_dragged');
      await mouse('mouseReleased', 0, 0, lift); await sleep(1200);
      console.log('let go, a second on: ', await top(), '|', says(await spider()));

      console.log('\n-- held until it dies');
      await fed();
      took = await takeBody();
      if (!took) { console.log('THE BODY COULD NOT BE TAKEN HOLD OF'); srv.kill(); return; }
      b = took[0];
      await drag(b.x, b.y, 600, 400, 8);
      let gen = b.gen, waited = 0;
      while (gen === b.gen && waited < 80) { await sleep(100); waited++; gen = (await spider()).gen; }
      console.log('after ' + (waited / 10).toFixed(1) + ' s held:   ', await top(), '|', says(await spider()), '| the old one: ' + (await ask('spider.old')));
      await shot('grab_died');
      await sleep(1500);
      console.log('the button still down, 1.5 s on:', await top(), '|', says(await spider()));
      await mouse('mouseReleased', 0, 0, lift); await sleep(300);
      await ask('spider.body.grip = 8'); await sleep(1800);
      console.log('a grip written in at the backdoor:', await top(), '\n      ' + (await js("[...document.getElementById('said').children].slice(-2).map(d => d.textContent.slice(0, 150)).join('\\n      ')")));
      srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // the rules of the game: lines written during the work, found and undone, or let through
    during: async () => {
      const port = 8300 + Math.floor(Math.random() * 500), said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const top = () => js("document.getElementById('ribbon').textContent + ' | moths ' + document.getElementById('n-moths').textContent + document.getElementById('n-tenths').textContent + ' | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent + ' | ' + [...document.querySelectorAll('#ring0 button, #ring1 button')].map(b => b.className || '?').join(' ')");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 230)).join('\\n      ')");
      const hints = () => js("[...document.querySelectorAll('#hints button')].map(b => b.textContent).join(' | ')");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      const key = async k => { await send('Input.dispatchKeyEvent', { type: 'keyDown', key: k, code: k, windowsVirtualKeyCode: 9 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k, windowsVirtualKeyCode: 9 }); await sleep(120); };
      await size(1500, 1150); await sleep(900);
      await send('Page.navigate', { url: 'http://localhost:' + port + '/' }); await sleep(3500);
      console.log('at the start:       ', await top());
      await js("document.getElementById('backdoor').focus(); 0"); await sleep(150);
      await send('Input.insertText', { text: 'd' }); await sleep(150); console.log('"d"                 ->', await hints());
      await key('Tab'); console.log('Tab                 ->', JSON.stringify(await js("document.getElementById('backdoor').value")), '->', await hints());
      await send('Input.insertText', { text: 'world.tally.' }); await sleep(150); console.log('then "world.tally." ->', await hints());
      await js("document.getElementById('backdoor').value = ''; 0");

      for (const [line, wait] of [
        ['during world.tally.caught += 5', 1600],
        ['during world.tally.gained += 100000', 1600],
        ['during spider.body.food = 1', 1600],
        ['during spider.body.x += 40; spider.legs[*].x += 40', 1600],
        ['during spider.body.until += 5', 700],
        ['during world.moths.push()', 1600],
        ['during spider.body.nothing = 1', 400],
        ['world.tally.gained = 100000; during world.shop.spider += 1', 1800],
      ]) {
        await type(line); await sleep(200);
        const mid = await top();
        if (line.includes('caught')) await shot('during_halted');
        await sleep(wait);
        console.log('\n' + line + '\n      ' + (await backdoor(4)) + '\n      a moment on: ' + mid + '\n      later:       ' + (await top()));
      }
      await js("document.querySelector('#how button[data-how=\"at once\"]').click(); 0"); await sleep(300);
      await type('during world.tally.gained += 100000'); await sleep(600);
      console.log('\nat once: during world.tally.gained += 100000\n      ' + (await backdoor(3)) + '\n      ' + (await top()));
      await shot('during_end');
      srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

    // The page and a halt that cannot be put right. Nothing typed at the backdoor can bring one about, so the page is
    // shown the program through a relay, which writes one into what the page is sent and takes it out when the page asks
    // for it to be put right. What the program does when it is asked is checked in its own tests: this checks the page.
    again: async () => {
      const http = require('http');
      const port = 8300 + Math.floor(Math.random() * 500), front = port + 600, said = [];
      const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] }); srv.stdout.on('data', d => said.push(String(d).trim())); srv.stderr.on('data', d => said.push('ERR ' + String(d).trim()));
      const WHY = 'twice running, the gate found a step of the work that the rules of the game do not allow: a foot further from the body than a leg can reach';
      let mode = 'as it is', asked = 0;
      const relay = http.createServer((req, res) => {
        // the program answers only to its own name, and takes a POST only from the page it served: the relay speaks to it as that page would
        const headers = Object.assign({}, req.headers, { host: '127.0.0.1:' + port });
        if (headers.origin) headers.origin = 'http://127.0.0.1:' + port;
        const out = http.request({ host: '127.0.0.1', port, path: req.url, method: req.method, headers }, got => {
          res.writeHead(got.statusCode, got.headers);
          if (req.url !== '/stream') { got.pipe(res); return; }
          let kept = '';
          got.setEncoding('utf8');
          got.on('data', d => {
            kept += d;
            let cut;
            while ((cut = kept.indexOf('\n\n')) >= 0) {
              let event = kept.slice(0, cut); kept = kept.slice(cut + 2);
              if (event.startsWith('data: ') && mode !== 'as it is') {
                const f = JSON.parse(event.slice(6));
                if (mode === 'cannot go on') { f.halt = WHY; f.why = WHY; f.stuck = true; f.halts += 1; } else f.games += 1;
                event = 'data: ' + JSON.stringify(f);
              }
              res.write(event + '\n\n');
            }
          });
          got.on('end', () => res.end());
        });
        out.on('error', () => res.destroy());
        if (req.method === 'POST' && req.url === '/right') { asked++; if (mode === 'cannot go on') mode = 'begun again'; }
        req.pipe(out);
      });
      await new Promise(r => relay.listen(front, '127.0.0.1', r));
      const js = async expression => { const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }); return r.exceptionDetails ? 'THREW ' + (r.exceptionDetails.exception && r.exceptionDetails.exception.description || r.exceptionDetails.text) : r.result.value; };
      const top = () => js("document.getElementById('ribbon').textContent + ' | halts ' + document.getElementById('n-halts').textContent + ', restarts ' + document.getElementById('n-restarts').textContent");
      const button = () => js("(() => { const b = document.getElementById('right'), r = b.getBoundingClientRect(); return 'the button is ' + (b.hidden || r.width === 0 ? 'not shown' : 'shown') + (b.disabled ? ', and cannot be clicked' : ', and can be clicked') + ' | set to end ' + document.querySelector('#how button[aria-pressed=\"true\"]').dataset.how + ' | the ribbon is ' + (document.getElementById('ribbon').className || 'plain'); })()");
      const backdoor = n => js("[...document.getElementById('said').children].slice(-" + n + ").map(d => d.textContent.slice(0, 230)).join('\\n      ')");
      const type = async line => { await js("document.getElementById('backdoor').focus(); 0"); await send('Input.insertText', { text: line }); await send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); await send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13 }); };
      await size(1500, 1150); await sleep(900);
      await send('Page.navigate', { url: 'http://127.0.0.1:' + front + '/' }); await sleep(3500);
      console.log('at the start:\n      ' + (await top()) + '\n      ' + (await button()));

      mode = 'cannot go on'; await sleep(600);
      console.log('\na halt that cannot be put right:\n      ' + (await top()) + '\n      ' + (await button()) + '\n      at the backdoor: ' + (await backdoor(1)));
      await shot('again_halted');
      for (const how of ['at once', 'on a click', 'after a pause']) {
        await js("document.querySelector('#how button[data-how=\"" + how + "\"]').click(); 0"); await sleep(1200);
        console.log('      ' + (await button()));
      }
      console.log('      asked so far: ' + asked);

      // the button is clicked where it is on the screen, as a pointer would
      const [bx, by] = await js("(() => { const r = document.getElementById('right').getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; })()");
      console.log('      the button is at ' + Math.round(bx) + ', ' + Math.round(by) + ' in a window ' + (await js("innerWidth + ' by ' + innerHeight")) + ', and what is there is ' + (await js("(e => e ? e.tagName + '#' + e.id : 'nothing')(document.elementFromPoint(" + bx + ", " + by + "))")));
      await mouse('mouseMoved', bx, by); await mouse('mousePressed', bx, by, { button: 'left', clickCount: 1 }); await mouse('mouseReleased', bx, by, { button: 'left', clickCount: 1 });
      await sleep(700);
      console.log('\n"Put it right" clicked: asked ' + asked + ' time' + (asked === 1 ? '' : 's') + '\n      ' + (await top()) + '\n      ' + (await button()) + '\n      at the backdoor:\n      ' + (await backdoor(2)));
      await shot('again_begun');

      // and after it the page still says what happens in the game
      await type('spider.body.x += 150'); await sleep(1700);
      console.log('\nspider.body.x += 150, in the game after it:\n      ' + (await backdoor(3)) + '\n      ' + (await top()) + '\n      ' + (await button()));

      // the button's ordinary use, in a halt that can be put right: it puts that right, and begins nothing again
      await js("document.querySelector('#how button[data-how=\"on a click\"]').click(); 0"); await sleep(400);
      console.log('\nset to end on a click:\n      ' + (await button()));
      await type('spider.body.x += 150'); await sleep(1700);
      console.log('      ' + (await top()) + '\n      ' + (await button()));
      await js("document.getElementById('right').scrollIntoView({ block: 'nearest' }); 0");
      const [cx, cy] = await js("(() => { const r = document.getElementById('right').getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; })()");
      await mouse('mouseMoved', cx, cy); await mouse('mousePressed', cx, cy, { button: 'left', clickCount: 1 }); await mouse('mouseReleased', cx, cy, { button: 'left', clickCount: 1 });
      await sleep(600);
      console.log('"Put it right" clicked: asked ' + asked + ' times in all\n      ' + (await backdoor(2)) + '\n      ' + (await top()) + '\n      ' + (await button()));
      relay.close(); srv.kill(); await sleep(300);
      console.log('what the server said:\n  ' + said.join('\n').split('\n').join('\n  '));
    },

  };
  await plans[planName]();
  console.log(problems.length ? problems.join('\n') : 'no exceptions, no console errors');
  ws.close(); proc.kill(); process.exit(0);
})();
