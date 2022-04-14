//
//  Manager.swift
//  PunchCard
//
//  Created by 77。 on 2022/4/14.
//

import Foundation

public struct Manager {
    
    /// 总打卡次数，总打卡天数，当前连续打卡天数，历史最高打卡天数
    public typealias PunchTuple = (records: Int, days: Int, continuous: Int, maxContinuous: Int)
    
    /// 记录每日打卡
    @discardableResult
    public static func recordDailyPunchCard(userID: Int) -> PunchTuple {
        PunchCard.insert(userID: userID, date: Date(), replenish: false)
        let continuous = ContinuousPunching.maxContinuousAndCurrent()
        let punch = PunchCard.punchCountAndDays()
        DispatchQueue.global().async{
            if var user = User.query(with: userID) {
                user.currentContinuousPunchDayCount = continuous.current
                user.maxContinuousPunchDayCount = continuous.max
                user.totalPunchRecords = punch.records
                user.totalPunchDays = punch.days
                User.update(with: userID, user: user)
            }
        }
        return (punch.records, punch.days, continuous.current, continuous.max)
    }
    
    /// 移除某一次打卡
    @discardableResult
    public static func removePunchCardRecord(id: Int, userID: Int) -> PunchTuple {
        /// 这边需要不明确，需要考虑到是否可以移除某天的唯一一次打卡记录
        /// 如果最后一次不能移除则如下；
        if let record = DayRecord.queryOne(with: id),
           var card = PunchCard.queryOne(with: record.punchCardID!) {
            card.punchCount -= 1
            PunchCard.update(card: card)
        }
        DayRecord.delete(with: id)
        DispatchQueue.global().async{
            if var user = User.query(with: userID) {
                user.totalPunchRecords -= 1
                User.update(with: userID, user: user)
            }
        }
        let continuous = ContinuousPunching.maxContinuousAndCurrent()
        let punch = PunchCard.punchCountAndDays()
        return (punch.records, punch.days, continuous.current, continuous.max)
    }
    
    /// 对指定日期补卡
    @discardableResult
    public static func replenishPunchCard(for date: Date, userID: Int) -> PunchTuple {
        if let _ = PunchCard.query(date: date) {
            let continuous = ContinuousPunching.maxContinuousAndCurrent()
            let punch = PunchCard.punchCountAndDays()
            return (punch.records, punch.days, continuous.current, continuous.max)
        }
        PunchCard.insert(userID: userID, date: date, replenish: true)
        let continuous = ContinuousPunching.maxContinuousAndCurrent()
        let punch = PunchCard.punchCountAndDays()
        DispatchQueue.global().async{
            if var user = User.query(with: userID) {
                user.currentContinuousPunchDayCount = continuous.current
                user.maxContinuousPunchDayCount = continuous.max
                user.totalPunchRecords = punch.records
                user.totalPunchDays = punch.days
                User.update(with: userID, user: user)
            }
        }
        return (punch.records, punch.days, continuous.current, continuous.max)
    }
    
    /// 点击日历某一天可以显示这一天的打卡数据
    public static func getPunchRecords(for date: Date) -> [DayRecord] {
        guard let card = PunchCard.query(date: date) else { return [] }
        return DayRecord.query(punchCardID: card.ID!)
    }
}

// MARK: - 特殊说明
/// 以下情况考虑到性能问题，这边引入用户表这个概念；
/// 并且在实际情况之下，一般我们的用户信息会堆栈缓存区，这样还可以省略掉查询操作，会更快
/// 如果不需要用户表的话，也可以直接`打卡表`和`连续打卡记录表`中获取，
/// 只是这种情况会比直接从用户表中查询慢些许时间；
extension Manager {
    
    /// 总的打卡次数
    public static func getTotalPunchCardRecords(userID: Int) -> Int {
        guard let user = User.query(with: userID) else { return 0 }
        return user.totalPunchRecords
    }
    
    /// 总的打卡天数
    public static func getTotalPunchCardDays(userID: Int) -> Int {
        guard let user = User.query(with: userID) else { return 0 }
        return user.totalPunchDays
    }
    
    /// 当前连续打卡天数
    public static func getCurrentContinuousPunchCardDays(userID: Int) -> Int {
        guard let user = User.query(with: userID) else { return 0 }
        return user.currentContinuousPunchDayCount
    }
    
    /// 历史最高连续打卡天数
    public static func getMaxContinuousPunchCardDays(userID: Int) -> Int {
        guard let user = User.query(with: userID) else { return 0 }
        return user.maxContinuousPunchDayCount
    }
}
