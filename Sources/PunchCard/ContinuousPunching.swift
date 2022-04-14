//
//  ContinuousPunching.swift
//  PunchCard
//
//  Created by 77。 on 2022/4/14.
//

import Foundation
import WCDBSwift

/// 连续打卡记录表
/// 字段详解见文档：`Tables/ContinuousPunching.numbers

public struct ContinuousPunching: TableCodable {
    // 表名
    public static let Continuous_punching_table = "Continuous_punching_table"
    
    public var ID: Int?
    public var punchCardID: Int?
    public var beginDay: Date?
    public var endDay: Date?
    public var days: Int = 0
    
    public init() { }
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = ContinuousPunching
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case ID
        case beginDay
        case endDay
        case days
        case punchCardID
        
        public static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                .ID: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
            ]
        }
    }
}

public extension ContinuousPunching {
    
    static func query(with ID: Int) -> [ContinuousPunching] {
        return DBManager.shared.query(fromTable: ContinuousPunching.Continuous_punching_table,
                                      where: ContinuousPunching.Properties.ID == ID) ?? []
    }
    
    static func queryTotal() -> [ContinuousPunching] {
        return DBManager.shared.query(fromTable: ContinuousPunching.Continuous_punching_table) ?? []
    }
    
    static func insert(date: Date) {
        var punch = ContinuousPunching()
        punch.days = 1
        punch.beginDay = date
        punch.endDay = date
        DBManager.shared.insert(intoTable: ContinuousPunching.Continuous_punching_table, objects: [punch])
    }
    
    static func update(punchCard: PunchCard, date: Date, replenish: Bool) {
        // 非周末才处理连续打卡事件
        if punchCard.weekend { return }
        let nums = queryTotal()
        if nums.isEmpty {
            insert(date: date)
            return
        }
        if replenish {
            /// 补卡这边需要根据具体需求来定，
        } else {
            var last = nums.last!
            let tuple = date.isSameWeekAndBetweenDays(date: last.endDay!)
            /// 同一周并间隔为一天代表连续
            /// 不同周，其实就是上周五和这周一也算连续
            if (tuple.week && tuple.days == 1) || (!tuple.week && tuple.days == 3) {
                last.endDay = date
                last.days += 1
                DBManager.shared.update(table: ContinuousPunching.Continuous_punching_table,
                                        on: [ContinuousPunching.Properties.endDay, ContinuousPunching.Properties.days],
                                        with: last,
                                        where: ContinuousPunching.Properties.ID == last.ID!)
            } else {
                // 断签，需要重新生成一条连续打卡记录数据
                insert(date: date)
            }
        }
    }
    
    /// 获取当前连续打卡天数和历史最高连续打卡天数
    static func maxContinuousAndCurrent() -> (current: Int, max: Int) {
        let nums = queryTotal()
        if nums.isEmpty {
            return (0, 0)
        }
        let max = nums.max { $0.days < $1.days }
        return (current: nums.last!.days, max: max!.days)
    }
}

extension Date {
    
    /// 判断两个日期是否处于同一周和间隔天数
    func isSameWeekAndBetweenDays(date: Date) -> (week: Bool, days: Int) {
        let differ = self.daysBetweenDate(toDate: date)
        let compareResult = Calendar.current.compare(self, to: date, toGranularity: Calendar.Component.day)
        var earlyDate: Date
        if compareResult == ComparisonResult.orderedAscending {
            earlyDate = self
        } else {
            earlyDate = date
        }
        let indexOfWeek = earlyDate.dayForWeekAtIndex()
        let result = differ + indexOfWeek
        return (result > 7 ? false : true, differ)
    }
    
    /// 判断两个日期间隔天数
    private func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return abs(components.day!)
    }
    
    /// 日期对应当周的周几，周一为开始, 周天为结束
    private func dayForWeekAtIndex() -> Int {
        let components = Calendar.current.dateComponents([.weekday], from: self)
        return (components.weekday! - 1) == 0 ? 7 : (components.weekday! - 1)
    }
}
