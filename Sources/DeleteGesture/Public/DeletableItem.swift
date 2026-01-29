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
@available(visionOS, unavailable)
public struct DGDeletableItem<Content: View>: View {
    ///Defines the action to execute when the Delete-Point entered
    private var onDelete: () -> Void
    
    ///The View that is deletable
    @ViewBuilder private var content: () -> Content
    
    public init(onDelete deleteAction: @escaping () -> Void, @ViewBuilder content view: @escaping () -> Content){
        self.onDelete = deleteAction
        self.content = view
    }
    
    @Environment(\.scenePhase) private var scenePhase
        
    @State private var offset: CGSize = .zero
    @State private var storedOffset: CGSize = .zero
    
    @State private var totalDistance: CGFloat = 0
    @State private var lastDragLocation: CGPoint?
    
    private var id = UUID()
    
    private var symbolOffset: CGFloat {
        if (offset.width + storedOffset.width) < -55 {
            if min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 {
                return (offset.width + storedOffset.width) + 50 
            }else{
                return -31.5 //Grundoffset, wenn Symbol sichtbar
            }
        }else{
            return -29
        }
    }
    
    @State private var measuredHeight: CGFloat = .zero
    @State private var measuredWidth: CGFloat = .zero
    
    
    public var body: some View {
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
                    .disabled(DeletionStore.shared.displayedObject == id)
                    .overlay{
                        if DeletionStore.shared.displayedObject == id{
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
                                .frame(width: abs(offset.width + storedOffset.width))
                        }
                    }
                }
                .onTapGesture {
                    onDelete()
                }
                HStack{
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
            #if os(iOS)
            .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 && offset.width < 0)
            #elseif os(macOS)
            .sensoryFeedback(.levelChange, trigger: min(measuredWidth, 500) / -(offset.width + storedOffset.width) <= 2 && offset.width < 0)
            #endif
            #if os(macOS)
            .onHorizontalTrackpadScroll(onChanged: {event in
                DeletionStore.shared.displayedObject = id
                if event.scrollingDeltaX < 0 || totalDistance < 0{
                    offset = CGSize(width: min(offset.width + event.scrollingDeltaX, min(measuredWidth, 500)), height: 0)
                }else{
                    offset = .zero
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
                        DeletionStore.shared.displayedObject = nil
                    }
                    offset = .zero
                }
            }, onReset: {
                storedOffset = .zero
                offset = .zero
                DeletionStore.shared.displayedObject = nil
            })
            #else
            .gesture(HorizontalPanGesture(onChanged: {proxy in
                DeletionStore.shared.displayedObject = id
                if proxy.translation(in: proxy.view).x + storedOffset.width < 0 && totalDistance < 5{
                    offset = CGSize(width: proxy.translation(in: proxy.view).x, height: 0)
                }else{
                    offset = .zero
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
                        DeletionStore.shared.displayedObject = nil
                    }
                    lastDragLocation = nil
                    totalDistance = 0
                }
            }))
            #endif
        }
        .onChange(of: DeletionStore.shared.displayedObject){
            if DeletionStore.shared.displayedObject != id && DeletionStore.shared.displayedObject != nil{
                withAnimation{
                    storedOffset = .zero
                    offset = .zero
                }
            }
        }
    }
}
