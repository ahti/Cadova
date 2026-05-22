import Foundation

public struct Path2D: Geometry2D {
    let path: BezierPath2D
    let style: PathStyle2D

    public init(_ path: BezierPath2D, style: PathStyle2D = PathStyle2D()) {
        self.path = path
        self.style = style
    }

    public func build(in environment: EnvironmentValues, context: EvaluationContext) async throws -> D2.BuildResult {
        BuildResult(.empty, element: PathCollection(entries: [PathEntry(path: path, style: style)]))
    }
}
