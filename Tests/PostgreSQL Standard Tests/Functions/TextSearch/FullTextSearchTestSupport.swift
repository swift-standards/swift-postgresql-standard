import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import Testing

@Table("articles")
struct Article: FullTextSearchable {
    let id: Int
    var title: String
    var body: String
    var searchVector: String
}

@Table("blogPosts")
struct FTSBlogPost: FullTextSearchable {
    let id: Int
    var content: String
    var searchVector: String
}

extension SnapshotTests {
    @Suite("Full-Text Search") struct FullTextSearch {}
}
