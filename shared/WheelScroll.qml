import QtQuick

// Wheel scrolling with a step you can feel.
//
// Qt's own Flickable wheel scroll is `wheelScrollLines * 24` pixels per notch,
// which is 72 px on a default desktop -- about one message row here. Worse,
// when notches arrive quickly each one cancels the flick animation the last
// one started, so spinning the wheel travels far less than the sum of the
// notches (five quick notches move ~200 px instead of 360).
//
// So the wheel is handled here instead: a fixed, predictable step per notch
// that never cancels itself. The angle delta is what a notch is measured in
// (120 units); Hyprland also reports a small pixel delta with every notch, and
// preferring that is what made this crawl at 15 px. Pixel deltas are only used
// when there is no angle delta at all. At either end of the content the step
// is handed to the next scroller out (the bar popup's body, say) rather than
// being swallowed, which is what an enclosing Flickable would have done.
WheelHandler {
  id: root

  // The Flickable/ListView to scroll.
  property Flickable flickable: null
  // Pixels per wheel notch. One notch is 120 units of angle delta.
  property real step: 160
  // Multiplier for pixel deltas (high-resolution wheels and touchpads).
  property real pixelFactor: 1.0

  acceptedDevices: PointerDevice.AllDevices
  orientation: Qt.Vertical
  // Take the notch whole: without this the Flickable would scroll it as well,
  // and the list would jump twice as far.
  blocking: true

  // Emitted when this scroller itself moved, with the wheel delta that did it
  // (positive = towards earlier content). A view that follows the end uses it
  // to stop following as soon as the user scrolls away.
  signal stepped(real dy)

  // The next Flickable up the tree, for a list nested in another scroller.
  function enclosing(item) {
    var p = item ? item.parent : null
    while (p) {
      if (p.contentY !== undefined && p.contentHeight !== undefined && p.flicking !== undefined)
        return p
      p = p.parent
    }
    return null
  }

  // Move f by dy pixels; false when it is already at the end that way.
  function scrollBy(f, dy) {
    if (!f) return false
    var minY = f.originY
    var maxY = Math.max(minY, f.originY + f.contentHeight - f.height)
    var target = Math.max(minY, Math.min(maxY, f.contentY - dy))
    if (target === f.contentY) {
      // A ListView's contentHeight is an estimate until the delegates at the
      // end exist, so being at the estimate can still be short of the real
      // end. Let the view anchor itself, and keep the notch for the list
      // while it says it is not at the end.
      if (dy < 0 && f.positionViewAtEnd !== undefined && !f.atYEnd) {
        f.positionViewAtEnd()
        return true
      }
      return false
    }
    f.cancelFlick()   // do not fight a flick that is still running
    f.contentY = target
    // Same estimate: land the last notch on the real end, not on the guess.
    if (dy < 0 && target >= maxY && f.positionViewAtEnd !== undefined)
      f.positionViewAtEnd()
    return true
  }

  onWheel: function(wheel) {
    // A notch is an angle delta. Hyprland sends one with every click of the
    // wheel *and* a small pixel delta alongside it; the angle is the one that
    // describes the notch, so it wins whenever it is there.
    var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y / 120 * root.step
                                      : wheel.pixelDelta.y * root.pixelFactor
    if (dy === 0) return
    var f = root.flickable
    var direct = true
    while (f && !root.scrollBy(f, dy)) {
      f = root.enclosing(f)
      direct = false
    }
    if (direct && f) root.stepped(dy)
    wheel.accepted = true
  }
}
