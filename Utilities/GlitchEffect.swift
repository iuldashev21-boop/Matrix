import SwiftUI

enum GlitchEffect {
    /// Triggers a glitch/jitter animation effect on a CGSize binding
    /// - Parameters:
    ///   - offset: Binding to the CGSize that controls the offset
    ///   - iterations: Number of jitter iterations (default: 6)
    ///   - range: Range of random offset values (default: -6...6)
    ///   - interval: Time between iterations in seconds (default: 0.05)
    ///   - resetDelay: Delay before resetting to zero (default: 0.3)
    static func trigger(
        offset: Binding<CGSize>,
        iterations: Int = 6,
        range: ClosedRange<CGFloat> = -6...6,
        interval: Double = 0.05,
        resetDelay: Double = 0.3,
        onComplete: (() -> Void)? = nil
    ) {
        for i in 0..<iterations {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                offset.wrappedValue = CGSize(
                    width: CGFloat.random(in: range),
                    height: CGFloat.random(in: range)
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
            withAnimation(.easeOut(duration: 0.1)) {
                offset.wrappedValue = .zero
            }
            onComplete?()
        }
    }

    /// Light glitch effect with smaller movements
    static func triggerLight(offset: Binding<CGSize>) {
        trigger(offset: offset, iterations: 5, range: -4...4, interval: 0.04, resetDelay: 0.2)
    }

    /// Standard glitch effect
    static func triggerStandard(offset: Binding<CGSize>) {
        trigger(offset: offset, iterations: 6, range: -6...6, interval: 0.05, resetDelay: 0.3)
    }

    /// Heavy glitch effect with larger movements
    static func triggerHeavy(offset: Binding<CGSize>) {
        trigger(offset: offset, iterations: 10, range: -8...8, interval: 0.03, resetDelay: 0.3)
    }
}
