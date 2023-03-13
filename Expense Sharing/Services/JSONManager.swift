//
//  JSONManager.swift
//  Expense Sharing
//

import Foundation

class JSONManager {
    static let shared = JSONManager()
    private init() { }
    
    static func loadFrom(fileName name: String) -> ExportData {
        guard let jsonData = JSONManager.loadJSON(fileName: name),
              let exportData: ExportData = JSONManager.decodeJSON(from: jsonData)
        else {
            print("Failed to decode export data - return empty")
            return ExportData(users: [], groups: [])
        }
        return exportData
    }
    
    static func loadFrom(fileURL url: URL) -> ExportData {
        guard let jsonData = JSONManager.loadJSON(fileURL: url),
              let exportData: ExportData = JSONManager.decodeJSON(from: jsonData)
        else {
            print("Failed to decode export data - return empty")
            return ExportData(users: [], groups: [])
        }
        return exportData
    }
    
    static func saveToFile(_ exportData: ExportData, named: String) -> URL? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(exportData)
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(named).json")
            try data.write(to: url, options: .atomic)
            return url
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    static func clearTempFile(named: String) {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(named).json")
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print("Removing file error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    static private func decodeJSON<T: Decodable>(from data: Data) -> T? {
        do {
            let decoder = JSONDecoder()
            let jsonObject = try decoder.decode(T.self, from: data)
            return jsonObject
        } catch let error {
            print("Decoding error: \(error)")
            return nil
        }
    }
    
    static private func loadJSON(fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("No such file...")
            return nil
        }
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return jsonData
        } catch let error {
            print("Loading error: \(error)")
            return nil
        }
    }
    
    static private func loadJSON(fileURL: URL) -> Data? {
        guard fileURL.isFileURL else {
            print("No a file url...")
            return nil
        }
        do {
            let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return jsonData
        } catch let error {
            print("Loading error: \(error)")
            return nil
        }
    }
}
