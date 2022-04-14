//
//  User.swift
//  PunchCard
//
//  Created by 77。 on 2022/4/14.
//

import Foundation
import WCDBSwift

/// 用户信息表
/// 字段详解见文档：`Tables/User.numbers

public struct User: TableCodable {
    // 表名
    public static let User_table = "User_table"
    
    public var UserID: Int?
    public var currentContinuousPunchDayCount: Int = 0
    public var maxContinuousPunchDayCount: Int = 0
    public var totalPunchRecords: Int = 0
    public var totalPunchDays: Int = 0
    
    public init() { }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = User
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case UserID
        case currentContinuousPunchDayCount
        case maxContinuousPunchDayCount
        case totalPunchRecords
        case totalPunchDays
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .UserID: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: false),
            ]
        }
    }
}

public extension User {
    
    /// 测试数据，初始化用户
    /// - Parameter ID: 用户ID
    static func initUser(with ID: Int) {
        if let _ = query(with: ID) {
            return
        }
        var user = User()
        user.UserID = ID
        DBManager.shared.insert(intoTable: User.User_table, objects: [user])
    }
    
    static func query(with ID: Int) -> User? {
        return DBManager.shared.queryOne(fromTable: User.User_table, where: User.Properties.UserID == ID)
    }
    
    static func update(with ID: Int, user: User) {
        DBManager.shared.update(table: User.User_table,
                                with: user,
                                where: User.Properties.UserID == ID)
    }
}
