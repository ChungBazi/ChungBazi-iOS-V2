// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// `BZCard`/`BZFlipCard`가 공유하는 찜하기(별) 버튼.
struct BZLikeButton: View {

    @Binding var isLiked: Bool

    var body: some View {
        Button {
            isLiked.toggle()
        } label: {
            Image.bazi(isLiked ? .filledStar : .unfilledStar)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .accessibilityLabel("찜하기")
        .accessibilityAddTraits(isLiked ? .isSelected : [])
    }
}
