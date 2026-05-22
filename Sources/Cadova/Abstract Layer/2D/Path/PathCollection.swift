import Foundation

internal struct PathEntry: Sendable, Hashable {
    let path: BezierPath2D
    let style: PathStyle2D
}

internal struct PathCollection: ResultElement {
    var entries: [PathEntry]

    init() {
        entries = []
    }

    init(entries: [PathEntry]) {
        self.entries = entries
    }

    init(combining collections: [PathCollection]) {
        entries = collections.flatMap(\.entries)
    }

    func transformed(_ transform: Transform2D) -> PathCollection {
        PathCollection(entries: entries.map {
            PathEntry(path: $0.path.transformed(transform), style: $0.style)
        })
    }
}
