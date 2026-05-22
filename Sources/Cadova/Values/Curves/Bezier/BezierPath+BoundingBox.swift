import Foundation

extension BezierPath2D {
    var boundingBox: BoundingBox2D {
        var minX = startPoint.x
        var maxX = startPoint.x
        var minY = startPoint.y
        var maxY = startPoint.y

        for curve in curves {
            for point in curve.controlPoints {
                minX = Swift.min(minX, point.x)
                maxX = Swift.max(maxX, point.x)
                minY = Swift.min(minY, point.y)
                maxY = Swift.max(maxY, point.y)
            }
        }

        return BoundingBox2D(minimum: [minX, minY], maximum: [maxX, maxY])
    }
}
