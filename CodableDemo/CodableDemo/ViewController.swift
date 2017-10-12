//
//  ViewController.swift
//  CodableDemo
//
//  Created by MacMini on 10/11/17.
//  Copyright © 2017 Thành Lã. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let csv = """
name,age,isMan
ほげ,25,true
ふが,100,false
"""
        let decoder = CSVDecoder()
        let rows = try! decoder.decode(Row.self, from: csv)
        dump(rows)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

struct Row: Codable {
    let name: String
    let age: Int
    let isMan: Bool
}

open class CSVDecoder {
    public init() {}
    
    open func decode<T: Decodable>(_ type: T.Type, from csv: String) throws -> [T] {
        var rows = csv.components(separatedBy: .newlines)
        let titleRow = rows.removeFirst()
        
        return try rows.map {
            let decoder = _CSVRowDecoder(titleRow: titleRow, valueRow: $0)
            return try T(from: decoder)
        }
        
    }
    
    
}

fileprivate class _CSVRowDecoder: Decoder {
    let titles: [String]
    let values: [String]
    
    var codingPath: [CodingKey] { return [] }
    
    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given top-level container and options.
    init(titleRow: String, valueRow: String) {
        titles = titleRow.split(separator: ",").map { String($0) }
        values = valueRow.split(separator: ",").map { String($0) }
    }
    
    // MARK: - Coding Path Operations
    
    /// T(from:)内で、各カラムのCodingPathをプロパティに接続するために呼び出されるのはこのメソッド
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = _CSVKeyedDecodingContainer<Key>(referencing: self)
        //注: 型消去
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        //CSVだと関係ないけど、ネストを加味して考える場合、ここで対象がdictionayあるいはarrayだとか色々見てやる必要がある
        
        throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                          DecodingError.Context(codingPath: self.codingPath,
                                                                debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.typeMismatch(SingleValueDecodingContainer.self,
                                         DecodingError.Context(codingPath: self.codingPath,
                                                               debugDescription: "Cannot get single value decoding container -- found keyed container instead."))
    }
}

// MARK: Decoding Containers

fileprivate struct _CSVKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the decoder we're reading from.
    let decoder: _CSVRowDecoder
    
    /// Data we're reading from.
    let columns: [String : String]
    
    /// The path of coding keys taken to get to this point in decoding.
    var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` by referencing the given decoder.
    init(referencing decoder: _CSVRowDecoder) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        columns = Dictionary(uniqueKeysWithValues: zip(decoder.titles, decoder.values))
    }
    
    // MARK: - KeyedDecodingContainerProtocol Methods
    
    var allKeys: [Key] {
        return columns.keys.flatMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: K) -> Bool {
        return columns[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: K) throws -> Bool {
        return columns[key.stringValue] != nil
    }
    
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        // ここらへん、既存コードでは `unbox` というメソッドを通して具体処理を切り離してるんだけど、今回はダイレクトに書く
        // KeyedDecodingContainerProtocolとSingleValueDecodingContainerの具体処理を共通化したいとき、 `unbox` メソッドが効いてくるんだと思う
        return columns[key.stringValue].flatMap { Bool($0) } ?? false
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return columns[key.stringValue].flatMap { Int($0) } ?? 0
    }
    
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return columns[key.stringValue].flatMap { Int8($0) } ?? 0
    }
    
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return columns[key.stringValue].flatMap { Int16($0) } ?? 0
    }
    
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return columns[key.stringValue].flatMap { Int32($0) } ?? 0
    }
    
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return columns[key.stringValue].flatMap { Int64($0) } ?? 0
    }
    
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return columns[key.stringValue].flatMap { UInt($0) } ?? 0
    }
    
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return columns[key.stringValue].flatMap { UInt8($0) } ?? 0
    }
    
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return columns[key.stringValue].flatMap { UInt16($0) } ?? 0
    }
    
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return columns[key.stringValue].flatMap { UInt32($0) } ?? 0
    }
    
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return columns[key.stringValue].flatMap { UInt64($0) } ?? 0
    }
    
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return columns[key.stringValue].flatMap { Float($0) } ?? 0
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return columns[key.stringValue].flatMap { Double($0) } ?? 0
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return columns[key.stringValue] ?? ""
    }
    
    func decode(_ type: Data.Type, forKey key: K) throws -> Data {
        return columns[key.stringValue]?.data(using: .utf8) ?? Data()
    }
    
    func decode<T : Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        // Date等のデコード方法(timeInterval, etc)を動的に指定するのもここらへん作り込む
        // cf. https://github.com/apple/swift/blob/dbe77601f348583eb892a5b9fff09327e23b00c2/stdlib/public/SDK/Foundation/JSONEncoder.swift#L30-L72
        
        // その他Decodableな型に対応するにはSingleValueDecodingContainerの実装が必要
        // cf. https://github.com/apple/swift/blob/dbe77601f348583eb892a5b9fff09327e23b00c2/stdlib/public/SDK/Foundation/JSONEncoder.swift#L1456
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "SingleValueDecodingContainerはとりあえず置いとく")
        )
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSVでnestは考えない")
        )
    }
    
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSVでnestは考えない")
        )
    }
    
    func superDecoder() throws -> Decoder {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSVでnestは考えない")
        )
    }
    
    func superDecoder(forKey key: K) throws -> Decoder {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath,
                                  debugDescription: "CSVでnestは考えない")
        )
    }
}
