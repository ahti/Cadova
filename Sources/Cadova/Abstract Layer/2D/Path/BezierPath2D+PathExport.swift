import Foundation

public extension BezierPath2D {
    func asPath(
        strokeWidth: Double = 1,
        strokeColor: String = "black",
        lineCap: LineCapStyle = .butt,
        lineJoin: LineJoinStyle = .miter,
        closed: Bool = false
    ) -> Path2D {
        Path2D(self, style: PathStyle2D(
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            strokeLineCap: lineCap,
            strokeLineJoin: lineJoin,
            closed: closed
        ))
    }
}
