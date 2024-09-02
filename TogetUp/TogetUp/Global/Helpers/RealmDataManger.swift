//
//  RealmDataManger.swift
//  TogetUp
//
//  Created by 이예원 on 1/21/24.
//

import Foundation
import RealmSwift

enum RealmError: Error {
    case alarmNotFound
}

class RealmAlarmDataManager {
    private var realm: Realm {
        return try! Realm()
    }
    
    func configureRealmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: Alarm.className()) { _, newObject in
                        newObject?["isPersonalAlarm"] = false
                    }
                }
            })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func fetchAlarms() -> [Alarm] {
        let alarms = realm.objects(Alarm.self)
            .filter("isPersonalAlarm == true")
            .sorted(by: [
                SortDescriptor(keyPath: "alarmHour", ascending: true),
                SortDescriptor(keyPath: "alarmMinute", ascending: true)
            ])

        return Array(alarms)
    }
    
    func countActivatedAlarms() -> Int {
        let activatedAlarms = realm.objects(Alarm.self).filter("isActivated == true")
        return activatedAlarms.count
    }
    
    func saveAlarms<T>(_ alarms: [T], transform: (T) -> Alarm) {
        do {
            try realm.write {
                alarms.map(transform).forEach { realm.add($0, update: .modified) }
            }
        } catch {
            print("Error saving alarms: \(error)")
        }
    }
    
    func deleteAllDataFromRealm() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func updateAlarm(with request: CreateOrEditAlarmRequest, for alarmId: Int, missionEndpoint: String, missionKoreanName: String, isPersonalAlarm: Bool?) {
        do {
            try realm.write {
                let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId)
                if alarm == nil {
                    let newAlarm = Alarm()
                    newAlarm.id = alarmId
                    mapRequestToAlarm(request, alarm: newAlarm, missionEndpoint: missionEndpoint, missionKoreanName: missionKoreanName, isPersonalAlarm: isPersonalAlarm)
                    realm.add(newAlarm)
                } else {
                    mapRequestToAlarm(request, alarm: alarm!, missionEndpoint: missionEndpoint, missionKoreanName: missionKoreanName, isPersonalAlarm: isPersonalAlarm)
                }
            }
        } catch {
            print("Error updating or adding alarm: \(error)")
        }
    }
    
    func deleteAlarm(alarmId: Int) {
        do {
            if let alarmToDelete = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
                try realm.write {
                    realm.delete(alarmToDelete)
                }
            }
        } catch {
            print("Error deleting alarm from realm: \(error)")
        }
    }
    
    func fetchPastNonRepeatingActivatedAlarms() -> [Int] {
        let now = Date()
        let filteredAlarms = realm.objects(Alarm.self).filter("isActivated == true AND (monday == false AND tuesday == false AND wednesday == false AND thursday == false AND friday == false AND saturday == false AND sunday == false) AND createdDate < %@", now)
        
        let alarmIds = filteredAlarms.map { $0.id }
        return Array(alarmIds)
    }
    
    func deactivateAlarms() {
        let alarmIds = fetchPastNonRepeatingActivatedAlarms()
        let alarmsToDeactivate = realm.objects(Alarm.self).filter("id IN %@", alarmIds)
        
        do {
            try realm.write {
                alarmsToDeactivate.forEach { $0.isActivated = false }
            }
        } catch {
            print("Error deactivating alarms: \(error)")
        }
    }
    
    func deactivateAlarmRequest(alarmId: Int) -> CreateOrEditAlarmRequest {
        guard let storedAlarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) else {
            fatalError("Alarm not found")
        }
        
        let alarmString = String(format: "%02d:%02d", storedAlarm.alarmHour, storedAlarm.alarmMinute)
        var objectIdParam: Int? = storedAlarm.missionObjectId
        if storedAlarm.missionId == 1 {
            objectIdParam = nil
        }
        
        return CreateOrEditAlarmRequest(
            missionId: storedAlarm.missionId,
            missionObjectId: objectIdParam,
            name: storedAlarm.name,
            icon: storedAlarm.icon,
            isVibrate: storedAlarm.isVibrate,
            alarmTime: alarmString,
            monday: storedAlarm.monday,
            tuesday: storedAlarm.tuesday,
            wednesday: storedAlarm.wednesday,
            thursday: storedAlarm.thursday,
            friday: storedAlarm.friday,
            saturday: storedAlarm.saturday,
            sunday: storedAlarm.sunday,
            isActivated: !storedAlarm.isActivated
        )
    }
    
    func isAlarmRepeat(alarmId: Int) -> Bool? {
        if let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
            return alarm.isRepeatAlarm()
        }
        return nil
    }
    
    func toggleActivationStatusAndNotification(for alarmId: Int) {
        if let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
            let newStatus = !alarm.isActivated
            
            try? realm.write {
                alarm.isActivated = newStatus
            }
            
            if newStatus {
                AlarmScheduleManager.shared.scheduleNotification(for: alarmId)
                print("Notification scheduled for alarmId: \(alarmId)")
            } else {
                AlarmScheduleManager.shared.removeNotification(for: alarmId) {
                    print("Notification removed for alarmId: \(alarmId)")
                }
            }
        }
    }
    
    
    private func mapRequestToAlarm(_ request: CreateOrEditAlarmRequest, alarm: Alarm, missionEndpoint: String, missionKoreanName: String, isPersonalAlarm: Bool?) {
        alarm.missionId = request.missionId
        alarm.missionObjectId = request.missionObjectId ?? 1
        alarm.name = request.name
        alarm.icon = request.icon
        alarm.isVibrate = request.isVibrate
        alarm.alarmHour = getHour(from: request.alarmTime)
        alarm.alarmMinute = getMinute(from: request.alarmTime)
        alarm.monday = request.monday
        alarm.tuesday = request.tuesday
        alarm.wednesday = request.wednesday
        alarm.thursday = request.thursday
        alarm.friday = request.friday
        alarm.saturday = request.saturday
        alarm.sunday = request.sunday
        alarm.isActivated = request.isActivated
        alarm.missionName = missionKoreanName
        alarm.missionEndpoint = missionEndpoint
        alarm.createdDate = Date()
        alarm.isPersonalAlarm = isPersonalAlarm ?? false
    }
    
    private func getHour(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components[0]) ?? 0
    }
    
    private func getMinute(from time: String) -> Int {
        let components = time.split(separator: ":").map(String.init)
        return Int(components.count > 1 ? components[1] : "0") ?? 0
    }
}
