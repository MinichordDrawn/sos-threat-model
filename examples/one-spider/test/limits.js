// Checks the program's limits on what it takes from outside, against a copy of it started here on a port of its own.
// Usage: node limits.js <one-spider.exe> <port>
// It takes a few minutes: several of the checks are waits.
const { spawn } = require('child_process');
const net = require('net');
const [program, portText] = process.argv.slice(2);
const port = Number(portText), host = '127.0.0.1';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const origin = 'http://' + host + ':' + port;

// How many whole answers there are in what has come back: each with its head and as much after it as the head says.
function answers(got) {
  let n = 0, at = 0;
  for (;;) {
    const end = got.indexOf('\r\n\r\n', at);
    if (end < 0) return n;
    const length = /\r\ncontent-length: *(\d+)/i.exec(got.slice(at, end).toString('latin1'));
    if (!length || got.length < end + 4 + Number(length[1])) return n;
    n += 1; at = end + 4 + Number(length[1]);
  }
}
// What is written out by hand is sent, and everything that comes back is kept: until so many whole answers
// have come (one, unless said otherwise; none means for the whole of the wait), the other side closes, or the wait runs out.
function raw(text, waitMs, many) {
  return new Promise(resolve => {
    const s = net.connect(port, host), got = [];
    const done = () => { s.destroy(); resolve(Buffer.concat(got).toString('utf8')); };
    s.on('data', d => { got.push(d); if (many !== 0 && answers(Buffer.concat(got)) >= (many || 1)) done(); }); s.on('close', done); s.on('error', done);
    s.on('connect', () => s.write(text));
    setTimeout(done, waitMs || 1500);
  });
}
const head = extra => 'Host: ' + host + ':' + port + '\r\n' + (extra || '');
const get = (path, extra) => raw('GET ' + path + ' HTTP/1.1\r\n' + head(extra || '') + '\r\n', 3000);
const post = (path, body) => raw('POST ' + path + ' HTTP/1.1\r\n' + head('Origin: ' + origin + '\r\nContent-Length: ' + Buffer.byteLength(body) + '\r\n') + '\r\n' + body, 3000);
const status = reply => (reply.split('\r\n')[0] || '(nothing)');
const bodyOf = reply => reply.slice(reply.indexOf('\r\n\r\n') + 4);
// The last whole frame of the stream.
const frame = async () => { const r = await raw('GET /stream HTTP/1.1\r\n' + head() + '\r\n', 400, 0); const at = r.lastIndexOf('data: {'), end = r.indexOf('\n\n', at); return at < 0 || end < 0 ? null : r.slice(at + 6, end); };
// A connection kept open, with a note of when the other side closed it. One that is stubborn does not
// hang up when the other side does: it stays as it is until it is destroyed here.
function held(first, stubborn) {
  const s = net.connect({ port, host, allowHalfOpen: !!stubborn }), one = { s, closed: null, got: '' };
  s.on('error', () => {}); s.on('data', d => { one.got += d; }); s.on('close', () => { if (one.closed === null) one.closed = Date.now(); });
  if (first) s.on('connect', () => s.write(first));
  return one;
}

(async () => {
  const srv = spawn(program, [String(port)], { stdio: ['ignore', 'pipe', 'pipe'] });
  const said = []; srv.stdout.on('data', d => said.push(String(d))); srv.stderr.on('data', d => said.push('ERR ' + String(d)));
  let ended = false; srv.on('exit', () => { ended = true; });
  await sleep(900);
  const out = [];
  const check = (what, ok, detail) => out.push((ok ? 'ok    ' : 'WRONG ') + what + (detail ? ': ' + detail : ''));
  const note = text => out.push('      ' + text);
  const ask = (command, args) => new Promise(r => { const p = spawn(command, args); let o = ''; p.stdout.on('data', d => o += d); p.on('close', () => r(o)); p.on('error', () => r('')); setTimeout(() => { p.kill(); r(''); }, 15000); });
  const mem = async () => ((await ask('tasklist', ['/FI', 'PID eq ' + srv.pid, '/FO', 'CSV', '/NH'])).split('","')[4] || '?').replace(/["\r\n]/g, '');
  const threads = async () => Number((await ask('powershell', ['-NoProfile', '-Command', '(Get-Process -Id ' + srv.pid + ').Threads.Count'])).trim()) || -1;

  // what is sent with every answer
  const page = await get('/');
  for (const h of ['X-Frame-Options: DENY', "Content-Security-Policy: frame-ancestors 'none'", 'Cross-Origin-Resource-Policy: same-origin', 'X-Content-Type-Options: nosniff', 'Cache-Control: no-store'])
    check('the page is sent with ' + h, page.includes(h));
  const stream = await raw('GET /stream HTTP/1.1\r\n' + head() + '\r\n', 400, 0);
  check('the stream is sent with X-Frame-Options and Cross-Origin-Resource-Policy', stream.includes('X-Frame-Options: DENY') && stream.includes('Cross-Origin-Resource-Policy: same-origin') && stream.includes('data: {'));
  check('a screen is told to ask again a second after it loses the stream', stream.includes('\r\n\r\nretry: 1000\n\n'));

  // where a request comes from
  const taken = await post('/backdoor', 'spider.body.x'); check('a backdoor line from this page is taken', status(taken).includes('200'), bodyOf(taken).slice(0, 40));
  const other = await raw('POST /backdoor HTTP/1.1\r\n' + head('Origin: http://elsewhere.example\r\nContent-Length: 13\r\n') + '\r\nspider.body.x'); check('a backdoor line from another origin is refused', status(other).includes('403'), status(other));
  const none = await raw('POST /backdoor HTTP/1.1\r\n' + head('Content-Length: 13\r\n') + '\r\nspider.body.x'); check('a backdoor line that does not say where it is from is refused', status(none).includes('403'), status(none));
  for (const [what, extra, want] of [
    ['the stream asked for from another site', 'Sec-Fetch-Site: cross-site\r\n', '403'],
    ['the stream asked for from another port of this machine', 'Sec-Fetch-Site: same-site\r\n', '403'],
    ['the stream asked for with another origin', 'Origin: http://elsewhere.example\r\n', '403'],
    ['the stream asked for with no origin at all', 'Origin: null\r\n', '403'],
    ['the stream asked for by the page itself', 'Sec-Fetch-Site: same-origin\r\n', '200'],
  ]) { const r = await raw('GET /stream HTTP/1.1\r\n' + head(extra) + '\r\n', 400, want === '200' ? 0 : 1); check(what + ' is ' + (want === '200' ? 'sent' : 'refused'), status(r).includes(want) && r.includes('data: {') === (want === '200'), status(r)); }
  for (const [what, path, extra, want] of [
    ['the page asked for from another site', '/', 'Sec-Fetch-Site: cross-site\r\n', '403'],
    ['the plans asked for from another site', '/plans', 'Sec-Fetch-Site: cross-site\r\nOrigin: http://elsewhere.example\r\n', '403'],
    ['the page asked for at the address bar', '/', 'Sec-Fetch-Site: none\r\n', '200'],
    ['the plans asked for by the page itself', '/plans', 'Sec-Fetch-Site: same-origin\r\n', '200'],
    ['the page asked for under another name', '/', 'Host: elsewhere.example\r\n', '403'],
  ]) { const r = what.endsWith('another name') ? await raw('GET / HTTP/1.1\r\nHost: elsewhere.example:' + port + '\r\n\r\n', 600) : await get(path, extra); check(what + ' is ' + (want === '200' ? 'sent' : 'refused'), status(r).includes(want), status(r)); }

  // a line of a request has a length, a request so many headers, and what it carries a size
  const long = await raw('GET / HTTP/1.1\r\n' + head('X-Long: ' + 'a'.repeat(20000) + '\r\n') + '\r\n'); check('a header line of 20,000 characters is refused', status(long).includes('400'), status(long) + ' | ' + bodyOf(long));
  // (the program stops reading and closes while the line is still being sent, so the sender may see the connection broken off and not the answer)
  const endless = await raw('GET / HTTP/1.1\r\n' + head('X-Long: ' + 'a'.repeat(3000000)), 2500); check('a header line of 3,000,000 characters with no end is not taken', !status(endless).includes('200'), status(endless));
  const longFirst = await raw('GET /' + 'a'.repeat(20000) + ' HTTP/1.1\r\n' + head() + '\r\n'); check('a first line of 20,000 characters is refused', status(longFirst).includes('400'), status(longFirst));
  const many = await raw('GET / HTTP/1.1\r\n' + head(Array.from({ length: 80 }, (_, k) => 'X-' + k + ': 1\r\n').join('')) + '\r\n'); check('a request with 81 headers is refused', status(many).includes('400'), status(many) + ' | ' + bodyOf(many));
  const some = await get('/', Array.from({ length: 40 }, (_, k) => 'X-' + k + ': 1\r\n').join('')); check('a request with 42 headers is taken', status(some).includes('200'), status(some));
  const heavy = await raw('POST /backdoor HTTP/1.1\r\n' + head('Origin: ' + origin + '\r\nContent-Length: 70000\r\n') + '\r\n' + 'help;'.repeat(100)); check('a request that says it carries 70,000 characters is told that is too much', status(heavy).includes('413'), status(heavy) + ' | ' + bodyOf(heavy));
  const most = await post('/backdoor', ' '.repeat(65000) + 'spider.body.gen'); check('one that carries 65,015 is taken', status(most).includes('200') && bodyOf(most) === '1', status(most) + ' | ' + bodyOf(most).slice(0, 40));
  const two = await raw('GET /plans HTTP/1.1\r\n' + head() + '\r\nPOST /backdoor HTTP/1.1\r\n' + head('Origin: ' + origin + '\r\nContent-Length: 15\r\n') + '\r\nspider.body.gen', 3000, 2);
  check('two requests on one connection are both answered', two.split('HTTP/1.1 200 OK').length === 3 && two.endsWith('\r\n\r\n1'), two.split('HTTP/1.1 200 OK').length - 1 + ' answers');
  note('memory in use after those: ' + await mem());

  // the backdoor: a line and its answer have a size, and so have a text, a line kept for the work, and the list of moths
  const wide = await post('/backdoor', 'world;'.repeat(2000)); check('a line of 2,000 reads is refused whole', bodyOf(wide).includes('no more than 32 are taken at once'), bodyOf(wide).length + ' characters back for 12,000 sent');
  const reads = await post('/backdoor', 'world;spider;'.repeat(16)); check('32 reads of everything are cut where enough has been said', bodyOf(reads).length <= 64200 && bodyOf(reads).includes('... and no more of this is said') && bodyOf(reads).endsWith('of that line were not done'), bodyOf(reads).length + ' characters back');
  const text = await post('/backdoor', 'spider.body.state = "' + 'a'.repeat(1025) + '"'); check('a text of 1,025 characters is not written', bodyOf(text).endsWith('is no longer than 1024 characters'), bodyOf(text).slice(0, 80));
  const kept = await post('/backdoor', 'during spider.body.x +=' + ' '.repeat(1100) + '1'); check('a line of more than 1,024 characters is not kept to be written during the work', bodyOf(kept).endsWith('is no longer than 1024 characters'), bodyOf(kept).slice(0, 80));
  const plain = (await frame() || '').length;
  await post('/how', 'on a click');
  const mark = String.fromCharCode(1).repeat(1024);
  for (const field of ['spider.ring[*].name', 'spider.ring[*].held', 'spider.ring[*].why', 'world.ring[*].name', 'world.ring[*].held', 'world.ring[*].why', 'spider.body.state', 'world.web.torn'])
    await post('/backdoor', field + ' = "' + mark + '"');
  await sleep(200);
  const big = await frame();
  check('with every text made as long as it may be, a frame of the stream stays small', big !== null && big.length < plain + 60000 && JSON.parse(big).halt !== null, (big || '').length + ' characters, and ' + plain + ' before');
  let last = '';
  for (let k = 0; k < 40; k++) last = bodyOf(await post('/backdoor', 'world.moths.push();'.repeat(32)));
  const count = JSON.parse(await frame()).state.world.moths.length;
  check('1,280 moths asked for at the backdoor come to 64', count === 64 && last.includes('no more are put in from here'), 'the list holds ' + count + ' | ' + last.split('\n').pop());
  note('one frame of the stream is now about ' + Math.round(((await frame()) || '').length / 1000) + ' thousand characters');
  await post('/right', ''); await sleep(300);
  const righted = JSON.parse(await frame());
  check('and once it is put right, a frame is as it was', righted.halt === null && JSON.stringify(righted).length < plain + 3000, JSON.stringify(righted).length + ' characters');

  // Lines written during the work that undo one another are let through, and only their beginning is kept to be said.
  // They have to be written in the same round: when they are not, that is a halt put right at once, and it is tried again.
  await post('/how', 'at once');
  const pad = ' '.repeat(990);
  let through = null;
  for (let tries = 0; tries < 30 && through === null; tries++) {
    const was = JSON.parse(await frame()).passed;
    await Promise.all([0, 1, 2, 3, 4, 5, 6, 7].map(k => post('/backdoor', 'during spider.body.x ' + (k % 2 ? '-=' : '+=') + pad + '1')));
    await sleep(150);
    const now = JSON.parse(await frame());
    if (now.passed > was && now.halt === null) through = now;
  }
  check('eight long lines that undo one another are let through with only their beginning kept', through !== null && through.let.length <= 203, through === null ? 'never let through in 30 tries' : through.let.length + ' characters kept');
  const later = await frame();
  check('and a frame of the stream is no larger for it', later !== null && later.length < plain + 3000, (later || '').length + ' characters, and ' + plain + ' before');
  await post('/how', 'after a pause');

  // connections: the newest is taken, and one that is no screen gives up its place: the one
  // that has waited longest with nothing of its own being answered, or else the one answered longest
  await sleep(1000);
  const before = await threads();
  const idle = [];
  for (let k = 0; k < 40; k++) idle.push(held());
  await sleep(700);
  const full = await get('/'); check('with 40 idle connections open, one more is served', status(full).includes('200'), status(full));
  const right = await post('/right', ''); check('and so is a click on "Put it right"', status(right).includes('200'), status(right));
  const slow = [];
  for (let k = 0; k < 40; k++) slow.push(held('POST /backdoor HTTP/1.1\r\n' + head('Origin: ' + origin + '\r\nContent-Length: 15\r\n') + '\r\nspider.'));
  await sleep(700);
  const crowded = await get('/'); check('with 40 more that have each sent half a request, one more is served', status(crowded).includes('200'), status(crowded));
  // Connections that do not hang up when they are put out: each may take as long to be gone as it was allowed to wait.
  const flood = [];
  for (let k = 0; k < 150; k++) flood.push(held(null, true));
  await sleep(1000);
  const some_threads = await threads();
  const through_flood = await post('/backdoor', 'spider.body.gen'); check('with 150 more that do not hang up when they are put out, a backdoor line is taken', status(through_flood).includes('200') && bodyOf(through_flood) === '1', status(through_flood) + ', with ' + some_threads + ' threads');
  // Past 256 held in all, counting those put out and not yet gone, no more are taken until some have gone.
  const flooded = Date.now();
  for (let k = 0; k < 300; k++) flood.push(held(null, true));
  await sleep(1500);
  const most_threads = await threads();
  const shut = await post('/backdoor', 'spider.body.gen');
  check('with 300 more of those, the program holds no more than 256 with their threads, and takes no more', most_threads > before + 200 && most_threads <= before + 256 + 4 && !status(shut).includes('200'), most_threads + ' threads, and ' + before + ' before; a backdoor line: ' + status(shut));
  let back = null;
  while (back === null && Date.now() - flooded < 30000) { if (status(await post('/backdoor', 'spider.body.gen')).includes('200')) back = Date.now(); else await sleep(500); }
  check('and a backdoor line is taken again fifteen seconds or so after they came', back !== null && back - flooded < 19000, back === null ? 'not in 30 s' : 'after ' + ((back - flooded) / 1000).toFixed(1) + ' s');
  // a request that is not all here ten seconds after its first character is given up
  const began = Date.now();
  const half = held('GET / HTTP/1.1\r\n' + head());
  while (half.closed === null && Date.now() - began < 14000) await sleep(100);
  check('half a request is given up ten seconds after it began', half.closed !== null && half.closed - began > 9000 && half.closed - began < 12500 && half.got.includes('408'), half.closed === null ? 'still open after 14 s' : 'closed after ' + ((half.closed - began) / 1000).toFixed(1) + ' s, told ' + status(half.got));
  // a connection with nothing asked on it is closed after fifteen seconds
  const quiet = held(); const opened = Date.now();
  while (quiet.closed === null && Date.now() - opened < 20000) await sleep(100);
  check('a connection on which nothing is asked is closed after fifteen seconds', quiet.closed !== null && quiet.closed - opened > 14000 && quiet.closed - opened < 17500, quiet.closed === null ? 'still open after 20 s' : 'closed after ' + ((quiet.closed - opened) / 1000).toFixed(1) + ' s');
  [...idle, ...slow, ...flood].forEach(one => one.s.destroy());
  let settled = -1, settling = Date.now();
  while (Date.now() - settling < 20000) { settled = await threads(); if (settled > 0 && settled <= before + 2) break; await sleep(1000); }
  check('and when they have all gone, so have their threads', settled > 0 && settled <= before + 2, settled + ' threads after ' + ((Date.now() - settling) / 1000).toFixed(0) + ' s, and ' + before + ' before');

  // screens: the newest is sent the game, and the one that has been sent it longest is put out
  const screens = [];
  for (let k = 0; k < 8; k++) { screens.push(held('GET /stream HTTP/1.1\r\n' + head() + '\r\n')); await sleep(60); }
  await sleep(500);
  check('eight screens are all sent the game', screens.every(one => one.closed === null && one.got.includes('data: {')), screens.filter(one => one.closed === null).length + ' open');
  const ninth = held('GET /stream HTTP/1.1\r\n' + head() + '\r\n');
  await sleep(700);
  check('a ninth is sent the game too, and the first of the eight is put out for it', ninth.closed === null && ninth.got.includes('data: {') && screens[0].closed !== null && screens.slice(1).every(one => one.closed === null), screens.map(one => one.closed === null ? 'open' : 'closed').join(' '));
  [...screens, ninth].forEach(one => one.s.destroy()); await sleep(700);

  // screens that do not read are given up on after the wait, and their threads go
  const quiet_threads = await threads();
  const deaf = [];
  for (let k = 0; k < 8; k++) { const s = net.connect(port, host); s.on('error', () => {}); s.on('connect', () => s.write('GET /stream HTTP/1.1\r\n' + head() + '\r\n')); s.pause(); deaf.push(s); }
  await sleep(1500);
  const with_deaf = await threads();
  let gone = false, waited = 1;
  while (!gone && waited < 90) { await sleep(3000); waited += 3; gone = (await threads()) <= quiet_threads; }
  check('eight screens that do not read are given up on, and their threads go', with_deaf === quiet_threads + 8 && gone, quiet_threads + ' threads before them, ' + with_deaf + ' with them, back to ' + (await threads()) + ' after about ' + waited + ' s');
  deaf.forEach(s => s.destroy());
  // Screens that do not read, eight at a time, each lot putting out the one before while the program is still
  // waiting to write to it. A screen that is slow to go must not keep a place that a connection needs.
  await sleep(500);
  const many_deaf = [], after_each = [];
  for (let lot = 0; lot < 7; lot++) {
    for (let k = 0; k < 8; k++) { const s = net.connect({ port, host, allowHalfOpen: true }); s.on('error', () => {}); s.on('connect', () => s.write('GET /stream HTTP/1.1\r\n' + head() + '\r\n')); s.pause(); many_deaf.push(s); }
    await sleep(2000);
    after_each.push(status(await post('/backdoor', 'spider.body.gen')).replace('HTTP/1.1 ', ''));
  }
  check('after each of seven lots of eight screens that do not read, a backdoor line is taken', after_each.every(one => one.startsWith('200')), after_each.join(' | '));
  const seen_through = await frame();
  check('and a screen is sent the game', seen_through !== null, (await threads()) + ' threads');
  many_deaf.forEach(s => s.destroy());

  // Started with something it does not take: something that is not a port, the port 0, which is none,
  // and a port with something after it. The program must say so and end without starting.
  for (const [what, given] of [['something that is not a port', ['eighty']], ['the port 0', ['0']], ['a port and something more', [String(port + 1), 'more']]]) {
    const refused = await new Promise(r => {
      const p = spawn(program, given, { stdio: ['ignore', 'pipe', 'pipe'] }); let told = '';
      p.stderr.on('data', d => { told += d; }); p.on('exit', code => r({ code, told })); p.on('error', () => r({ code: null, told: '' }));
      setTimeout(() => p.kill(), 5000);
    });
    check('started with ' + what + ', the program says so and ends', refused.code === 2 && refused.told.includes('Usage: one-spider [port]'), 'ended with ' + refused.code + ', saying: ' + refused.told.trim());
  }

  const alive = await post('/backdoor', 'spider.body.gen'); check('the game is still running at the end', status(alive).includes('200') && !ended, bodyOf(alive).slice(0, 40));
  note('memory in use at the end: ' + await mem());
  srv.kill(); await sleep(300);
  console.log(out.join('\n'));
  console.log(out.filter(line => line.startsWith('WRONG')).length + ' wrong of ' + out.filter(line => /^(ok|WRONG)/.test(line)).length);
  console.log('what the program said:\n  ' + said.join('').trim().split('\n').join('\n  '));
  process.exit(0);
})();
