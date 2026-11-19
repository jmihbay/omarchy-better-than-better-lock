function fromDevices(devices, preferred) {
  var keyboards = (devices && Array.isArray(devices.keyboards) ? devices.keyboards : []).filter(function(k) {
    return k && typeof k.name === "string" && !/^(hl-virtual-keyboard|power-button|sleep-button|lid-switch|video-bus)/.test(k.name)
      && !/(consumer-control|system-control|hotkeys|avrcp|mouse-keyboard)/.test(k.name);
  });
  var keyboard = keyboards.find(function(k) { return k.name === preferred; })
    || keyboards.find(function(k) { return k.main; })
    || keyboards.find(function(k) { return /keyboard|gaming-kb/.test(k.name); })
    || keyboards[0];
  if (!keyboard) return { label: "—", capsLock: false };
  var layouts = String(keyboard.layout || "").split(",").map(function(s) { return s.trim(); });
  var code = layouts[Number(keyboard.active_layout_index || 0)] || "";
  var label = ({ us: "EN", gb: "EN", ru: "RU" })[code] || code.toUpperCase() || String(keyboard.active_keymap || "—");
  return { label: label.slice(0, 12), capsLock: keyboards.some(function(k) { return k.capsLock === true; }) };
}
