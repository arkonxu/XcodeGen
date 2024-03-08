import Foundation

public protocol BuildSettingsContainer {
    var settings: Settings { get }
    var configFiles: [ConfigFile] { get }
}
