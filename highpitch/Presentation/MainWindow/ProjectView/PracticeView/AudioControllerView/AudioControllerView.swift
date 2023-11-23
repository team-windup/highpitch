//
//  AudioControllerView.swift
//  highpitch
//
//  Created by yuncoffee on 10/14/23.
//

import SwiftUI
import Sliders

struct AudioControllerView: View {
    private var audioPlayer : AudioPlayable
    private var audioPath: URL
    @State var currentTime = 0.0
    @State var isPlaying = false
    @State var isDragging = false
    @State var prevState = false
    @State private var prevAnimationsRunning = false
    @State private var nextAnimationsRunning = false
    
    init(
        audioPlayer: AudioPlayable,
        audioPath: URL
    ) {
        self.audioPlayer = audioPlayer
        self.audioPath = audioPath
    }
    var body: some View {
        ZStack {
            sliderContainer
            buttonContainer
        }
        .padding(.bottom, .HPSpacing.xsmall)
        .frame(maxWidth: .infinity, maxHeight: 64, alignment: .top)
        .background(Color.HPComponent.audioControllerBackground)
        .background(.ultraThinMaterial)
        //        .border(.HPComponent.stroke, width: 1, edges: [.top])
        .onAppear {
            currentTime = audioPlayer.currentTime
            //settingAudio(filePath: audioPath)
        }.onChange(of: audioPlayer.currentTime) { _, newValue in
            self.currentTime = newValue
            if newValue == 0 {
                audioPlayer.pausePlaying()
            }
        }.onChange(of: isDragging) { _, newValue in
            if newValue {
                audioPlayer.pausePlaying()
            } else {
                if prevState {
                    audioPlayer.play()
                }
            }
        }.onChange(of: audioPlayer.isPlaying) { _, newValue in
            isPlaying = newValue
        }.onDisappear {
            audioPlayer.stopPlaying()
        }
    }
}

extension AudioControllerView {
    /// 음성파일 URL을 MediaManager에 등록
//    private func settingAudio(filePath: URL) {
//        do {
//            try audioPlayer.registerAudio(url: filePath)
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    private func play() {
        audioPlayer.play()
    }
    private func pause() {
        audioPlayer.pausePlaying()
    }
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
}

// MARK: - Views
extension AudioControllerView {
    @ViewBuilder
    private var sliderContainer: some View {
        ZStack(alignment: .top) {
            // decoration
            Rectangle()
                .frame(maxHeight: 4)
                .foregroundStyle(Color.HPGray.system200)
//                .offset(y: .HPSpacing.xxxxsmall)
            VStack(spacing: .zero) {
                HPSlider(value: $currentTime, bounds: 0...audioPlayer.getDuration()) { edit in
                    if edit {
                        isDragging = true
                        prevState = isPlaying
                    } else {
                        isDragging = false
                        audioPlayer.setCurrentTime(time: currentTime)
                    }
                }
                ValueSlider(value: $currentTime, in: 0...audioPlayer.getDuration()) { edit in
                    if edit {
                        isDragging = true
                        prevState = isPlaying
                    } else {
                        isDragging = false
                        audioPlayer.setCurrentTime(time: currentTime)
                    }
                }
                .valueSliderStyle(
                    HorizontalValueSliderStyle(
                        track: HorizontalTrack(view: Color.HPPrimary.base)
                            .frame(height: 4)
                            .background(Color.HPGray.system400)
                            .cornerRadius(4),
                        thumbSize: CGSize(width: 16, height: 16)
                    )
                )
                .padding(.horizontal, .HPSpacing.xxxsmall)
                HStack(spacing: 0) {
                    Text(timeString(time: currentTime))
                        .systemFont(.caption2)
                        .foregroundStyle(Color.HPTextStyle.light)
                    Spacer()
                    Text(timeString(time: audioPlayer.getDuration()))
                        .systemFont(.caption2)
                        .foregroundStyle(Color.HPTextStyle.light)
                }
                .padding(.horizontal, .HPSpacing.xxxsmall)
                .offset(y: -.HPSpacing.xxsmall)
            }
            .offset(y: -.HPSpacing.xsmallBetweenSmall)
        }
    }
    
    @ViewBuilder
    private var buttonContainer: some View {
        HStack(spacing: .HPSpacing.medium) {
            goBackward
            controllButton
            goForward
        }
    }
    
    @ViewBuilder
    private var controllButton: some View {
        Button {
            isPlaying ? pause() : play()
        } label: {
            Label(
                isPlaying
                ? "멈춤"
                : "재생",
                systemImage: isPlaying
                ? "pause.fill"
                : "play.fill"
            )
            .systemFont(.largeTitle)
            .labelStyle(.iconOnly)
            //            .symbolEffect(.bounce, value: isPlaying)
            .contentTransition(.symbolEffect(.replace))
            .foregroundStyle(Color.HPTextStyle.base)
            .imageScale(.large)
        }
        .frame(width: 24, height: 24)
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var goForward: some View {
        Button {
            audioPlayer.playAfter(second: 10)
            nextAnimationsRunning.toggle()
        } label: {
            Label("앞으로 10초",
                  systemImage: "goforward.10"
            )
            .systemFont(.subTitle, weight: .regular)
            .symbolEffect(.bounce, value: nextAnimationsRunning)
            .labelStyle(.iconOnly)
            .foregroundStyle(Color.HPTextStyle.base)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var goBackward: some View {
        Button {
            audioPlayer.playAfter(second: -10)
            prevAnimationsRunning.toggle()
        } label: {
            Label("뒤로 10초",
                  systemImage: "gobackward.10"
            )
            .systemFont(.subTitle, weight: .regular)
            .symbolEffect(.bounce, value: prevAnimationsRunning)
            .labelStyle(.iconOnly)
            .foregroundStyle(Color.HPTextStyle.base)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "20231107202138", withExtension: "m4a")
    
    return AudioControllerView(audioPlayer: MediaManager(),audioPath: url!)
        .border(.green)
        .frame(width: 640)
    //        .padding(24)
}
