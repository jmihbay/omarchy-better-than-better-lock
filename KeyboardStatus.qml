import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import "KeyboardState.js" as KeyboardState

Row {
  id: root
  property string capsLockLabel: ""
  property bool active: false
  property bool showLayout: true
  property bool showCapsLock: true
  readonly property bool queryActive: active && (showLayout || showCapsLock)
  property var state: ({ label: "—", capsLock: false })
  property string preferredKeyboard: ""
  property bool pending: false
  spacing: Style.space(18)

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function refresh() {
    if (!queryActive) return
    if (query.running) { pending = true; return }
    query.running = true
  }
  function refreshSoon() { settle.restart() }
  onQueryActiveChanged: if (queryActive) refreshSoon()
  Timer { id: settle; interval: 50; onTriggered: root.refresh() }
  // Only poll while the lock/preview is showing; Caps Lock has no Hyprland IPC event.
  Timer { interval: 1000; running: root.queryActive; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
  Timer { id: deadline; interval: 2000; onTriggered: query.signal(9) }
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!root.queryActive || !event) return
      if (event.name === "activelayout") {
        root.preferredKeyboard = String(event.data || "").split(",")[0]
        root.refreshSoon()
      } else if (event.name === "configreloaded") root.refreshSoon()
    }
  }
  Process {
    id: query
    command: ["/usr/bin/hyprctl", "-j", "devices"]
    clearEnvironment: true
    environment: ({
      "HYPRLAND_INSTANCE_SIGNATURE": Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"),
      "XDG_RUNTIME_DIR": Quickshell.env("XDG_RUNTIME_DIR")
    })
    onRunningChanged: if (running) deadline.restart(); else deadline.stop()
    property string output: ""
    property bool overflowed: false
    stdout: SplitParser {
      onRead: function(data) {
        if (query.overflowed) return;
        if (query.output.length + data.length > 65536) {
          query.overflowed = true;
          query.signal(9);
          return;
        }
        query.output += data + "\n";
      }
    }
    onStarted: { output = ""; overflowed = false; }
    onExited: function(exitCode) {
      try {
        if (exitCode !== 0 || overflowed) throw new Error("keyboard query failed");
        root.state = KeyboardState.fromDevices(JSON.parse(output), root.preferredKeyboard);
      } catch (error) { root.state = ({ label: "—", capsLock: false }); }
      if (root.pending) { root.pending = false; root.refreshSoon(); }
    }
  }

  Text {
    objectName: "lockKeyboardLayout"
    textFormat: Text.PlainText
    visible: root.showLayout
    text: root.state.label
    color: Commons.Color.lock.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
  Text {
    objectName: "lockCapsLock"
    textFormat: Text.PlainText
    visible: root.showCapsLock && root.state.capsLock
    text: root.capsLockLabel || strings.t("lock.capsLockOn")
    color: Commons.Color.accent
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    font.bold: true
  }
}
