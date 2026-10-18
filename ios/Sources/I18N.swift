import Foundation

public enum I18N {
    public static var isVietnamese: Bool {
        Locale.preferredLanguages.first?.hasPrefix("vi") == true
    }

    public static func loc(_ en: String, _ vi: String) -> String {
        isVietnamese ? vi : en
    }
}

public func loc(_ en: String, _ vi: String) -> String {
    I18N.loc(en, vi)
}
