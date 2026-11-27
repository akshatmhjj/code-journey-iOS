import Foundation

/// A role's pay in India, from PayScale. Figures are in lakh rupees a year (1 lakh = 100,000).
struct IndiaPay: Codable, Hashable {
    let title: String
    let avg: Double
    let p10: Double
    let p90: Double
    /// Average for people with under a year's experience. Not every role has one.
    let entry: Double?
    let profiles: Int
    /// When PayScale last updated this figure, as "YYYY-MM-DD".
    let updated: String
    let url: URL
    /// False when PayScale's closest title is only a near match for this role.
    let exact: Bool
}

/// A role's pay in the US, from the Bureau of Labor Statistics. Median pay is in dollars a year.
struct USPay: Codable, Hashable {
    let title: String
    let median: Int
    /// Projected growth in jobs from 2025 to 2035, as a percentage.
    let growth: Double
    let url: URL
    let exact: Bool
}

/// Both markets for one role. Either can be missing when a source has no matching title.
struct RolePay: Codable, Hashable {
    let india: IndiaPay?
    let us: USPay?
}
