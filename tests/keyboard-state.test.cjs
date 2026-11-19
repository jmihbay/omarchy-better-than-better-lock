const { test } = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');
const context = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../KeyboardState.js'), 'utf8'), context);
const read = (devices, preferred = '') => JSON.parse(JSON.stringify(context.fromDevices(devices, preferred)));
const keyboard = (extra = {}) => ({name: 'at-translated-set-2-keyboard', main: true, layout: 'us,ru', active_layout_index: 0, capsLock: false, ...extra});
test('shows current physical layout and Caps Lock', () => {
 assert.deepEqual(read({keyboards:[keyboard()]}), {label:'EN', capsLock:false});
 assert.deepEqual(read({keyboards:[keyboard({active_layout_index:1,capsLock:true})]}), {label:'RU', capsLock:true});
});
test('ignores virtual keyboards and unrelated input devices', () => {
 assert.deepEqual(read({keyboards:[keyboard({name:'hl-virtual-keyboard',capsLock:true}),keyboard()]}), {label:'EN',capsLock:false});
});
test('follows the physical keyboard from the last layout event', () => {
 assert.equal(read({keyboards:[keyboard(),keyboard({name:'usb-keyboard',main:false,active_layout_index:1})]},'usb-keyboard').label,'RU');
});
test('Caps Lock on another physical keyboard still warns', () => {
 assert.equal(read({keyboards:[keyboard(),keyboard({name:'usb-keyboard',capsLock:true})]}).capsLock,true);
});
test('missing and malformed device lists fail safely', () => {
 for (const devices of [null,{}, {keyboards:null}, {keyboards:'bad'}, {keyboards:[null,{}]}])
  assert.deepEqual(read(devices),{label:'—',capsLock:false});
});
test('unknown layout labels remain plain text and bounded', () => {
 const result=read({keyboards:[keyboard({layout:'<img src=evil.invalid>'})]});
 assert.ok(result.label.length <= 12);
});
