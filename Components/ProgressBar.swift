import SwiftUI

struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let isPower: Bool

    var fillColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: Theme.progressBarHeight / 2)
                    .fill(Color.mediumGray)
                    .frame(height: Theme.progressBarHeight)

                // Fill
                RoundedRectangle(cornerRadius: Theme.progressBarHeight / 2)
                    .fill(fillColor)
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)), height: Theme.progressBarHeight)
            }
        }
        .frame(height: Theme.progressBarHeight)
    }
}
