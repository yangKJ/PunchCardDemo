//
//  PunchCardDemoTests.swift
//  PunchCardDemoTests
//
//  Created by 77。 on 2022/4/14.
//

import XCTest
@testable import PunchCardDemo
import PunchCard

class PunchCardDemoTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DBManager.shared.createTable(User.User_table, of: User.self)
        DBManager.shared.createTable(PunchCard.Punch_card_table, of: PunchCard.self)
        DBManager.shared.createTable(DayRecord.Day_record_table, of: DayRecord.self)
        DBManager.shared.createTable(ContinuousPunching.Continuous_punching_table, of: ContinuousPunching.self)
        User.initUser(with: 1)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    /// 测试记录每日打卡
    func testRecordDailyPunchCard() {
        let tuple = Manager.recordDailyPunchCard(userID: 1)
        print("""
              总打卡次数 = \(tuple.records)
              总打卡天数 = \(tuple.days)
              当前连续打卡天数 = \(tuple.continuous)
              历史最高打卡天数 = \(tuple.maxContinuous)
              """)
    }
    
    /// 测试移除某一次打卡
    func testRemovePunchCardRecord() {
        let records = Manager.getPunchRecords(for: Date())
        XCTAssertNotEqual(records.count, 0, "今天没有打卡记录")
        guard let record = records.first else { return }
        let tuple = Manager.removePunchCardRecord(id: record.ID!, userID: 1)
        print("""
              总打卡次数 = \(tuple.records)
              总打卡天数 = \(tuple.days)
              当前连续打卡天数 = \(tuple.continuous)
              历史最高打卡天数 = \(tuple.maxContinuous)
              """)
    }
    
    /// 测试获取指定日期全部打卡记录
    func testPunchRecords() {
        let records = Manager.getPunchRecords(for: Date())
        XCTAssertNotEqual(records.count, 0, "今天没有打卡记录")
    }
    
    /// 测试对指定日期进行补卡
    func testReplenishPunchCard() {
        let date = Date().dayAfter
        Manager.replenishPunchCard(for: date, userID: 1)
    }
}

extension Date {
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    public var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
}
