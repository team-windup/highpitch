//
//  StatisticsTabItem.swift
//  highpitch
//
//  Created by yuncoffee on 10/14/23.
//

import SwiftUI

struct ProjectOutLine: View {
    @Environment(ProjectManager.self)
    private var projectManager
    
    var body: some View {
        if let practices = projectManager.current?.practices.sorted(by: { $0.creatAt < $1.creatAt }) {
            if (practices.count != 0) {
                /// 연습 진행 기간
                let startDate = Date().createAtToYMD(input: practices.first!.creatAt)
                let endDate = Date().createAtToYMD(input: practices.last!.creatAt)
                let practiceDuration = "\(startDate) - \(endDate)"
                
                ScrollView {
                    VStack(alignment:.leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("총 \(practices.count)번의 연습에 대한 결과에요")
                                .systemFont(.largeTitle)
                                .foregroundStyle(Color.HPTextStyle.darker)
                            Text("\(practiceDuration) 동안 연습했어요")
                                .systemFont(.body)
                                .foregroundStyle(Color.HPTextStyle.base)
                        }
                        .padding(.bottom, .HPSpacing.xsmall)
                        HStack(spacing: .HPSpacing.xxxsmall + .HPSpacing.xxsmall) {
                            HStack(spacing: .HPSpacing.xxxsmall + .HPSpacing.xxsmall) {
                                speakingRateView(practices: practices)
                                fillerWordCountView(practices: practices)
                            }
                            fillerWordTOP3View(practices: practices)
                        }
                        .padding(.bottom, .HPSpacing.small)
                        ProjectFWPMChart()
                            .padding(.bottom, .HPSpacing.small)
                        ProjectSpeakingRateChart()
                            .padding(.bottom, .HPSpacing.small)
                        ProjectLengthChart()
                            .padding(.bottom, .HPSpacing.small)
                    }
                    .padding(.horizontal, .HPSpacing.medium)
                }
            } else { emptyView }
        } else { emptyView }
    }
}

extension ProjectOutLine {
    // MARK: - functions
    /// speakingRage(SPM)을 반환합니다.
    func returnSpeakingRate(practices: [PracticeModel]) -> Int {
        var answer = 0.0
        for practice in practices {
            answer += practice.summary.spmAverage
        }
        answer /= Double(practices.count)
        return Int(answer)
    }
    
    /// fwpmAverage를 반환합니다.
    func returnFWPMAverage(practices: [PracticeModel]) -> Double {
        var answer = 0.0
        for practice in practices {
            answer += practice.summary.fwpm
        }
        answer /= Double(practices.count)
        return answer
    }
    
    /// fillerWordTOP3를 반환합니다.
    func returnfillerWordTOP3(practices: [PracticeModel]) -> [(key: String, value: Int)] {
        var answer: [String: Int] = [:]
        for practice in practices {
            for fillerWord in practice.summary.eachFillerWordCount {
                if answer[fillerWord.fillerWord] == nil {
                    answer[fillerWord.fillerWord] = fillerWord.count
                } else {
                    answer[fillerWord.fillerWord] = answer[fillerWord.fillerWord]! + fillerWord.count
                }
            }
        }
        var sortedAnswer = answer.sorted { $0.1 > $1.1 }
        while !sortedAnswer.isEmpty && sortedAnswer.last!.value == 0 { _ = sortedAnswer.popLast() }
        while sortedAnswer.count > 3 { _ = sortedAnswer.popLast() }
        return sortedAnswer
    }
}

extension ProjectOutLine {
    // MARK: - emptyView
    @ViewBuilder
    var emptyView: some View {
        VStack(spacing: .zero) {
            Text("연습 기록이 없어요")
                .systemFont(.body, weight: .semibold)
                .foregroundStyle(Color.HPTextStyle.base)
            Text("첫번째 연습을 시작해보세요")
                .systemFont(.caption, weight: .semibold)
                .foregroundStyle(Color.HPTextStyle.light)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - speakingRateView
    func speakingRateView(practices: [PracticeModel]) -> some View {
        let speakingRate = returnSpeakingRate(practices: practices)
        return VStack(spacing: 0) {
            Text("평균 말 빠르기")
                .systemFont(.body)
                .foregroundColor(Color.HPTextStyle.darker)
            Text("\(speakingRate)SPM")
                .systemFont(.largeTitle)
                .foregroundColor(Color.HPPrimary.base)
            Text(speakingRate >= 410
                 ? "빠른 편이에요"
                 : speakingRate >= 370
                 ? "조금 빠른 편이에요"
                 : speakingRate >= 330
                 ? "적절한 빠르기에요"
                 : speakingRate >= 290
                 ? "조금 느린 편이에요"
                 : "느린 편이에요"
            )
            .systemFont(.caption)
            .foregroundColor(Color.HPTextStyle.light)
        }
        .frame(minWidth: 50, maxWidth: .infinity, minHeight: 124, maxHeight: 124, alignment: .center)
        .background(Color.HPComponent.Section.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.HPComponent.shadowColor ,radius: 10, y: .HPSpacing.xxxxsmall)
        .overlay(alignment: .topTrailing) {
            HPTooltip(tooltipContent: "평균 말 빠르기", arrowEdge: .bottom , content: {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("평균 말 빠르기란?")
                        .systemFont(.footnote, weight: .bold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                        .padding(.bottom, .HPSpacing.xxxxsmall + 2)
                    VStack(alignment: .leading, spacing: .zero) {
                        HStack(spacing: 0) {
                            Text("이 프로젝트에서 진행한 ").fontWeight(.regular)
                            + Text("모든 연습의 평균 말 빠르기").bold()
                            + Text("예요.").fontWeight(.regular)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .systemFont(.caption, weight: .semibold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                        HStack(spacing: 0) {
                            Text("330~370 SPM 범위로 계산").bold()
                            + Text("하고, 이를 기준으로 내 평균\n속도가 어떤지 알려드려요.").fontWeight(.regular)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .systemFont(.caption, weight: .semibold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                        HStack(spacing: 0) {
                            Text("전문 연사를 기준으로 드리는 조언이니, ").fontWeight(.regular)
                            + Text(" 자신만의 페이스\n에 맞게 참고").bold()
                            + Text("해보세요.").fontWeight(.regular)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .systemFont(.caption, weight: .semibold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                    }
                    .padding(.bottom, .HPSpacing.xxxxsmall + 2)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("*SPM(Syllable Per Minutes•분 당 음절 수) : 1분 동안 말한 음절을 기준으로 측정한 단위")
                            .fixedSize(horizontal: false, vertical: true)
                            .systemFont(.caption2, weight: .medium)
                            .foregroundStyle(Color.HPPrimary.base)
                        Text("*논문 참고: 이소현. (2020). 설득적 말하기의 핵심메시지 발화에 \n나타나는 준언어 연구: 속도와 휴지를 중심으로")
                            .fixedSize(horizontal: false, vertical: true)
                            .systemFont(.caption2, weight: .medium)
                            .foregroundStyle(Color.HPPrimary.base)
                    }
                }
                .padding(.HPSpacing.small)
                .frame(maxWidth: 360, maxHeight: 282)
                .background(Color.HPGray.systemWhite)
            })
            .offset(x: -8, y: 8)
        }
    }
    // MARK: - fillerWordCountView
    func fillerWordCountView(practices: [PracticeModel]) -> some View {
        let fwpmAverage = returnFWPMAverage(practices: practices)
        return VStack(spacing: 0) {
            Text("습관어 사용횟수")
                .systemFont(.body)
                .foregroundColor(Color.HPTextStyle.darker)
            HStack(alignment: .bottom, spacing: .HPSpacing.xxxxsmall) {
                Text("분당")
                    .systemFont(.caption2)
                    .foregroundColor(Color.HPTextStyle.light)
                    .offset(y: -7)
                Text("\(fwpmAverage, specifier: "%.1f")회")
                    .systemFont(.largeTitle)
                    .foregroundColor(Color.HPPrimary.base)
            }
            Text(
                fwpmAverage >= 5.0
                ? "많았어요"
                : fwpmAverage >= 3.0
                ? "조금 많았어요"
                : fwpmAverage > 0.0
                ? "적절했어요" : "없었어요"
            )
                .systemFont(.caption)
                .foregroundColor(Color.HPTextStyle.light)
        }
        .frame(minWidth: 50, maxWidth: .infinity, minHeight: 124, maxHeight: 124, alignment: .center)
        .background(Color.HPComponent.Section.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.HPComponent.shadowColor ,radius: 10, y: .HPSpacing.xxxxsmall)
        .overlay(alignment: .topTrailing) {
            HPTooltip(tooltipContent: "습관어 사용횟수", arrowEdge: .bottom , content: {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("습관어 사용횟수란?")
                        .systemFont(.footnote, weight: .bold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                        .padding(.bottom, .HPSpacing.xxxxsmall + 2)
                    VStack(alignment: .leading, spacing: .zero) {
                        HStack(spacing: .zero) {
                            Text("이 프로젝트에서 진행한 ").fontWeight(.regular)
                            + Text("모든 연습의 분 당 습관어 사용횟수에 대한 평균").bold()
                            + Text("이에요. 분 당 1-2회 정도의 사용은 발표를 한 층 더 자연스럽게 들리게 할 수 있어 괜찮아요. ").fontWeight(.regular)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .systemFont(.caption, weight: .semibold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                        HStack(spacing: .zero) {
                            Text("하이피치는 습관어를 ").fontWeight(.regular)
                            + Text("분 당 5회 이상 말했을 시, 줄여보는 것을 권장").bold()
                            + Text("드리고 있어요.").fontWeight(.regular)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .systemFont(.caption, weight: .semibold)
                        .foregroundStyle(Color.HPTextStyle.darker)
                    }
                }
                .padding(.HPSpacing.small)
                .frame(maxWidth: 360, maxHeight: 183)
                .background(Color.HPGray.systemWhite)
            })
            .offset(x: -8, y: 8)
        }
    }
    
    // MARK: - fillerWordTOP3View
    func fillerWordTOP3View(practices: [PracticeModel]) -> some View {
        let fillerWordTOP3 = returnfillerWordTOP3(practices: practices)
        
        return VStack(spacing: 0) {
            Text("많이 사용한 습관어")
                .systemFont(.body)
                .foregroundColor(Color.HPTextStyle.darker)
            if fillerWordTOP3.isEmpty {
                Text("지금까지 습관어 사용이 없었어요")
                    .systemFont(.footnote)
                    .foregroundColor(Color.HPTextStyle.light)
                    .padding(.top, .HPSpacing.xsmall)
            } else {
                ZStack {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(fillerWordTOP3, id: \.key) { fillerWord, count in
                            VStack(spacing: 0) {
                                Text(fillerWord)
                                    .systemFont(.largeTitle)
                                    .foregroundColor(Color.HPPrimary.base)
                                Text("\(count)회")
                                    .systemFont(.caption)
                                    .foregroundColor(Color.HPTextStyle.light)
                                    .offset(y: -5)
                            }
                            .frame(minWidth: 10, maxWidth: .infinity)
                        }
                    }
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(fillerWordTOP3, id: \.key) { fillerWord, _ in
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(minWidth: 10, maxWidth: .infinity, minHeight: 27, maxHeight: 27)
                                .border(
                                    Color.HPComponent.stroke,
                                    width: 1,
                                    edges: fillerWordTOP3.last!.key != fillerWord ? [.trailing] : []
                                )
                                .offset(y: -10)
                        }
                    }
                }
                .padding(.horizontal, .HPSpacing.small)
            }
        }
        .frame(minWidth: 50, maxWidth: .infinity, minHeight: 124, maxHeight: 124, alignment: .center)
        .background(Color.HPComponent.Section.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.HPComponent.shadowColor ,radius: 10, y: .HPSpacing.xxxxsmall)
    }
}
