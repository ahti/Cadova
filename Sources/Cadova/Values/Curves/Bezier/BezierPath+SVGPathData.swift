import Foundation

extension BezierPath2D {
    func svgPathData(offsetBy offset: Vector2D) -> String {
        var commands = [String]()

        commands.append(String(format: "M %g,%g", startPoint.x - offset.x, startPoint.y - offset.y))

        for curve in curves {
            let degree = curve.degree
            let points = curve.controlPoints

            switch degree {
            case 1:
                let end = points[1]
                commands.append(String(format: "L %g,%g", end.x - offset.x, end.y - offset.y))

            case 2:
                let cp = points[1]
                let end = points[2]
                commands.append(String(format: "Q %g,%g %g,%g", cp.x - offset.x, cp.y - offset.y, end.x - offset.x, end.y - offset.y))

            case 3:
                let cp1 = points[1]
                let cp2 = points[2]
                let end = points[3]
                commands.append(String(format: "C %g,%g %g,%g %g,%g", cp1.x - offset.x, cp1.y - offset.y, cp2.x - offset.x, cp2.y - offset.y, end.x - offset.x, end.y - offset.y))

            default:
                fatalError("Bézier curves of degree \(degree) are not yet supported in SVG export")
            }
        }

        return commands.joined(separator: " ")
    }
}
