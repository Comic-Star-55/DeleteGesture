//
//  HorizontalPanGesture.swift
//  Hausaufgabenplaner
//
//  Created by Samuel Meincke on 07.10.25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if !os(macOS) && !os(visionOS)
/// Ein universeller horizontaler Drag-GestureRecognizer für SwiftUI.
/// Gibt dieselben Werte wie eine native DragGesture zurück.
/// Erkennt nur horizontale Bewegungen, lässt vertikales Scrollen zu.
struct HorizontalPanGesture: UIGestureRecognizerRepresentable {
    var onChanged: (UIPanGestureRecognizer) -> Void
    var onEnded: (UIPanGestureRecognizer) -> Void
    
    // SwiftUI 6+: neuer Initialisierer mit CoordinateSpaceConverter
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator(parent: self, converter: converter)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, converter: nil)
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan)
        )
        recognizer.delegate = context.coordinator
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let parent: HorizontalPanGesture
        let converter: CoordinateSpaceConverter?
        
        private var startLocation: CGPoint = .zero
        private var lastValue: UIPanGestureRecognizer?
        
        init(parent: HorizontalPanGesture, converter: CoordinateSpaceConverter?) {
            self.parent = parent
            self.converter = converter
        }
        
        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            let view = recognizer.view
            let location = recognizer.location(in: view)
            
            // Startpunkt merken
            if recognizer.state == .began {
                startLocation = location
            }
            
            switch recognizer.state {
            case .began, .changed:
                parent.onChanged(recognizer)
                lastValue = recognizer
            case .ended, .cancelled, .failed:
                parent.onEnded(lastValue ?? recognizer)
                lastValue = nil
            default:
                break
            }
        }
        
        // ScrollView darf gleichzeitig scrollen
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
        // Nur horizontale Bewegungen starten
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}
#endif

#if os(macOS)
import SwiftUI
import AppKit

/// Modifier, der horizontale Trackpad-Scrolls (z. B. zwei-Finger-Wisch) erkennt.
@available(macOS 10.15, *)
struct HorizontalTrackpadScrollModifier: ViewModifier {
    let onChanged: (NSEvent) -> Void      // Δ seit letztem Event
    let onEnded: (NSEvent) -> Void        // Aufruf wenn Scroll endet (inkl. momentum end)
    @State private var monitor: Any? = nil
    @State private var accumulating = false

    func body(content: Content) -> some View {
        content
            .background(TrackpadScrollHost(onChanged: onChanged, onEnded: onEnded))
    }

    private struct TrackpadScrollHost: NSViewRepresentable {
        let onChanged: (NSEvent) -> Void
        let onEnded: (NSEvent) -> Void

        func makeNSView(context: Context) -> NSView {
            let v = NSView(frame: .zero)
            v.wantsLayer = true
            // Lokalen Event-Monitor pro View-Instanz hinzufügen
            context.coordinator.install(in: v)
            return v
        }

        func updateNSView(_ nsView: NSView, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(onChanged: onChanged, onEnded: onEnded)
        }

        @MainActor class Coordinator {
            let onChanged: (NSEvent) -> Void
            let onEnded: (NSEvent) -> Void
            var monitor: Any?
            var lastMomentumPhase: NSEvent.Phase = []
            // optional: kleines Debounce/Timer um sicherzustellen dass "ended" ausgelöst wird
            var endWorkItem: DispatchWorkItem?

            init(onChanged: @escaping (NSEvent) -> Void, onEnded: @escaping (NSEvent) -> Void) {
                self.onChanged = onChanged
                self.onEnded = onEnded
            }

            func install(in view: NSView) {
                // entferne alten Monitor, falls vorhanden
                removeMonitor()
                // Local monitor, damit andere Views weiterhin Events erhalten
                monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self, weak view] event in
                    guard let self = self,
                          let view = view,
                          let window = view.window,
                          event.window === window else {
                        return event // Event ignorieren
                    }

                    let locationInWindow = event.locationInWindow
                    let pointInView = view.convert(locationInWindow, from: nil)
                    guard view.bounds.contains(pointInView) else {
                        return event // Event betrifft nicht unsere View
                    }

                    // Apple hardware: continuous two-finger trackpad -> continuous scroll type
                    // event.momentumPhase hilft, Ende des Scrolls zu erkennen
                    self.endWorkItem?.cancel()

                    // begin detection: momentumPhase == .began OR phase != .changed? Use momentumPhase for momentum
                    // wir rufen onChanged jedes Mal mit ΔX auf
//                    if dx != 0 {
//                        self.onChanged(dx)
//                    }
                    if ![NSEvent.Phase.began, NSEvent.Phase.changed].contains(event.momentumPhase){
                        onChanged(event)
                    }
                    // Wenn momentumPhase == .ended oder phase == .ended -> call ended immediately
                    if event.phase == .ended && event.phase != .stationary{
                        self.onEnded(event)
                    } /*else {
                        // Fallback: schedule a short timeout to consider scroll ended (z. B. 120ms)
                        let work = DispatchWorkItem { [weak self] in
                            self?.onEnded(event)
                        }
                        self.endWorkItem = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
                    }*/

                    return event // weiter durchreichen
                }
            }

            func removeMonitor() {
                if let m = monitor {
                    NSEvent.removeMonitor(m)
                    monitor = nil
                }
                endWorkItem?.cancel()
                endWorkItem = nil
            }

            isolated deinit {
                removeMonitor()
            }
        }
    }
}

@available(macOS 10.15, *)
extension View {
    func onHorizontalTrackpadScroll(onChanged: @escaping (NSEvent) -> Void,
                                    onEnded: @escaping (NSEvent) -> Void) -> some View {
        modifier(HorizontalTrackpadScrollModifier(onChanged: onChanged, onEnded: onEnded))
    }
}

#endif

