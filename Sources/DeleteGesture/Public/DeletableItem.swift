//
//  DeletableItem.swift
//  Hausaufgabenplaner
//
//  Created by Samuel Meincke on 21.05.25.
//

import CoreHaptics
import SwiftUI

@available(iOS 18, macOS 15, *)
@available(tvOS, unavailable)
public struct DGDeletableItem<Content: View>: View {
    ///Defines the action to execute when the Delete-Point entered
    private var onDelete: () -> Void
    
    ///The View that is deletable
    @ViewBuilder private var content: () -> Content
    
    public init(onDelete deleteAction: @escaping () -> Void, @ViewBuilder content view: @escaping () -> Content){
        self.onDelete = deleteAction
        self.content = view
    }
    
    @Environment(DeletionStore.self) private var deletionStore
    @Environment(\.scenePhase) private var scenePhase
        
    @State private var offset: CGSize = .zero
    @State private var storedOffset: CGSize = .zero
    
    @State private var playedHaptic = false
    
    
    @State private var totalDistance: CGFloat = 0
    @State private var lastDragLocation: CGPoint?
    
    private var id = UUID()
    
    private var symbolOffset: CGFloat {
        if (offset.width + storedOffset.width) < -55 {
            if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 {
                return (offset.width + storedOffset.width) + 50 
            }else{
                return -30 //Grundoffset, wenn Symbol sichtbar
            }
        }else{
            return -29
        }
    }
    
    @State private var measuredHeight: CGFloat = .zero
    @State private var measuredWidth: CGFloat = .zero
    
    @State private var hapticEngine: CHHapticEngine? = nil
    @State private var hapticPlayer: CHHapticPatternPlayer? = nil
    
    public var body: some View {
//        #if !os(macOS)
        VStack{
            ZStack{
                Rectangle()
                    .opacity(0.0001)
                    .background(
                        GeometryReader { innerProxy in
                            Color.clear
                                .preference(key: ViewHeightKey.self, value: innerProxy.size.height)
                                .preference(key: ViewWidthKey.self, value: innerProxy.size.width)
                        }
                    )
                    .onPreferenceChange(ViewHeightKey.self) { height in
                        self.measuredHeight = height
                        print("Change of height")
                    }
                    .onPreferenceChange(ViewWidthKey.self) { width in
                        self.measuredWidth = width
                    }
                content()
                    .disabled(deletionStore.displayedObject == id)
                    .overlay{
                        if deletionStore.displayedObject == id{
                            Rectangle()
                                .opacity(0.001)
                        }
                    }
                    .offset(offset)
                    .offset(storedOffset)
                HStack{
                    Spacer()
                    ZStack{
                        HStack{
                            Spacer()
                            Capsule()
                                .foregroundStyle(.red)
                                .padding(.trailing)
                                .frame(maxHeight: 50)
                                .frame(width: abs(/*min(*/offset.width/*, 0))*/ + storedOffset.width))
                        }
                    }
                }
                .onTapGesture {
                    onDelete()
                }
                HStack(/*alignment: .trailing*/){
                    Spacer()
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(/*maxWidth: symbolOffset <= -30 ? measuredHeight < 20 ? measuredHeight * 0.8 : 20 : .zero*/ maxHeight: symbolOffset <= -30 ? measuredHeight < 20 ? measuredHeight * 0.8 : 20 : .zero)
                            .foregroundColor(.white)
                            .offset(x: symbolOffset)
                            .animation(.linear(duration: 0.3), value: symbolOffset)
                }
                .onTapGesture {
                    onDelete()
                }
            }
            #if os(macOS)
            .onHorizontalTrackpadScroll(onChanged: {event in
                deletionStore.displayedObject = id
                if event.scrollingDeltaX < 0 || totalDistance < 0{
                    offset = CGSize(width: min(offset.width + event.scrollingDeltaX, min(measuredWidth, 500)), height: 0)
                }else{
                    offset = .zero
                }
                                
                if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 && offset.width < 0{
                    if !playedHaptic{
                        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
                        playedHaptic = true
                    }
                }else{
                    playedHaptic = false
                }
                
                totalDistance += event.scrollingDeltaX
            }, onEnded: {event in
                withAnimation{
                    if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2  && offset.width < 0{
                        onDelete()
                        offset = .zero
                        return
                    }
                    if offset.width + storedOffset.width < -50{
                        storedOffset = CGSize(width: -65, height: 0)
                    }else{
                        storedOffset = .zero
                        deletionStore.displayedObject = nil
                    }
                    offset = .zero
                }
            })
            #else
            .gesture(HorizontalPanGesture(onChanged: {proxy in
                deletionStore.displayedObject = id
                if proxy.translation(in: proxy.view).x + storedOffset.width < 0 && totalDistance < 5{
                    offset = CGSize(width: proxy.translation(in: proxy.view).x, height: 0)
                }else{
                    offset = .zero
                }
                
                if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 && offset.width < 0{
                    if !playedHaptic{
                        #if os(macOS)
                        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
                        playedHaptic = true
                        #else
                        if let hapticPlayer{
                            do{
                                try hapticEngine!.start()
                                try hapticPlayer.start(atTime: 0)
                                playedHaptic = true
                            }catch{
                                print("Haptic player error:", error.localizedDescription)
                            }
                        }
                        #endif
                    }
                }else{
                    playedHaptic = false
                }
                
                if let last = lastDragLocation {
                    let deltaY = abs(proxy.location(in: proxy.view).y - last.y)
                    let deltaX = abs(proxy.location(in: proxy.view).x - last.x)
                    
                    if deltaY > deltaX{
                        totalDistance += deltaY
                    }
                }
                lastDragLocation = proxy.location(in: proxy.view)
            }, onEnded: {proxy in
                withAnimation{
                    if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2  && offset.width < 0 && totalDistance < 5{
                        onDelete()
                        offset = .zero
                        return
                    }
                    offset = .zero
                    if proxy.translation(in: proxy.view).x + storedOffset.width < -60 && totalDistance < 5{
                        storedOffset = CGSize(width: -65, height: 0)
                    }else{
                        storedOffset = .zero
                        deletionStore.displayedObject = nil
                    }
                    lastDragLocation = nil
                    totalDistance = 0
                }
            }))
            #endif
            .onAppear{
                var supportsHaptics: Bool = false
                // Check if the device supports haptics.
                let hapticCapability = CHHapticEngine.capabilitiesForHardware()
                supportsHaptics = hapticCapability.supportsHaptics
                print("Haptic Support: \(supportsHaptics)")
                if supportsHaptics {
                    do {
                        let engine = try CHHapticEngine()
                        
                        engine.resetHandler = {
                            
                            print("Reset Handler: Restarting the engine.")
                            
                            do {
                                // Try restarting the engine.
                                try self.hapticEngine!.start()
                                        
                                // Register any custom resources you had registered, using registerAudioResource.
                                // Recreate all haptic pattern players you had created, using createPlayer.


                            } catch {
                                fatalError("Failed to restart the engine: \(error)")
                            }
                        }
                        
                        engine.stoppedHandler = { reason in
                            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
                            switch reason {
                            case .audioSessionInterrupt: print("Audio session interrupt")
                            case .applicationSuspended: print("Application suspended")
                            case .idleTimeout: print("Idle timeout")
                            case .systemError: print("System error")
                            case .notifyWhenFinished:
                                print("Notify when finished")
                            case .engineDestroyed:
                                print("Engine destroyed")
                            case .gameControllerDisconnect:
                                print("Game controller disconnected")
                            @unknown default:
                                print("Unknown error")
                            }
                        }

                        hapticEngine = engine
                        do{
                            let hapticDict = [
                                CHHapticPattern.Key.pattern: [
                                    [CHHapticPattern.Key.event: [
                                        CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                                        CHHapticPattern.Key.time: CHHapticTimeImmediate,
                                        CHHapticPattern.Key.eventDuration: 1.0]
                                    ]
                                ]
                            ]
                            let pattern = try CHHapticPattern(dictionary: hapticDict)
                            
                            hapticPlayer = try hapticEngine!.makePlayer(with: pattern)
                        }catch{
                            print("Engine Error: \(error)")
                        }
                        
                    } catch let error {
                        fatalError("Engine Creation Error: \(error)")
                    }
                }
            }
        }
        .onChange(of: deletionStore.displayedObject){
            if deletionStore.displayedObject != id && deletionStore.displayedObject != nil{
                withAnimation{
                    storedOffset = .zero
                    offset = .zero
                }
            }
        }
    }
}
