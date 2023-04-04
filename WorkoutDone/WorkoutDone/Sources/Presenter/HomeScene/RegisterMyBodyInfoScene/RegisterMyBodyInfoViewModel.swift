//
//  RegisterMyBodyInfoViewModel.swift
//  WorkoutDone
//
//  Created by 류창휘 on 2023/03/21.
//

import RxSwift
import RxCocoa
import RealmSwift
import UIKit

class RegisterMyBodyInfoViewModel {
    let realm = try! Realm()
    var workOutDoneData : Results<WorkOutDoneData>?
    init(workOutDoneData: Results<WorkOutDoneData>? = nil) {
        self.workOutDoneData = realm.objects(WorkOutDoneData.self)
    
    }
    
    //struct
    var test = PublishSubject<Void>()
    struct Input {
        let weightInputText : Driver<String>
        let skeletalMusleMassInputText : Driver<String>
        let fatPercentageInputText : Driver<String>
        let saveButtonTapped : Driver<BodyInputData>
        let selectedDate : Driver<String>
    }
    struct Output {
        let weightOutputText : Driver<String>
        let skeletalMusleMassOutputText : Driver<String>
        let fatPercentageOutputText : Driver<String>
        let saveData : Driver<Void>
        let isConfirmEnabled : Driver<Bool>
    }
    func trimText(text: String) -> String {
        if text.count >= 3 {
            let index = text.index(text.startIndex, offsetBy: 3)
            let newString = text[text.startIndex..<index]
            return String(newString)
            
        }
        else {
            return text
        }
    }
    func ignoreZeroText(text: String) -> String {
        if text.count >= 1 && text[text.startIndex] == "0" {
            return ""
        }
        else {
            return text
        }
    }
    
    func createBodyInfoData(weight : Double?, skeletalMusleMass : Double?, fatPercentage : Double?, date : String, id : Int) {
        do {
            try realm.write {
                let workoutDoneData = WorkOutDoneData(id: id, date: date)
                let bodyInfo = BodyInfo()
                bodyInfo.wegiht = weight
                bodyInfo.skeletalMuscleMass = skeletalMusleMass
                bodyInfo.fatPercentage = fatPercentage
                workoutDoneData.bodyInfo = bodyInfo
                realm.add(workoutDoneData)
                //??
                test.onNext(())
                
                print("렘 세ㅇ")
            }
        }
        catch {
            print("Error saving \(error)")
        }
    }
    func updateBodyInfoData(weight: Double?, skeletalMusleMass : Double?, fatPercentage : Double?, date : String, id : Int) {
        do {
            try realm.write {
                let workoutDoneData = WorkOutDoneData(id: id, date: date)
                let bodyInfo = BodyInfo(value: ["wegiht" : weight, "skeletalMuscleMass" : skeletalMusleMass, "fatPercentage" : fatPercentage])
                workoutDoneData.bodyInfo = bodyInfo
                realm.add(workoutDoneData, update: .modified)
            }
        }
        catch {
            print("Error updating \(error)")
        }
    }
    
    func transform(input: Input) -> Output {
        let weightText = input.weightInputText.map { value in
            let ignoreZeroValue = self.ignoreZeroText(text: value )
            let trimValue = self.trimText(text: ignoreZeroValue)
            return trimValue
        }
        
        let skeletalMusleMassText = input.skeletalMusleMassInputText.map { value in
            let ignoreZeroValue = self.ignoreZeroText(text: value )
            let trimValue = self.trimText(text: ignoreZeroValue)
            return trimValue
        }
        
        let fatPercentageText = input.fatPercentageInputText.map { value in
            let ignoreZeroValue = self.ignoreZeroText(text: value )
            let trimValue = self.trimText(text: ignoreZeroValue)
            return trimValue
        }
        let buttonEnabled = Driver<Bool>.combineLatest(input.weightInputText, skeletalMusleMassText, fatPercentageText, resultSelector: { (weight, skeletalMusle, fatPercenatage) in
            if weight.count + skeletalMusle.count + fatPercenatage.count > 0 {
                return true
            }
            else {
                return false
            }
        })
  
        
        let inputData = input.saveButtonTapped.map { value in
            self.updateBodyInfoData(
                weight: Double(value.weight ?? ""),
                skeletalMusleMass: Double(value.skeletalMusleMass ?? ""),
                fatPercentage: Double(value.fatPercentage ?? ""),
                date: "2023.04.20",
                id: 20230420)
        }
        return Output(
            weightOutputText: weightText,
            skeletalMusleMassOutputText: skeletalMusleMassText,
            fatPercentageOutputText: fatPercentageText, 
            saveData: inputData, isConfirmEnabled: buttonEnabled)
    }
}

