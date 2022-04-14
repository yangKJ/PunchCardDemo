//
//  DayRecord.swift
//  PunchCard
//
//  Created by 77。 on 2022/4/14.
//

import Foundation
import WCDBSwift

/// 每日打卡记录表
/// 字段详解见文档：`Tables/DayRecord.numbers

public struct DayRecord: TableCodable {
    // 表名
    public static let Day_record_table = "Day_record_table"
    
    public var ID: Int?
    public var date: Int?
    public var punchCardID: Int?
    
    public init() { }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = DayRecord
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case ID
        case date
        case punchCardID
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .ID: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
            ]
        }
    }
}

public extension DayRecord {
    
    static func queryOne(with ID: Int) -> DayRecord? {
        return DBManager.shared.queryOne(fromTable: DayRecord.Day_record_table, where: DayRecord.Properties.ID == ID)
    }
    
    static func query(punchCardID: Int) -> [DayRecord] {
        return DBManager.shared.query(fromTable: DayRecord.Day_record_table,
                                      where: DayRecord.Properties.punchCardID == punchCardID) ?? []
    }
    
    static func insert(punchCardID: Int) {
        let timeInterval = Int(Date().timeIntervalSince1970)
        var record = DayRecord()
        record.punchCardID = punchCardID
        record.date = timeInterval
        DBManager.shared.insert(intoTable: DayRecord.Day_record_table, objects: [record])
    }
    
    static func delete(with ID: Int) {
        DBManager.shared.delete(fromTable: DayRecord.Day_record_table,
                                where: DayRecord.Properties.ID == ID)
    }
}
