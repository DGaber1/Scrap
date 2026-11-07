import SwiftUI

/// Ruled notebook paper with a red margin line, used by the grocery list (REQ-D-23).
struct ScpNotebookPaperStyle: ViewModifier {
    static let lineSpacing: CGFloat = 38
    static let marginX: CGFloat = 56

    func body(content: Content) -> some View {
        content.background {
            Canvas { context, size in
                var y = ScpNotebookPaperStyle.lineSpacing
                while y < size.height {
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(line, with: .color(ScpColor.paperLine), lineWidth: 1)
                    y += ScpNotebookPaperStyle.lineSpacing
                }
                var margin = Path()
                margin.move(to: CGPoint(x: ScpNotebookPaperStyle.marginX, y: 0))
                margin.addLine(to: CGPoint(x: ScpNotebookPaperStyle.marginX, y: size.height))
                context.stroke(margin, with: .color(ScpColor.paperMargin), lineWidth: 1.5)
            }
            .background(ScpColor.paper)
        }
    }
}

extension View {
    /// Draws this view on ruled notebook paper.
    func scpNotebookPaper() -> some View {
        modifier(ScpNotebookPaperStyle())
    }
}
