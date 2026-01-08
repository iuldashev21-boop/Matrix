import SwiftUI

struct PrimaryButton: View {
    let title: String
    var color: Color = Color.matrixGreen
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.deepBlack)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.buttonHeight)
                .background(color)
                .cornerRadius(Theme.cornerRadius)
                .shadow(color: color.opacity(0.4), radius: 8)
        }
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        VStack(spacing: 20) {
            PrimaryButton(title: "INITIALIZE CONSTRUCT") {}
            PrimaryButton(title: "UPLOAD PROGRAM") {}
        }
        .padding()
    }
}
