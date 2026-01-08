import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(Color.mediumGray)

            Text(title)
                .font(.headline)
                .foregroundColor(Theme.primaryText)

            Text(message)
                .font(.bodyRegular)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)

            PrimaryButton(title: buttonTitle, action: action)
                .padding(.horizontal, Spacing.xl)
        }
        .padding(Spacing.xl)
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        EmptyStateView(
            icon: "bolt.slash",
            title: "No Hacks Loaded",
            message: "Load your first program to begin rewriting your code.",
            buttonTitle: "LOAD PROGRAM"
        ) {}
    }
}
