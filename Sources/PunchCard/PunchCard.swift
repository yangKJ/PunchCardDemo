//
//  PunchCard.swift
//  PunchCard
//
//  Created by 77。 on 2022/4/14.
//

import Foundation
import WCDBSwift

/// 打卡表
/// 字段详解见文档：`Tables/PunchCard.numbers

public struct PunchCard: TableCodable {
    // 表名
    public static let Punch_card_table = "Punch_card_table"
    
    public var ID: Int?
    public var day: String?
    public var punched: Bool = false
    public var weekend: Bool = false
    public var userID: Int?
    public var max: Int = 0
    public var punchCount: Int = 0
    
    public init() { }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = PunchCard
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case ID
        case day
        case punched
        case weekend
        case userID
        case max
        case punchCount
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .ID: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                //.max: ColumnConstraintBinding(orderBy: OrderTerm.descending),
            ]
        }
    }
}

public extension PunchCard {
    
    static func queryOne(with ID: Int) -> PunchCard? {
        return DBManager.shared.queryOne(fromTable: PunchCard.Punch_card_table,
                                         where: PunchCard.Properties.ID == ID)
    }
    
    static func query(day: String) -> [PunchCard] {
        return DBManager.shared.query(fromTable: PunchCard.Punch_card_table,
                                      where: PunchCard.Properties.day == day) ?? []
    }
    
    static func queryTotal() -> [PunchCard] {
        return DBManager.shared.query(fromTable: PunchCard.Punch_card_table) ?? []
    }
    
    static func query(date: Date) -> PunchCard? {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        let dayString = dformatter.string(from: date)
        let cards = query(day: dayString)
        if cards.isEmpty { return nil }
        return cards.first!
    }
    
    static func update(card: PunchCard) {
        DBManager.shared.update(table: PunchCard.Punch_card_table,
                                with: card,
                                where: PunchCard.Properties.ID == card.ID!)
    }
    
    /// 打卡事件处理
    /// - Parameters:
    ///   - userID: 用户ID
    ///   - date: 打卡或补卡日期
    ///   - replenish: 是否为补卡
    static func insert(userID: Int, date: Date, replenish: Bool) {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        let dayString = dformatter.string(from: date)
        let cards = query(day: dayString)
        if cards.isEmpty {
            var card = PunchCard()
            card.day = dayString
            card.punched = true
            card.weekend = weekend(date: date)
            card.userID = userID
            card.max = queryTotal().count + 1
            card.punchCount = 1
            DBManager.shared.insert(intoTable: PunchCard.Punch_card_table, objects: [card])
            let cards = query(day: dayString)
            if cards.isEmpty == false {
                ContinuousPunching.update(punchCard: cards.first!, date: date, replenish: replenish)
            }
        } else {
            // 今日已打卡
            var card = cards.first!
            card.punchCount += 1
            DBManager.shared.update(table: PunchCard.Punch_card_table,
                                    on: [PunchCard.Properties.punchCount],
                                    with: card,
                                    where: DayRecord.Properties.ID == card.ID!)
            DayRecord.insert(punchCardID: card.ID!)
        }
    }
}

extension PunchCard {
    
    /// 判断当前是否为周末
    /// - Parameter date: 日期
    /// - Returns: 是否为周末
    static func weekend(date: Date) -> Bool {
        guard let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday else {
            return false
        }
        // 第一天是从星期天算起，weekday在 1~7之间
        let day = (weekday + 5) % 7
        return day == 6 || day == 7
    }
    
    /// 获取今日打卡次数
    static func todayPunchCount(with ID: Int) -> Int {
        return DayRecord.query(punchCardID: ID).count
    }
    
    /// 获取总打卡天数
    static func totalPunchDays() -> Int {
        guard let days: [PunchCard] = DBManager.shared.query(fromTable: PunchCard.Punch_card_table, limit: 1),
              !days.isEmpty else {
            return 0
        }
        return days.first!.max
    }
    
    /// 获取总打卡天数和总次数
    static func punchCountAndDays() -> (days: Int, records: Int) {
        let cards = queryTotal()
        let records = cards.reduce(0) { $0 + $1.punchCount }
        return (days: cards.count, records: records)
    }
}
