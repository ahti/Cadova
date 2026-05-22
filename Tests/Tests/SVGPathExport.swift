import Foundation
import Testing
@testable import Cadova

struct SVGPathExportTests {
    init() {
        Platform.revealingFilesDisabled = true
    }

    private func svgContent(for modelName: String, in tempDir: URL) throws -> String {
        let svgURL = tempDir.appending(path: "\(modelName).svg")
        let data = try Data(contentsOf: svgURL)
        return String(decoding: data, as: UTF8.self)
    }

    @Test func `SVG export of line path produces L commands`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0])
            .addingLine(to: [10, 0])
            .addingLine(to: [10, 10])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("lines") {
                path.asPath()
            }
        }

        let svg = try svgContent(for: "lines", in: tempDir)
        #expect(svg.contains("fill=\"none\""))
        #expect(svg.contains("stroke=\"black\""))
        #expect(svg.contains("L"))
    }

    @Test func `SVG export of cubic curve produces C commands`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0])
            .addingCubicCurve(controlPoint1: [5, 10], controlPoint2: [15, 10], end: [20, 0])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("cubic") {
                path.asPath()
            }
        }

        let svg = try svgContent(for: "cubic", in: tempDir)
        #expect(svg.contains("C"))
        #expect(svg.contains("fill=\"none\""))
    }

    @Test func `SVG export of quadratic curve produces Q commands`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0])
            .addingQuadraticCurve(controlPoint: [10, 20], end: [20, 0])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("quad") {
                path.asPath()
            }
        }

        let svg = try svgContent(for: "quad", in: tempDir)
        #expect(svg.contains("Q"))
        #expect(svg.contains("fill=\"none\""))
    }

    @Test func `SVG export of closed path produces Z command`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0])
            .addingLine(to: [10, 0])
            .addingLine(to: [10, 10])
            .addingLine(to: [0, 10])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("closed") {
                path.asPath(closed: true)
            }
        }

        let svg = try svgContent(for: "closed", in: tempDir)
        #expect(svg.contains("Z"))
        #expect(svg.contains("fill=\"none\""))
    }

    @Test func `SVG export of open path does not produce Z command`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0])
            .addingLine(to: [10, 0])
            .addingLine(to: [10, 10])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("open") {
                path.asPath(closed: false)
            }
        }

        let svg = try svgContent(for: "open", in: tempDir)
        #expect(!svg.contains("Z"))
    }

    @Test func `SVG export of mixed solid and path geometry produces both fill and stroke`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let bezierPath = BezierPath2D(startPoint: [0, 0])
            .addingCubicCurve(controlPoint1: [5, 10], controlPoint2: [15, 10], end: [20, 0])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("mixed") {
                Circle(diameter: 10)
                bezierPath.asPath(strokeWidth: 2, strokeColor: "blue")
            }
        }

        let svg = try svgContent(for: "mixed", in: tempDir)
        #expect(svg.contains("fill=\"black\""))
        #expect(svg.contains("stroke=\"blue\""))
        #expect(svg.contains("stroke-width=\"2\""))
    }

    @Test func `SVG export applies stroke style attributes`() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let path = BezierPath2D(startPoint: [0, 0]).addingLine(to: [10, 0])

        await Project(root: tempDir, options: .format2D(.svg)) {
            await Model("styled") {
                path.asPath(strokeWidth: 3, strokeColor: "red", lineCap: .round, lineJoin: .bevel)
            }
        }

        let svg = try svgContent(for: "styled", in: tempDir)
        #expect(svg.contains("stroke=\"red\""))
        #expect(svg.contains("stroke-width=\"3\""))
        #expect(svg.contains("stroke-linecap=\"round\""))
        #expect(svg.contains("stroke-linejoin=\"bevel\""))
    }

    @Test func `SVG path data conversion produces correct line commands`() {
        let path = BezierPath2D(startPoint: [1, 2])
            .addingLine(to: [3, 4])
            .addingLine(to: [5, 6])

        let data = path.svgPathData(offsetBy: [0, 0])
        #expect(data == "M 1,2 L 3,4 L 5,6")
    }

    @Test func `SVG path data conversion produces correct cubic commands`() {
        let path = BezierPath2D(startPoint: [0, 0])
            .addingCubicCurve(controlPoint1: [1, 2], controlPoint2: [3, 4], end: [5, 6])

        let data = path.svgPathData(offsetBy: [0, 0])
        #expect(data == "M 0,0 C 1,2 3,4 5,6")
    }

    @Test func `SVG path data conversion produces correct quadratic commands`() {
        let path = BezierPath2D(startPoint: [0, 0])
            .addingQuadraticCurve(controlPoint: [1, 2], end: [3, 4])

        let data = path.svgPathData(offsetBy: [0, 0])
        #expect(data == "M 0,0 Q 1,2 3,4")
    }

    @Test func `SVG path data conversion applies offset`() {
        let path = BezierPath2D(startPoint: [10, 20])
            .addingLine(to: [30, 40])

        let data = path.svgPathData(offsetBy: [5, 10])
        #expect(data == "M 5,10 L 25,30")
    }

    @Test func `BezierPath2D bounding box is correct`() {
        let path = BezierPath2D(startPoint: [1, 2])
            .addingCubicCurve(controlPoint1: [5, 10], controlPoint2: [15, -3], end: [20, 4])

        let box = path.boundingBox
        #expect(box.minimum.x == 1)
        #expect(box.minimum.y == -3)
        #expect(box.maximum.x == 20)
        #expect(box.maximum.y == 10)
    }
}
