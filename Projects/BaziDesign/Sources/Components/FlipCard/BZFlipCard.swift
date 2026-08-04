// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 탭하면 앞/뒤로 뒤집히는 정책 카드. 앞면엔 썸네일/태그/제목/신청기간을,
/// 뒷면엔 상세 설명을 보여준다.
public struct BZFlipCard: View {

    // MARK: - Constants

    private static let cardAspectRatio: CGFloat = 302.0 / 456.0
    private static let thumbnailAspectRatio: CGFloat = 270.0 / 139.0
    private static let horizontalMargin: CGFloat = 36

    // MARK: - Properties

    @State private var isFlipped = false

    private let image: Image?
    private let category: String
    private let dDay: String
    private let title: String
    private let subtitle: String
    private let applyPeriod: String
    private let description: String
    @Binding private var isBookmarked: Bool

    // MARK: - Init

    public init(
        image: Image? = nil,
        category: String,
        dDay: String,
        title: String,
        subtitle: String,
        applyPeriod: String,
        description: String,
        isBookmarked: Binding<Bool>
    ) {
        self.image = image
        self.category = category
        self.dDay = dDay
        self.title = title
        self.subtitle = subtitle
        self.applyPeriod = applyPeriod
        self.description = description
        self._isBookmarked = isBookmarked
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            front
                .baziRadius(.medium)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            back
                .baziRadius(.medium)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .aspectRatio(Self.cardAspectRatio, contentMode: .fit)
        .padding(.horizontal, Self.horizontalMargin)
        .shadow(color: Color.grayBlack.opacity(0.11), radius: 5.67, x: 0, y: 1.89)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFlipped.toggle()
            }
        }
    }
}

// MARK: - Front

extension BZFlipCard {

    private var front: some View {
        VStack(alignment: .leading, spacing: 0) {
            thumbnailAndHeader
            Spacer(minLength: 4)
            applyPeriodSection
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .baziBackground(.bgWhite)
    }

    private var thumbnailAndHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            thumbnail
            VStack(alignment: .leading, spacing: 8) {
                headerRow
                titleAndSubtitle
            }
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 8) {
            categoryAndDDay
            Spacer(minLength: 8)
            BZBookmarkButton(isBookmarked: $isBookmarked)
        }
    }

    private var categoryAndDDay: some View {
        HStack(spacing: 8) {
            BZTag(category, type: .blue100)
            Text(dDay)
                .baziFont(.small12SB)
                .foregroundStyle(Color.gray700)
        }
    }

    private var titleAndSubtitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.byCharWrapping)
                .baziFont(.head20B)
                .foregroundStyle(Color.grayBlack)
            Text(subtitle.byCharWrapping)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray500)
        }
    }

    private var applyPeriodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            VStack(alignment: .leading, spacing: 2) {
                Text("신청 기간")
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray400)
                Text(applyPeriod)
                    .baziFont(.small12M)
                    .foregroundStyle(Color.gray600)
            }
        }
    }

    private var thumbnail: some View {
        GeometryReader { geometry in
            (image ?? Image.bazi(.imagePlaceholder))
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .aspectRatio(Self.thumbnailAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: BaziRadius.small.rawValue, style: .continuous))
    }
}

// MARK: - Back

extension BZFlipCard {

    private var back: some View {
        ScrollView {
            Text(description.byCharWrapping)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 36)
                .padding(.horizontal, 31.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.grayWhite, location: 0),
                    .init(color: Color.blue100, location: 0.44),
                    .init(color: Color.grayWhite, location: 1),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Preview

private struct BZFlipCardPreview: View {
    @State private var isBookmarked = true

    var body: some View {
        BZFlipCard(
            category: "월세·주거",
            dDay: "D-11",
            title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업",
            subtitle: "소속 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소, 중견기업에게 장려금을 지원",
            applyPeriod: "2025.05.03 - 2025.06.30",
            description: "서울 청년취업사관학교는 청년들의 실무 역량을 키우고 취업까지 이어질 수 있도록 돕는 교육 프로그램이에요. 디지털·IT 분야를 중심으로 현장에서 활용할 수 있는 실무 교육과 프로젝트 기반 수업을 제공해요.",
            isBookmarked: $isBookmarked
        )
    }
}

#Preview {
    BZFlipCardPreview()
}
