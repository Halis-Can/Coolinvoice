//
//  FirestoreCodableHelper.swift
//  Cullinvoice
//
//  Helper for encoding/decoding Codable types to/from Firestore
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    func data<T: Codable>(as type: T.Type) throws -> T {
        guard let data = self.data() else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document data is nil"])
        }
        
        // Convert Firestore data to JSON-compatible format
        let convertedData = convertFirestoreToJSON(data)
        let json = try JSONSerialization.data(withJSONObject: convertedData)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: json)
    }
    
    private func convertFirestoreToJSON(_ data: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in data {
            result[key] = convertValue(value)
        }
        return result
    }
    
    private func convertValue(_ value: Any) -> Any {
        if let timestamp = value as? Timestamp {
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: timestamp.dateValue())
        } else if let array = value as? [Any] {
            return array.map { convertValue($0) }
        } else if let dict = value as? [String: Any] {
            return convertFirestoreToJSON(dict)
        }
        return value
    }
}

extension DocumentReference {
    func setData<T: Codable>(from codable: T, merge: Bool = false) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(codable)
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Convert JSON to Firestore-compatible format
        let firestoreData = convertJSONToFirestore(json)
        
        if merge {
            setData(firestoreData, merge: true)
        } else {
            setData(firestoreData)
        }
    }
    
    private func convertJSONToFirestore(_ json: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in json {
            result[key] = convertValueToFirestore(value)
        }
        return result
    }
    
    private func convertValueToFirestore(_ value: Any) -> Any {
        if let dateString = value as? String,
           let date = ISO8601DateFormatter().date(from: dateString) {
            return Timestamp(date: date)
        } else if let array = value as? [Any] {
            return array.map { convertValueToFirestore($0) }
        } else if let dict = value as? [String: Any] {
            return convertJSONToFirestore(dict)
        }
        return value
    }
}

extension WriteBatch {
    func setData<T: Codable>(from codable: T, forDocument document: DocumentReference, merge: Bool = false) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(codable)
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Convert JSON to Firestore-compatible format
        let firestoreData = convertJSONToFirestore(json)
        
        if merge {
            setData(firestoreData, forDocument: document, merge: true)
        } else {
            setData(firestoreData, forDocument: document)
        }
    }
    
    private func convertJSONToFirestore(_ json: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in json {
            result[key] = convertValueToFirestore(value)
        }
        return result
    }
    
    private func convertValueToFirestore(_ value: Any) -> Any {
        if let dateString = value as? String,
           let date = ISO8601DateFormatter().date(from: dateString) {
            return Timestamp(date: date)
        } else if let array = value as? [Any] {
            return array.map { convertValueToFirestore($0) }
        } else if let dict = value as? [String: Any] {
            return convertJSONToFirestore(dict)
        }
        return value
    }
}

