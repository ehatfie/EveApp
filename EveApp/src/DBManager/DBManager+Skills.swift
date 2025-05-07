//
//  DBManager+Skills.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/28/25.
//
import Foundation
import Fluent
import FluentSQL
import FluentPostgresDriver
import ModelLibrary

extension DBManager {
    
    func makeSkillInfos(for skills: [(String, Int)]) async -> [SkillInfo] {
        let result = await withTaskGroup(returning: [SkillInfo].self) { taskGroup in
            for skill in skills {
                taskGroup.addTask {
                    return await self.makeSkillInfo(
                        skillName: skill.0,
                        requiredLevel: skill.1
                    )
                }
            }
            var returnValues: [SkillInfo] = []
            
            for await result in taskGroup {
                guard let result else { continue }
                returnValues.append(result)
            }
            return returnValues
        }
        
        return result
    }
    
    func makeSkillInfo(
      skillName: String,
      requiredLevel: Int
    ) async -> SkillInfo? {
        guard let typeModel = try? await TypeModel.query(on: self.database)
          .filter(\.$name == skillName)
          .join(
            TypeDogmaInfoModel.self,
            on: \TypeDogmaInfoModel.$typeId == \TypeModel.$typeId
          )
          .first()
        else {
            print("no typeModel for skill named \(skillName)")
            return nil
        }
        
        guard let dogmaInfo = try? typeModel.joined(TypeDogmaInfoModel.self) else {
            print("no TypeDogmaInfoModel")
            return nil
        }
        
        guard let skillDogmaInfo = await makeSkillAttributeInfo(dogmaInfo: dogmaInfo) else {
            print("no skill dogma info")
            return nil
        }
      print()
      //print("dogmaInfo \(dogmaInfo)")
      //print("skill dogma info \(skillDogmaInfo)")
        
      return SkillInfo(
        typeModel: typeModel,
        dogma: dogmaInfo,
        skillDogmaInfo: skillDogmaInfo,
        skillEffectInfo: SkillEffectInfo(skillDogmaEffectInfos: []),
        skillDescription: typeModel.name,
        requiredLevel: requiredLevel
      )
    }
    
    func makeSkillAttributeInfo(dogmaInfo: TypeDogmaInfoModel) async -> SkillDogmaAttributeInfo? {
        let attributesByID = await self.getAttributeModels(for: dogmaInfo.attributes)
        let categoryIDs = attributesByID.compactMap { $0.value.categoryID}
        let categoriesByID = await self.getAttributeCategoryModels(for: categoryIDs)
        //let attributesByCategory = await self.makeAttributesByCategory(from: dogmaInfo.attributes)
        let skillAttributeInfosByCategory: [Int64: [SkillAttributeInfo]] = await self.makeValues(
          values: dogmaInfo.attributes,
          for: attributesByID,
          categoryModels: categoriesByID
        )
        //await self.makeSkillAttributeDomgaInfo(from: skillAttributeInfosByCategory)
        let skillAttributeInfo = await self.makeSkillAttributeInfo(
          typeDogmaAttributes: dogmaInfo.attributes,
          values: skillAttributeInfosByCategory
        )
        return skillAttributeInfo
    }
}
