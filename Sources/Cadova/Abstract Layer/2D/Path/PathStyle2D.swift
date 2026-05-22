import Foundation

public struct PathStyle2D: Hashable, Sendable {
    public var strokeWidth: Double
    public var strokeColor: String
    public var strokeLineCap: LineCapStyle
    public var strokeLineJoin: LineJoinStyle
    public var closed: Bool

    public init(
        strokeWidth: Double = 1,
        strokeColor: String = "black",
        strokeLineCap: LineCapStyle = .butt,
        strokeLineJoin: LineJoinStyle = .miter,
        closed: Bool = false
    ) {
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.strokeLineCap = strokeLineCap
        self.strokeLineJoin = strokeLineJoin
        self.closed = closed
    }
}
