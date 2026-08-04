// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// `BZCard`/`BZFlipCard`가 공유하는 찜하기(별) 버튼.
struct BZBookmarkButton: View {

    @Binding var isBookmarked: Bool

    var body: some View {
        Button {
            isBookmarked.toggle()
        } label: {
            Image.bazi(isBookmarked ? .filledStar : .unfilledStar)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
}
