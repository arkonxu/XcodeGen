import Foundation
import JSONUtilities
import PathKit

public struct ConfigFile: Equatable {
    public var type: String
    public var path: String
    public var configOptions: [ConfigOption]?
    
    public func getConfigurationOptions(path: String) -> [ConfigOption] {
        guard let configContent = try? String(contentsOfFile: path) else {
            return []
        }
        
        let lines = configContent.components(separatedBy: .newlines)
        var configOptions: [ConfigOption] = []
        
        for line in lines {
            let parts = line.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                configOptions.append(ConfigOption(configName: key, configValue: value))
            }
        }
        
        var configDictionary: [String: Any] = [:]
        configOptions.forEach { option in
            configDictionary[option.configName] = option.configValue
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: configDictionary, options: .prettyPrinted) {
            if let deserializedDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                deserializedDictionary.forEach { key, value in                    
                    if let stringValue = value as? String {
                        let arrayValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
                        configOptions.removeAll { $0.configName == key }
                        configOptions.append(ConfigOption(configName: key.replacingOccurrences(of: "\"", with: ""), configValue: arrayValue))
                    } else {
                        configOptions.removeAll { $0.configName == key }
                        configOptions.append(ConfigOption(configName: key.replacingOccurrences(of: "\"", with: ""), configValue: value))
                    }
                }
            }
        }
        
        return configOptions
    }
    
    public static func == (lhs: ConfigFile, rhs: ConfigFile) -> Bool {
        lhs.path == rhs.path && lhs.configOptions == rhs.configOptions
    }
}

public struct ConfigOption: Equatable {
    public var configName: String
    public var configValue: Any
    
    public static func == (lhs: ConfigOption, rhs: ConfigOption) -> Bool {
        lhs.configName == rhs.configName && lhs.configValue as? String == rhs.configValue as? String
    }
}

extension ConfigFile: JSONObjectConvertible {
    
    public init(jsonDictionary: JSONDictionary) throws {
        guard let path: String = jsonDictionary.json(atKeyPath: "path"),
              let type: String = jsonDictionary.json(atKeyPath: "type") else {
            throw JSONUtilsError.fileDeserializationFailed
        }
        
        self.path = path
        self.type = type
    }
    
}

extension ConfigOption: JSONObjectConvertible {
    
    public init(jsonDictionary: JSONDictionary) throws {
        guard let configName: String = jsonDictionary.json(atKeyPath: "configName"),
              let configValue: Any = jsonDictionary.json(atKeyPath: "configValue") else {
            throw JSONUtilsError.fileDeserializationFailed
        }
        
        self.configName = configName
        self.configValue = configValue
    }
    
    public func toDictionary() -> [String: Any] {
        [self.configName: self.configValue]
    }
    
}
