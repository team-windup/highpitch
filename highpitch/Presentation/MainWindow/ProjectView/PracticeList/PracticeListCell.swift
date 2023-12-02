//
//  PracticeListCell.swift
//  highpitch
//
//  Created by yuncoffee on 10/23/23.
//

import SwiftUI
import SwiftData
import AVFoundation

struct PracticeListCell: View {
    @Environment(\.modelContext)
    var modelContext
    @Environment(ProjectManager.self)
    private var projectManager
    var practice: PracticeModel
    var index: Int
    @State
    var duration = 0.0
    @State
    var isSelected = false
    
    @Binding
    var selectedPractices: [PracticeModel]
    @Binding
    var refreshable: Bool
    
    var isEditMode: Bool
    // MARK: 모델 변경하고 모델에 반영할꺼
    @State
    var isRemarkable: Bool = false
    
    var body: some View {
        HStack(spacing: .zero) {
            HStack(spacing: .HPSpacing.xsmall) {
                if isEditMode {
                    Toggle(isOn: $isSelected) {
                    }
                    .frame(height: 12)
                    .frame(width: 16, height: 24)
                    .accentColor(Color.HPPrimary.base)
                    .opacity(isEditMode ? 1 : 0)
                    .disabled(!isEditMode)
                } else {
                    Image(systemName: isRemarkable ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isRemarkable ? Color("FEBC2E") : Color.HPTextStyle.light)
                        .frame(height: 12)
                        .frame(width: 16, height: 24)
                        .onTapGesture {
                            isRemarkable.toggle()
                            practice.remarkable = isRemarkable
                            Task {
                                await MainActor.run {
                                    do {
                                        try modelContext.save()
                                        refreshable = true
                                    } catch {
                                        #if DEBUG
                                        print(error)
                                        #endif
                                    }
                                }
                            }
                        }
                }
                Text("\(indexToOrdinalNumber(index: practice.index))번째 연습")
                    .systemFont(.footnote, weight: .medium)
                    .foregroundStyle(Color.HPTextStyle.darker)
            }
            .frame(minWidth: 151, maxWidth: .infinity, alignment: .leading)
            Text("\(Date().createAtToPracticeDate(input: practice.creatAt))")
                .systemFont(.footnote, weight: .medium)
                .foregroundStyle(Color.HPTextStyle.light)
                .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
            Text("\(parseDurationToLabel(duration: duration))")
                .systemFont(.footnote, weight: .medium)
                .foregroundStyle(Color.HPTextStyle.light)
                .frame(minWidth: 80, maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.HPGray.system400)
                .frame(minWidth: 12, maxWidth: 12, minHeight: 12, maxHeight: 12)
                .frame(minWidth: 36, maxWidth: 36, minHeight: 36, maxHeight: 36)
        }
        .frame(minHeight: 56)
        .padding(.leading, .HPSpacing.small)
        .background(index % 2 == 0 ? Color.HPComponent.Detail.background : .clear)
        .padding(.horizontal, .HPSpacing.xxsmall)
        .contentShape(Rectangle())
        .onAppear {
            do {
                duration = try AVAudioPlayer(contentsOf: practice.audioPath!).duration
            } catch {
                #if DEBUG
                print(error)
                #endif            
            }
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                selectedPractices.append(practice)
            } else {
                if let index = selectedPractices.firstIndex(of: practice) {
                    selectedPractices.remove(at: index)
                }
            }
        }
    }
}

extension PracticeListCell {
    private func parseDurationToLabel(duration: Double) -> String {
        var result = ""
        let _duration = Int(duration)
        
        let hour =  _duration / 3600
        let minute = _duration % 3600 / 60
        let second = _duration % 60
        
        if hour > 0 {
            result += "\(hour)시"
        }
        if minute > 0 {
            result += "\(minute)분"
        }
        if second > 0 {
            result += "\(second)초"
        }

        return result
    }

    private func indexToOrdinalNumber(index: Int) -> String {
        let realIndex = index + 1
        if (realIndex == 1) { return "첫" }
        if (realIndex == 20) { return "스무" }
        let firstNum = [
            "",
            "한",
            "두",
            "세",
            "네",
            "다섯",
            "여섯",
            "일곱",
            "여덟",
            "아홉"
        ]
        let secondNum = [
            "",
            "열",
            "스물",
            "서른",
            "마흔",
            "쉰",
            "예순",
            "일흔",
            "여든",
            "아흔"
        ]
        return secondNum[realIndex / 10] + firstNum[realIndex % 10]
    }

}

#Preview {
    var practice = PracticeModel(
        practiceName: "",
        index: 0,
        isVisited: false,
        creatAt: "",
        utterances: [],
        summary: PracticeSummaryModel()
    )
    
    @State
    var selectedPractices: [PracticeModel] = []
    @State
    var isRemarkable: Bool = false
    var isEditMode = false
    
    return PracticeListCell(
        practice: practice,
        index: 0,
        selectedPractices: $selectedPractices,
        refreshable: $isRemarkable, 
        isEditMode: isEditMode
    )
    .padding()
}
