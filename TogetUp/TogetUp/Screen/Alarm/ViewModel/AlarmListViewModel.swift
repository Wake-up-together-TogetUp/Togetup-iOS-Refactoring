//
//  AlarmListViewModel.swift
//  TogetUp
//
//  Created by 이예원 on 2023/09/12.
//

import Foundation
import RxMoya
import RxSwift
import Moya
import RealmSwift

class AlarmListViewModel {
    private let provider: MoyaProvider<AlarmService>
    var alarms = BehaviorSubject<[Alarm]>(value: [])
    private let disposeBag = DisposeBag()
    
    private lazy var realmInstance: Realm = {
        return try! Realm()
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    init() {
        self.provider = MoyaProvider<AlarmService>(plugins: [NetworkLogger()])
    }
    
    func fetchAlarmsFromRealm() {
        let alarmsFromRealm = realmInstance.objects(Alarm.self).sorted(byKeyPath: "alarmTime")
        alarms.onNext(Array(alarmsFromRealm))
    }
    
    func getAndSaveAlarmList(type: String) {
        provider.rx.request(.getAlarmList(type: type))
            .filterSuccessfulStatusCodes()
            .map(GetAlarmListResponse.self)
            .subscribe(onSuccess: { [weak self] response in
                if let result = response.result {
                    self?.saveAlarmsToRealm(result)
                    self?.fetchAlarmsFromRealm()
                }
            }, onFailure: handleNetworkError)
            .disposed(by: disposeBag)
    }
    
    private func handleNetworkError(_ error: Error) {
        print(error.localizedDescription)
    }
    
    private func createAlarmFrom(apiAlarm: GetAlarmResult) -> Alarm {
        let alarm = Alarm()
        alarm.id = apiAlarm.id
        
        if let missionId = apiAlarm.getMissionRes?.id,
           let missionObjectId = apiAlarm.getMissionObjectRes?.id,
           let missionName = apiAlarm.getMissionObjectRes?.kr {
            alarm.missionId = missionId
            alarm.missionObjectId = missionObjectId
            alarm.missionName = missionName
        }
        
        alarm.isSnoozeActivated = apiAlarm.isSnoozeActivated
        alarm.name = apiAlarm.name
        alarm.icon = apiAlarm.icon
        alarm.isVibrate = apiAlarm.isVibrate
        alarm.monday = apiAlarm.monday
        alarm.tuesday = apiAlarm.tuesday
        alarm.wednesday = apiAlarm.wednesday
        alarm.thursday = apiAlarm.thursday
        alarm.friday = apiAlarm.friday
        alarm.saturday = apiAlarm.saturday
        alarm.sunday = apiAlarm.sunday
        alarm.isActivated = apiAlarm.isActivated
        
        if let alarmTimeDate = dateFormatter.date(from: apiAlarm.alarmTime) {
            alarm.alarmTime = alarmTimeDate
        } else {
            print(#function, "Date formatting failed for:", apiAlarm.alarmTime)
        }
        
        return alarm
    }
    
    func editAlarm(alarmId: Int, param: CreateOrEditAlarmRequest) -> Single<Result<CreateEditDeleteAlarmResponse, CreateAlarmError>> {
        return handleAPIRequest(provider.rx.request(.editAlarm(alarmId: alarmId, param: param)))
    }
    
    func handleAPIRequest<T: Decodable>(_ request: Single<Response>) -> Single<Result<T, CreateAlarmError>> {
        return request
            .filterSuccessfulStatusAndRedirectCodes()
            .map(T.self)
            .map(Result.success)
            .catch { error -> Single<Result<T, CreateAlarmError>> in
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        return Single.just(.failure(.server(response.statusCode)))
                    default:
                        return Single.just(.failure(.network(moyaError)))
                    }
                } else {
                    return Single.just(.failure(.network(MoyaError.underlying(error, nil))))
                }
            }
    }
    
    func updateRealmDatabaseWithResponse(_ response: CreateEditDeleteAlarmResponse, for alarmId: Int) {
            let realm = try! Realm()
            
            if let alarm = realm.object(ofType: Alarm.self, forPrimaryKey: alarmId) {
                try! realm.write {
                    if alarm.isActivated {
                        alarm.isActivated.toggle()
                    } else {
                        alarm.isActivated.toggle()
                    }
                }
            }
        }
    
    private func saveAlarmsToRealm(_ alarms: [GetAlarmResult]) {
        try! realmInstance.write {
            for apiAlarm in alarms {
                let alarm = createAlarmFrom(apiAlarm: apiAlarm)
                realmInstance.add(alarm, update: .modified)
            }
        }
    }
    
    func deleteAlarm(alarmId: Int) {
        provider.rx.request(.deleteAlarm(alarmId: alarmId))
            .filterSuccessfulStatusCodes()
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                
                if let alarmToDelete = self.realmInstance.objects(Alarm.self).filter("id == %@", alarmId).first {
                    var currentAlarms = try? self.alarms.value()
                    currentAlarms?.removeAll(where: { $0.id == alarmId })
                    
                    try? self.realmInstance.write {
                        self.realmInstance.delete(alarmToDelete)
                    }
                    
                    if let updatedAlarms = currentAlarms {
                        self.alarms.onNext(updatedAlarms)
                    }
                }
            }, onFailure: handleNetworkError)
            .disposed(by: disposeBag)
    }
}


