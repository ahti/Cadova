import Foundation
internal import Nodal

struct SVGDataProvider: OutputDataProvider {
    let result: D2.BuildResult
    let options: ModelOptions
    let fileExtension = "svg"

    func generateOutput(context: EvaluationContext) async throws -> Data {
        let yFlip = Transform2D.scaling(x: 1, y: -1)
        let node = GeometryNode.transform(result.node, transform: yFlip)
        let nodeResult = try await context.result(for: node)

        let pathCollection = result.elements[PathCollection.self].transformed(yFlip)

        let shapePoints = nodeResult.concrete.polygons()
        let pathBounds = pathCollection.entries.map(\.path.boundingBox)

        var bounds: BoundingBox2D
        if shapePoints.isEmpty == false {
            bounds = BoundingBox2D(nodeResult.concrete.bounds)
            for pb in pathBounds {
                bounds = bounds.union(with: pb)
            }
        } else if let first = pathBounds.first {
            bounds = first
            for pb in pathBounds.dropFirst() {
                bounds = bounds.union(with: pb)
            }
        } else {
            bounds = BoundingBox2D(centeredSize: [0, 0])
        }

        let document = Document()
        let svg = document.makeDocumentElement(name: "svg", defaultNamespace: "http://www.w3.org/2000/svg")
        svg[attribute: "width"] = String(format: "%g", bounds.size.x)
        svg[attribute: "height"] = String(format: "%g", bounds.size.y)
        svg[attribute: "viewBox"] = String(format: "%g %g %g %g", 0.0, 0.0, bounds.size.x, bounds.size.y)

        let metadata = options[Metadata.self]
        if let title = metadata.title {
            svg.addElement("title").textContent = title
        }
        if let desc = metadata.description {
            svg.addElement("desc").textContent = desc
        }

        if shapePoints.isEmpty == false {
            let fillPath = svg.addElement("path")
            fillPath[attribute: "fill"] = "black"
            fillPath[attribute: "fill-rule"] = "nonzero"
            fillPath[attribute: "d"] = shapePoints.map {
                "M " + $0.vertices.map {
                    String(format: "%g,%g", $0.x - bounds.minimum.x, $0.y - bounds.minimum.y)
                }.joined(separator: " ") + " Z"
            }.joined(separator: " ")
        }

        for entry in pathCollection.entries {
            let style = entry.style
            let strokePath = svg.addElement("path")
            strokePath[attribute: "fill"] = "none"
            strokePath[attribute: "stroke"] = style.strokeColor
            strokePath[attribute: "stroke-width"] = String(format: "%g", style.strokeWidth)
            strokePath[attribute: "stroke-linecap"] = style.strokeLineCap.svgValue
            strokePath[attribute: "stroke-linejoin"] = style.strokeLineJoin.svgValue

            var pathData = entry.path.svgPathData(offsetBy: bounds.minimum)
            if style.closed {
                pathData += " Z"
            }
            strokePath[attribute: "d"] = pathData
        }

        return try document.xmlData()
    }
}

private extension BoundingBox2D {
    func union(with other: BoundingBox2D) -> BoundingBox2D {
        BoundingBox2D(
            minimum: Vector2D(x: Swift.min(minimum.x, other.minimum.x), y: Swift.min(minimum.y, other.minimum.y)),
            maximum: Vector2D(x: Swift.max(maximum.x, other.maximum.x), y: Swift.max(maximum.y, other.maximum.y))
        )
    }
}

private extension LineCapStyle {
    var svgValue: String {
        switch self {
        case .butt: "butt"
        case .round: "round"
        case .square: "square"
        }
    }
}

private extension LineJoinStyle {
    var svgValue: String {
        switch self {
        case .round: "round"
        case .miter: "miter"
        case .bevel: "bevel"
        case .square: "miter"
        }
    }
}
