//
//  SpeedPanelView.swift
//  highpitch
//
//  Created by 이재혁 on 11/13/23.
//

import SwiftUI

struct SpeedPanelView: View {
    private let DEFUALT_SPEED = SystemManager.shared.spmAverage
    
    var panelController: PanelController
    var instantFeedbackManager = SystemManager.shared.instantFeedbackManager
    
    let SPEED_PANEL_INFO = SystemManager.shared.instantFeedbackManager.SPEED_PANEL_INFO
    let XMARK_RADIUS = SystemManager.shared.instantFeedbackManager.PANEL_XMARK_RADIUS
    let XMARK_WIDTH = SystemManager.shared.instantFeedbackManager.PANEL_XMARK_CIRCLE_WIDTH
    
    private var realTimeRate: Double {
        instantFeedbackManager.speechRecognizerManager?.realTimeRate ?? 0
    }
    
    private var isSpeaking: Bool {
        instantFeedbackManager.speechRecognizerManager?.isSpeaking ?? false
    }
    
    private var underSpeedRate: Double {
        calcSpeedRate(rate: DEFUALT_SPEED - 104.1)
    }
    
    private var overSpeedRate: Double {
        calcSpeedRate(rate: DEFUALT_SPEED + 131.7)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: .zero) {
                ZStack {
                    speedIndicatorTrack()
                    if isSpeaking {
                        speedIndicator(percent: calcSpeedRate(rate: realTimeRate))
                    }
                    Text("말 빠르기")
                        .systemFont(.caption)
                        .foregroundColor(Color.HPGray.systemWhite.opacity(0.6))
                        .offset(y: 24)
                }
            }
            .offset(y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.HPGray.systemBlack.opacity(0.4))
            .background(.ultraThickMaterial)
            .edgesIgnoringSafeArea(.all)
            .clipShape(RoundedRectangle(cornerRadius: .HPCornerRadius.large))
        }
        .frame(
            width: SPEED_PANEL_INFO.size.width,
            height: SPEED_PANEL_INFO.size.height
        )
        .overlay {
            ZStack(alignment: .topTrailing) {
                if instantFeedbackManager.focusedPanel == .speed {
                    Button {
                        if instantFeedbackManager.activePanels.contains(InstantPanel.speed) {
                            instantFeedbackManager.activePanels.remove(InstantPanel.speed)
                        }
                    } label: {
                        Circle()
                            .fill(Color.HPPrimary.lightness)
                            .stroke(Color.HPPrimary.base, lineWidth: XMARK_WIDTH)
                            .frame(width: XMARK_RADIUS * 2, height: XMARK_RADIUS * 2)
                            .overlay {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: XMARK_RADIUS, height: XMARK_RADIUS)
                                    .fontWeight(.black)
                                    .foregroundStyle(Color.HPPrimary.base)
                            }
                    }
                    .buttonStyle(.plain)
                    .offset(
                        x: SPEED_PANEL_INFO.size.width / 2 - XMARK_WIDTH,
                        y: XMARK_WIDTH - (SPEED_PANEL_INFO.size.height / 2)
                    )
                }
            }
        }
        .onHover { value in
            if value {
                instantFeedbackManager.focusedPanel = .speed
            } else {
                // Hover Out 되었을때, 해당 위치를 UserDefaults에 넣는다.
                UserDefaults.standard.set(
                    Int(panelController.panel?.frame.origin.x ?? 0),
                    forKey: "SpeedPanelX"
                )
                UserDefaults.standard.set(
                    Int(panelController.panel?.frame.origin.y ?? 0),
                    forKey: "SpeedPanelY"
                )
                
                instantFeedbackManager.focusedPanel = nil
                
                instantFeedbackManager.userDefaultsPanelPosition[2] = Int(panelController.panel?.frame.origin.x ?? 0)
                instantFeedbackManager.userDefaultsPanelPosition[3] = Int(panelController.panel?.frame.origin.y ?? 0)
            }
        }
        .frame(
            width:
                instantFeedbackManager.getTotalFrameWidth(
                    width: SPEED_PANEL_INFO.size.width,
                    padding: XMARK_RADIUS
                ),
            height:
                instantFeedbackManager.getTotalFrameWidth(
                    width: SPEED_PANEL_INFO.size.height,
                    padding: XMARK_RADIUS
                )
        )
        .onAppear {
//            #if PREVIEW
//            instantFeedbackManager.speechRecognizerManager = SpeechRecognizerManager()
//            instantFeedbackManager.speechRecognizerManager?.realTimeFillerCount = 3
//            #endif
        }
    }
}

extension SpeedPanelView {
    private func calcSpeedRate(rate: Double) -> Double {
        let result = rate / (DEFUALT_SPEED * 4 / 100)
        return result < 0 ? 0 : result > 50 ? 50 : result
    }
}

extension SpeedPanelView {
    func speedIndicator(percent: Double = 25) -> some View {
        RingShape(
            percent: percent,
            startAngle: 180,
            drawnClockwise: false
        )
        .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
        .fill(
            percent < underSpeedRate
            ? Color("00A3FF").opacity(0.5)
            : percent > overSpeedRate
            ? Color.HPOrange.light
            : Color.HPGreen.light
        )
        .frame(width: 68, height: 68)
        .animation(.bouncy, value: realTimeRate)
        .animation(.bouncy, value: isSpeaking)
    }
    func speedIndicatorTrack() -> some View {
        RingShape(
            percent: 50,
            startAngle: 180,
            drawnClockwise: false
        )
        .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
        .fill(Color("000000").opacity(0.1))
        .frame(width: 68, height: 68)
        .overlay {
            RingShape(
                percent: 50,
                startAngle: 180,
                drawnClockwise: false
            )
            .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
            .fill(Color("FFFFFF").opacity(0.2))
            .frame(width: 69, height: 69)
        }
    }
}

#Preview {
    SpeedPanelView(
        panelController:
            PanelController(
                xpos: -120,
                ypos: 120,
                width: 132,
                height: 132
            )
    )
    .frame(maxWidth: 132, maxHeight: 132)
    .padding(64)
}
