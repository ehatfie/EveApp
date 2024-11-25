//
//  DBManager+query.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/7/23.
//

import Foundation
import Fluent
import FluentSQL
import ModelLibrary
import FluentKit


struct TypeNamesResult {
  let typeId: Int64
  let name: String
}

extension DBManager {
  func getGroups() -> [GroupModel] {
    return try! GroupModel.query(on: self.database)
      .all()
      .wait()
  }
  
  func getGroups(in categoryId: Int64) -> [GroupModel] {
    return try! GroupModel.query(on: self.database)
      .filter(\.$categoryID == categoryId)
      .all()
      .wait()
  }
  
  func getGroups(with groupIds: [Int64]) async -> [GroupModel] {
    return try! await GroupModel.query(on: self.database)
      .filter(\.$groupId ~~ groupIds)
      .all()
      .get()
  }
  
  func getGroup(for groupId: Int64) -> GroupModel? {
    return try! GroupModel.query(on: self.database)
      .filter(\.$groupId == groupId)
      .first()
      .wait()
  }
  
  func getGroup(for groupId: Int64) async -> GroupModel? {
    return try! await GroupModel.query(on: self.database)
      .filter(\.$groupId == groupId)
      .first()
      .get()
  }
  
  func getCategories() -> [CategoryModel] {
    return try! CategoryModel.query(on: self.database)
      .all()
      .wait()
  }
  
  func getCategory(typeId: Int64) -> CategoryModel {
    let category = try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .join(GroupModel.self, on: \GroupModel.$groupId == \TypeModel.$groupID)
      .join(CategoryModel.self, on: \CategoryModel.$categoryId == \GroupModel.$categoryID)
      .first()
      .wait()!.joined(CategoryModel.self)
    
    return category
  }
  
  func getCategory(groupId: Int64) -> CategoryModel {
    let categoryModel = try! GroupModel.query(on: self.database)
      .filter(\.$groupId == groupId)
      .join(CategoryModel.self, on: \CategoryModel.$categoryId == \GroupModel.$categoryID)
      .first().wait()!
      .joined(CategoryModel.self)
    return categoryModel
  }
}

extension DBManager {
  func getTypeNames(for typeIds: [Int64]) -> [TypeNamesResult] {
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .wait()
      .map({ TypeNamesResult(typeId: $0.typeId, name: $0.name) })
    return results
  }
  
  func getTypeNames(for typeIds: [Int64]) async -> [TypeNamesResult] {
    let results = try! await TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .get()
      .map({ TypeNamesResult(typeId: $0.typeId, name: $0.name) })
    return results
  }
  
  func getObjects<T: Model>(for type: T.Type, filter: ModelFieldFilter<T, T>) -> [T] {
    try! T.query(on: self.database)
      .filter(filter)
      .all()
      .wait()
  }
  
  func getObjects<T: Model>(for type: T.Type) -> [T] {
    try! T.query(on: self.database)
      .all()
      .wait()
  }
  
  func getRandomBlueprint() -> BlueprintModel? {
    let blueprints = try! BlueprintModel.query(on: self.database)
      .filter(\.$blueprintTypeID == 11394)
      .join(TypeModel.self, on: \TypeModel.$typeId == \BlueprintModel.$blueprintTypeID)
      .filter(TypeModel.self, \.$published == true)
      .filter(TypeModel.self, \.$metaGroupID == 2)
      .all()
      .wait()
    
    guard !blueprints.isEmpty else {
      return nil
    }
    
    let count = blueprints.count
    
    let rand = Int.random(in: 0..<count)
    
    return blueprints[rand]
  }
  
  func getType(for typeId: Int64) -> TypeModel {
    try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .all()
      .wait()[0]
  }
  
  func getType(for typeId: Int64) async -> TypeModel? {
    try? await TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .first()
  }
  
  func getType1(for typeId: Int64) -> TypeModel {
    try! TypeModel.query(on: self.database)
      .field(\.$id).field(\.$typeId).field(\.$name)
      .filter(\.$typeId == typeId)
      .all()
      .wait()[0]
    
  }
  
  func getTypes(for typeIds: [Int64]) -> [TypeModel] {
    try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .wait()
  }
  
  func getTypeMaterialModel(for type: Int64) -> TypeMaterialsModel? {
    return try! TypeMaterialsModel.query(on: self.database)
      .filter(\.$typeID == type)
      .first()
      .wait()
  }
  
  func getTypeAndMaterialModels(for typeId: Int64) -> TypeModel? {
    return try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .join(TypeMaterialsModel.self, on: \TypeMaterialsModel.$typeID == \TypeModel.$typeId)
      .first()
      .wait()
  }
  
  func getTypeMaterialModels(for types: [Int64]) -> [TypeMaterialsModel] {
    try! TypeMaterialsModel.query(on: self.database)
      .filter(\.$typeID ~~ types)
      .all()
      .wait()
  }
  
  func getTests(for types: [Int64]) {
    let foo = try! TypeModel.query(on: self.database)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .filter(TypeModel.self, \.$typeId ~~ types)
      .all()
      .wait()
    
    foo.forEach { value in
      let materialsModel = try! value.joined(TypeMaterialsModel.self)
      print("got \(materialsModel.materialData.count) for \(value.name)")
    }
  }
  
  func getMaterialTypes(for type: Int64) -> [TypeModel] {
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId == type)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .all()
      .wait()
    
    if results.count > 0 {
      let foo = try! results[0].joined(TypeMaterialsModel.self)
      print("got foo \(foo)")
    }
    
    return results
  }
  
  func getMaterialTypes(for types: [Int64]) -> [TypeModel] {
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ types)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .all()
      .wait()
    return results
  }
  
  func getDogmaAttributes(for typeDogma: TypeDogmaInfoModel) -> [DogmaAttributeModel] {
    let attributeIds = typeDogma.attributes.map({ $0.attributeID })
    do {
      return try DogmaAttributeModel.query(on: database)
        .filter(\.$attributeID ~~ attributeIds)
        .all()
        .wait()
    } catch let err {
      print("dogma attribute query err \(err)")
      return []
    }
    
  }
  
  func getDogmaAttribute(for attributeID: Int64) -> DogmaAttributeModel? {
    do {
      return try DogmaAttributeModel.query(on: database)
        .filter(\.$attributeID == attributeID)
        .first()
        .wait()
    } catch let err {
      print("dogma attribute query err \(err)")
      return nil
    }
    
  }
  
  func getDogmaAttribute(for attributeID: Int64) async -> DogmaAttributeModel? {
    do {
      return try await DogmaAttributeModel.query(on: database)
        .filter(\.$attributeID == attributeID)
        .first()
        .get()
    } catch let err {
      print("dogma attribute query err \(err)")
      return nil
    }
    
  }
  
  func getDogmaEffects(for effectIDs: [Int64]) -> [DogmaEffectModel] {
    do {
      return try DogmaEffectModel.query(on: database)
        .filter(\.$effectID ~~ effectIDs)
        .join(TypeModel.self, on: \TypeModel.$typeId == \DogmaEffectModel.$effectID)
        .all()
        .wait()
    } catch let err {
      print("dogma effect query err \(err)")
      return []
    }
    
  }
  
  func getDogmaEffects(for effectIDs: [Int64]) async -> [DogmaEffectModel] {
    do {
      return try await DogmaEffectModel.query(on: database)
        .filter(\.$effectID ~~ effectIDs)//.join(TypeModel.self, on: \TypeModel.$typeId == \DogmaEffectModel.$effectID)
        .all()
        .get()
    } catch let err {
      print("dogma effect query err \(err)")
      return []
    }
    
  }
  
  func getDogmaEffect(for effectID: Int64) -> DogmaEffectModel? {
    do {
      return try DogmaEffectModel.query(on: database)
        .filter(\.$effectID == effectID)
        .first()
        .wait()
    } catch let err {
      print("dogma effect query err \(err)")
      return nil
    }
  }
  
}

struct DogmaInfo {
  
}

struct SkillEffectInfo {
  let skillDogmaEffectInfos: [SkillDogmaEffectInfo]
}

struct AttributeModifierInfo {
  let id = UUID()
  let name: String
  let modifiedAttributeModel: DogmaAttributeModel
  let modifyingAttribute: DogmaAttributeModel
  let modifierInfo: ModifierInfo
  let skillDescription: String?
}

struct SkillDogmaEffectInfo {
  let id = UUID()
  let dogmaEffectModel: DogmaEffectModel
  let typeModel: TypeModel?
  let effectedAttributes: [AttributeModifierInfo]
}

struct SkillRequiredSkillsInfo {
  var requiredSkill1: String?
  var requiredSkill2: String?
  var requiredSkill3: String?
  
  init(requiredSkill1: String? = nil, requiredSkill2: String? = nil, requiredSkill3: String? = nil) {
    self.requiredSkill1 = requiredSkill1
    self.requiredSkill2 = requiredSkill2
    self.requiredSkill3 = requiredSkill3
  }
}

struct SkillDogmaAttributeInfo {
  let skillMiscAttributes: SkillMiscAttributes
  
  init(
    skillMiscAttributes: SkillMiscAttributes
  ) {
    self.skillMiscAttributes = skillMiscAttributes
  }
  
  init() {
    let attribute = DogmaAttributeModel(
      attributeId: 0,
      data: DogmaAttributeData1(
        attributeID: 0,
        defaultValue: 0,
        description: "",
        name: ""
      )
    )

    self.skillMiscAttributes = SkillMiscAttributes(
      primaryAttribute: attribute,
      secondaryAttribute: attribute,
      skillTimeConstant: 0
    )
  }
}

struct SkillDogmaAttributeInfo1 {
  let primaryAttribute: DogmaAttributeModel // be an enum?
  let secondaryAttribute: DogmaAttributeModel
  let skillTimeConstants: Int
  let requiredSkills: SkillRequiredSkillsInfo
  let skillMiscAttributes: SkillMiscAttributes
  
  init(
    primaryAttribute: DogmaAttributeModel,
    secondaryAttribute: DogmaAttributeModel,
    skillTimeConstants: Int,
    requiredSkillsInfo: SkillRequiredSkillsInfo,
    skillMiscAttributes: SkillMiscAttributes
  ) {
    self.primaryAttribute = primaryAttribute
    self.secondaryAttribute = secondaryAttribute
    self.skillTimeConstants = skillTimeConstants
    self.requiredSkills = requiredSkillsInfo
    self.skillMiscAttributes = skillMiscAttributes
  }
  
  init() {
    let attribute = DogmaAttributeModel(
      attributeId: 0,
      data: DogmaAttributeData1(
        attributeID: 0,
        defaultValue: 0,
        description: "",
        name: ""
      )
    )
    self.primaryAttribute = attribute
    self.secondaryAttribute = attribute
    self.skillTimeConstants = 0
    self.requiredSkills = SkillRequiredSkillsInfo()
    self.skillMiscAttributes = SkillMiscAttributes(
      primaryAttribute: attribute,
      secondaryAttribute: attribute,
      skillTimeConstant: 0
    )
  }
}

struct SkillDogmaCategory {
  
}

enum DogmaAttribute: CaseIterable {
  enum characterAttribute: Double  {
    case charisma = 164
    case intelligence = 165
    case memory = 166
    case willpower = 167
  }
  
  case requiredSkill1
  case requiredSkill2
  case requiredSkill3
  case requiredSkill1Level
  case requiredSkill2Level
  case requiredSkill3Level
  
}



// Mark: - Reactions

extension DBManager {
  func getReactionBlueprints() -> [TypeModel] {
    // all blueprints with a type id that matches a TypeModel that has a groupID that matches IndustryGroup.compositeReactionsFormula
    let foo = try! TypeModel.query(on: database)
      .filter(\.$groupID == IndustryGroup.compositeReactionsFormula.rawValue)
      .join(BlueprintModel.self, on: \BlueprintModel.$blueprintTypeID == \TypeModel.$typeId)
      .all()
      .wait()
    print("getReactionBlueprints got \(foo.count) things")
    return foo
  }
  
  func getReactionBlueprints1(groups: [IndustryGroup.ReactionFormulas]) -> [TypeModel] {
    // all blueprints with a type id that matches a TypeModel that has a groupID that matches IndustryGroup.compositeReactionsFormula
    let values = groups.map({ $0.rawValue })
    let foo = try! TypeModel.query(on: database)
      .filter(\.$groupID ~~ values)
      //.join(BlueprintModel.self, on: \BlueprintModel.$blueprintTypeID == \TypeModel.$typeId)
      .all()
      .wait()
    print("getReactionBlueprints1 got \(foo.count) things")
    return foo
  }
  
  func getManufacturingBlueprint(for typeId: Int64) -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_manufacturing_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .wait()
  }
  
  func getBlueprintModelAsync(for typeId: Int64) async -> BlueprintModel? {
    let db = self.database
    let blueprintModel = try? await BlueprintModel.query(on: db)
      .filter(\.$blueprintTypeID == typeId)
      .first()
      .get()
    
    return blueprintModel
  }
  
  func getManufacturingBlueprintWithInput(of typeId: Int64) async -> [BlueprintModel]? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
    """
      select b.*, value, d.name
      from blueprintModel b, TypeData d,
              json_each(b.activities_manufacturing_materials)
              where json_extract(value, '$.typeId') = \("\(typeId)")
          AND b.blueprintTypeId=d.typeId
          AND d.group_id NOT in (1197)
    """
    
    return try? await sql.raw(SQLQueryString(queryString))
      .all(decoding: BlueprintModel.self)
      
  }
  
  /// Returns the BlueprintModel that has the provided typeId as a product
  func getManufacturingBlueprintAsync(making typeId: Int64) async -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    //print("+++ \(typeId)")
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_manufacturing_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? await sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .get()
  }
  
  func getManufacturingBlueprintsAsync(making typeIds: [Int64]) async -> [BlueprintModel] {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return []
    }
    
    var values = typeIds
    let startString = "\(values.removeFirst())"
    let concatString = values.reduce(startString) { $0 + ",\($1)" }
    //print("concatString: \(concatString)")
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_manufacturing_products)
        where json_extract(value, '$.typeId') IN \("(\(concatString))")
      """
    let result = try? await sql.raw(SQLQueryString(queryString))
      .all(decoding: BlueprintModel.self)
      .get()
    return result ?? []
  }
  
  func getReactionBlueprint(for typeId: Int64) -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_reaction_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .wait()
  }
  
  func getReactionBlueprintAsync(for typeId: Int64) async -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_reaction_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? await sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .get()
  }
  
  func getReactionBlueprintsAsync(making typeIds: [Int64]) async -> [BlueprintModel] {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return []
    }
    var values = typeIds
    let startString = "\(values.removeFirst())"
    let concatString = values.reduce(startString) { $0 + ",\($1)" }

    let queryString =
      """
      select b.*, d.name
      value from blueprintModel b, TypeData d,
      json_each(b.activities_reaction_products)
      where json_extract(value, '$.typeId') in \("(\(concatString))")
      AND b.blueprintTypeId=d.typeId
      AND d.published=true
      """
    let result = try? await sql.raw(SQLQueryString(queryString))
      .all(decoding: BlueprintModel.self)
      .get()
    return result ?? []
  }
  
  func getReactionBlueprintWithInput(of typeId: Int64) async -> [BlueprintModel]? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
    """
      select b.*, value, d.name
      from blueprintModel b, TypeData d,
              json_each(b.activities_reaction_materials)
              where json_extract(value, '$.typeId') = \("\(typeId)")
          AND b.blueprintTypeId=d.typeId
          AND d.group_id in (1888)
          AND d.name NOT LIKE 'Unrefined%'
          AND d.published=true
    """
    
    return try? await sql.raw(SQLQueryString(queryString))
      .all(decoding: BlueprintModel.self)
  }
  
  func getAllESIKillMailModels() async -> [ESIKillmailModel] {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return []
    }

    let queryString =
      """
        SELECT * FROM esi
        INNER JOIN zkill ON esi.killmail_id = zkill.killmail_id
        INNER JOIN solarSystems ON esi.solar_system_id = solarSystems.system_id
        GROUP BY esi.killmail_id
      """
    
    let result = (try? await sql.raw(SQLQueryString(queryString))
      .all(decoding: ESIKillmailModel.self)
      .get()) ?? []
    
    return result
  }
  
  func getReactionBlueprintsWIthInputs(of typeIds: [Int64]) async -> [BlueprintModel] {
    let results = await withTaskGroup(of: [BlueprintModel]?.self, returning: [BlueprintModel].self) { taskGroup in
      for typeId in typeIds {
        taskGroup.addTask {
          let reactionBlueprint = await self.getReactionBlueprintWithInput(of: typeId)
          print("++ reaction blueprint \(reactionBlueprint?.count ?? 0)")
          return reactionBlueprint
        }
      }
      var values: [BlueprintModel] = []
      for await result in taskGroup {
        guard let result = result else {
          continue
        }
        
        values.append(contentsOf: result)
      }
      //let results = try await taskGroup.waitForAll()
      return values//results
    }
    
    return results
  }
  //getManufacturingBlueprintWithInput
  func getManufacturingBlueprintsWithInputs(of typeIds: [Int64]) async -> [BlueprintModel] {
    let results = await withTaskGroup(of: [BlueprintModel]?.self, returning: [BlueprintModel].self) { taskGroup in
      for typeId in typeIds {
        taskGroup.addTask {
          return await self.getManufacturingBlueprintWithInput(of: typeId)
        }
      }
      var values: [BlueprintModel] = []
      for await result in taskGroup {
        guard let result = result else {
          continue
        }
        
        values.append(contentsOf: result)
      }
      //let results = try await taskGroup.waitForAll()
      return values//results
    }
    
    return results
  }
  
  func getBlueprintModel(for typeId: Int64) async -> BlueprintModel? {
    return await self.getBlueprintModelAsync(for: typeId)
  }
}


// MARK: - Character

extension DBManager {
  @MainActor
  func getCharacters() async -> [CharacterDataModel] {
    do {
      return try await CharacterDataModel.query(on: self.database)
        .with(\.$publicData)
        .with(\.$assetsData)
        .all()
        .get()
    } catch let err {
      print("DBManager.getCharacter() - error \(err)")
      return []
    }
  }
  
  func getCharacters() -> [CharacterDataModel] {
    do {
      return try CharacterDataModel.query(on: self.database)
        .with(\.$publicData)
        .with(\.$assetsData)
        .all()
        .wait()
    } catch let err {
      print("DBManager.getCharacter() - error \(err)")
      return []
    }
  }
  func getCharactersWithInfo() async -> [CharacterDataModel] {
    do {
      return try await CharacterDataModel.query(on: self.database)
        .with(\.$publicData)
        .with(\.$assetsData)
        .with(\.$corp)
        .all()
        .get()
      
    } catch let err {
      print("DBManager.getCharacter() - error \(err)")
      return []
    }
  }
  
  func getCharacter(by characterId: String) async -> CharacterDataModel? {
    do {
      return try await  CharacterDataModel.query(on: self.database)
        .filter(\.$characterId == characterId)
        .first()
        .get()
    } catch let err {
      print("DBManager.getCharacter() - error \(err)")
      return nil
    }
  }
  
  func getCharacter(by characterId: String) -> CharacterDataModel? {
    do {
      return try CharacterDataModel.query(on: self.database)
        .filter(\.$characterId == characterId)
        .first()
        .wait()
    } catch let err {
      print("DBManager.getCharacter() - error \(err)")
      return nil
    }
  }
}

// MARK: - Skill Group
extension DBManager {
  func getSkillGroups(for characterId: String) async -> [SkillGroup] {
    guard
      let character =  try! await CharacterDataModel.query(on: self.database)
        .filter(\.$characterId == characterId)
        .with(\.$skillsData)
        .first()
        .get(),
      let skillsData = character.skillsData
    else {
      print("no characterModel found for \(characterId)")
      return []
    }
    
    let skillIds = skillsData.skills.map { Int64($0.skillId) }.sorted(by: { $0 < $1})
    //.join(GroupModel.self, on: \GroupModel.$groupId == \TypeModel.$groupID)
    let typeModels = try! await TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ skillIds)
      .join(TypeDogmaInfoModel.self, on: \TypeDogmaInfoModel.$typeId == \TypeModel.$typeId)
      .all()
      .get()
      .sorted(by: {$0.typeId < $1.typeId})
    
    var skillDict = [Int64: CharacterSkillModel]()
    
    skillsData.skills.forEach { value in
      skillDict[Int64(value.skillId)] = value
    }
    
    let results = typeModels.compactMap { typeModel -> (CharacterSkillModel, TypeModel)? in
      guard let skillModel = skillDict[Int64(typeModel.typeId)] else {
        return nil
      }
      
      return (skillModel, typeModel)
    }
    let start = Date()
    var skillsByGroup: [Int64: [SkillInfo]] = await processStuff(data: results)
    print("creating skills by group took \(Date().timeIntervalSince(start))")
    
    let skillGroups = await makeSkillGroups(skillsByGroup: skillsByGroup)
    //    skillsByGroup.compactMap { key, value -> SkillGroup? in
    //      guard let group = getGroup(for: key) else {
    //        return nil
    //      }
    //      return SkillGroup(group: group, skills: value)
    //    }
    
    return skillGroups
  }
  
  func processStuff(data: [(CharacterSkillModel, TypeModel)]) async -> [Int64: [SkillInfo]] {
    return await withTaskGroup(
      of: SkillInfo?.self,
      returning: [Int64: [SkillInfo]].self
    ) { taskGroup in
      for (skillModel, typeModel) in data {
        taskGroup.addTask {
          return await self.makeSkillInfo(characterSkillModel: skillModel, typeModel: typeModel)
        }
      }
      var skillsByGroup: [Int64: [SkillInfo]] = [:]
      
      for await skillInfo in taskGroup {
        guard let skillInfo = skillInfo else {
          continue
        }
        let groupID = skillInfo.typeModel.groupID
        skillsByGroup[groupID] = (skillsByGroup[groupID] ?? []) + [skillInfo]
      }
      
      return skillsByGroup
    }
  }
  
  func makeSkillInfo(
    characterSkillModel: CharacterSkillModel,
    typeModel: TypeModel
  ) async -> SkillInfo? {
    guard let dogmaInfo = try? typeModel.joined(TypeDogmaInfoModel.self) else {
      return nil
    }
    
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
    
    //let skillEffectInfo = await self.getSkillEffectInfo(for: dogmaInfo)
    
    let skillInfo = SkillInfo(
      skillModel: characterSkillModel,
      typeModel: typeModel,
      dogma: dogmaInfo,
      skillDogmaInfo: skillAttributeInfo,
      skillEffectInfo: SkillEffectInfo(skillDogmaEffectInfos: []),
      skillDescription: typeModel.descriptionString ?? ""
    )
    //print("makeSkillInfo took \(Date().timeIntervalSince(start))")
    return skillInfo
  }
  
  func makeSkillGroups (
    skillsByGroup: [Int64: [SkillInfo]]
  ) async -> [SkillGroup] {
    let skillGroups = await withTaskGroup(
      of: SkillGroup?.self,
      returning: [SkillGroup].self
    ) { taskGroup in
      
      for (groupID, skills) in skillsByGroup {
        taskGroup.addTask {
          guard let group = await self.getGroup(for: groupID) else {
            return nil
          }
          return SkillGroup(group: group, skills: skills)
        }
      }
      
      var skillGroups = [SkillGroup]()
      for await result in taskGroup {
        guard let result = result else {
          continue
        }
        skillGroups.append(result)
      }
      return skillGroups
    }
    
    return skillGroups
  }
  
  func getSkillDogmaAttributeInfo(typeDogma: TypeDogmaInfoModel) -> SkillDogmaAttributeInfo?  {
    // get Dogma attributes from this array and use it to create some display data
    let typeDogmaAttributes = typeDogma.attributes
    let dogmaAttributes = getDogmaAttributes(for: typeDogma)
    let names = dogmaAttributes.map { ($0.name, $0.attributeID) }
    //print("dogmaAttributes \(names)")
    
    var primaryAttribute: DogmaAttributeModel?
    var secondaryAttribute: DogmaAttributeModel?
    var requiredSkills = [Int]()
    var skillTimeConstant = 0
    var attributesByCategory = [Int64: [DogmaAttributeModel]]()
    var skillMiscAttributes: SkillMiscAttributes?

    typeDogma.attributes.forEach { typeDogmaAttribute in
      guard
        let dogmaAttribute = self.getDogmaAttribute(for: typeDogmaAttribute.attributeID),
        let categoryID = dogmaAttribute.categoryID else {
        return
      }
      
      attributesByCategory[categoryID] = (attributesByCategory[categoryID] ?? []) + [dogmaAttribute]
      
      let attributeID = typeDogmaAttribute.attributeID
      switch attributeID {
      case 180:
        primaryAttribute = self.getDogmaAttribute(for: Int64(typeDogmaAttribute.value))
      case 181:
        secondaryAttribute = self.getDogmaAttribute(for: Int64(typeDogmaAttribute.value))
      case 182:
        requiredSkills.append(Int(typeDogmaAttribute.value))
      case 275:
        skillTimeConstant = Int(typeDogmaAttribute.value)
      case 277:
        // required skill level for skill 1
        return
      case 280:
        // level
        return
      case 312:
        return
      case 450:
        // manufacturing slot bonus
        return
      default: return
      }
      // 277, 280, 450, etc can probably just be used as is, i.e. only do special handling
      // for primaryAttribute and secondaryAttribute or possibly only specific categories
      // i.e. required skills 1-3, primary+secondary attribute
    }
    
    guard 
      let primaryAttribute = primaryAttribute,
      let secondaryAttribute = secondaryAttribute,
      let skillMiscAttributes = skillMiscAttributes
    else {
      return nil
    }
    
    let skillDogmaInfo = SkillDogmaAttributeInfo(
      skillMiscAttributes: skillMiscAttributes
    )
    
    return skillDogmaInfo
  }
  
  func makeSkillAttributeInfo(
    typeDogmaAttributes: [TypeDogmaAttribute],
    values: [Int64: [SkillAttributeInfo]]
  ) async -> SkillDogmaAttributeInfo? {
    
    var skillMiscAttributes: SkillMiscAttributes?
    
    if let miscSkillAttributeInfos = values[7] {
      skillMiscAttributes = await self.makeSkillMiscAttributes(attributeInfos: miscSkillAttributeInfos)
    }
    
    guard let skillMiscAttributes = skillMiscAttributes else {
      return nil
    }
    
    return SkillDogmaAttributeInfo(
      skillMiscAttributes: skillMiscAttributes
    )
  }
  
  func getSkillEffectInfo(for typeDogma: TypeDogmaInfoModel) -> SkillEffectInfo {
    let skillEffects = typeDogma.effects
    let skillEffectIDs = skillEffects.map({ $0.effectID })
    let dogmaEffects = getDogmaEffects(for: skillEffectIDs)
    let effectNames = dogmaEffects.map { $0.effectName }
    
    let skillDogmaEffectInfos = dogmaEffects.compactMap { dogmaEffect -> SkillDogmaEffectInfo? in
      guard let typeModel = try? dogmaEffect.joined(TypeModel.self) else {
        return nil
      }
      return SkillDogmaEffectInfo(dogmaEffectModel: dogmaEffect, typeModel: typeModel, effectedAttributes: [])
    }
    
    //print("effectNames \(effectNames)")
    print("got \(skillDogmaEffectInfos.count) effects")
    return SkillEffectInfo(skillDogmaEffectInfos: skillDogmaEffectInfos)
  }
  
  func getSkillEffectInfo(for typeDogma: TypeDogmaInfoModel) async -> SkillEffectInfo {
    let skillEffects = typeDogma.effects
    let skillEffectIDs = skillEffects.map({ $0.effectID })
    let dogmaEffects = await getDogmaEffects(for: skillEffectIDs)
    
    let skillDogmaEffectInfos = await withTaskGroup(
      of: SkillDogmaEffectInfo?.self,
      returning: [SkillDogmaEffectInfo].self
    ) { taskGroup in
      
      dogmaEffects.forEach { dogmaEffect in
        taskGroup.addTask {
          
          return await self.makeSkillDogmaEffectInfo(for: dogmaEffect)
        }
      }
      
      var returnValues: [SkillDogmaEffectInfo] = []
      
      for await result in taskGroup {
        guard let effectInfo = result else {
          continue
        }
        returnValues.append(effectInfo)
      }
      
      return returnValues
    }
    
    
    //print("effectNames \(effectNames)")
    //print("got \(skillDogmaEffectInfos.count) effects")
    return SkillEffectInfo(skillDogmaEffectInfos: skillDogmaEffectInfos)
  }
  
  func makeSkillDogmaEffectInfo(for dogmaEffect: DogmaEffectModel) async -> SkillDogmaEffectInfo? {
    if dogmaEffect.effectCategory == 0 {
      // handle for
      let attributeInfo = await getAttributeInfo(for: dogmaEffect.modifierInfo)
      let typeModel = await getType(for: dogmaEffect.effectID)
      return SkillDogmaEffectInfo(dogmaEffectModel: dogmaEffect, typeModel: nil, effectedAttributes: attributeInfo)
    } else {
      guard let typeModel = await getType(for: dogmaEffect.effectID) else {
        return nil
      }
      
      return SkillDogmaEffectInfo(dogmaEffectModel: dogmaEffect, typeModel: typeModel, effectedAttributes: [])
    }
  }
  
  func getAttributeInfo(for modifierInfos: [ModifierInfo]) async -> [AttributeModifierInfo] {
    let results = await withTaskGroup(
      of: AttributeModifierInfo?.self,
      returning: [AttributeModifierInfo].self
    ) { taskGroup in
      for modifierInfo in modifierInfos {
        taskGroup.addTask {
          //print("modifier \(modifierInfo.domain) \(modifierInfo.function) \(modifierInfo.operation) \(modifierInfo.skillTypeID)")
          guard
            let modifyingDogmaAttribute = await self.getDogmaAttribute(
              for: modifierInfo.modifiyingAttributeID
            ),
            let modifiedDogmaAttribute = await self.getDogmaAttribute(for: modifierInfo.modifiedAttributeID),
            let typeModel = await self.getType(for: modifierInfo.skillTypeID)
                 else {
            return nil
          }
          
          
          return AttributeModifierInfo(
            name: modifyingDogmaAttribute.name,
            modifiedAttributeModel: modifiedDogmaAttribute,
            modifyingAttribute: modifyingDogmaAttribute,
            modifierInfo: modifierInfo,
            skillDescription: typeModel.descriptionString ?? ""
          )
        }
      }
      
      var returnValues = [AttributeModifierInfo]()
      
      for await result in taskGroup {
        guard let result = result else { continue }
        returnValues.append(result)
      }
      
      return returnValues
    }
    
    return results
  }
  
  func makeAttributesByCategory(from typeDogmaAttributes: [TypeDogmaAttribute]) async -> [Int64: [DogmaAttributeModel]] {
    let start = Date()
    
    let result: [Int64: [DogmaAttributeModel]] = await withTaskGroup(
      of: (DogmaAttributeModel, TypeDogmaAttribute)?.self,
      returning: [Int64: [DogmaAttributeModel]].self
    ) { taskGroup in
      for typeDogmaAttribute in typeDogmaAttributes {
        taskGroup.addTask {
          guard
            let dogmaAttribute = await self.getDogmaAttribute(for: typeDogmaAttribute.attributeID),
            dogmaAttribute.categoryID != nil else {
            return nil
          }
          return (dogmaAttribute, typeDogmaAttribute)
        }
      }
      
      var requiredSkills = [Int]()
      var skillTimeConstant = 0
      
      var attributesByCategory = [Int64: [DogmaAttributeModel]]()
      
      for await result in taskGroup {
        guard
          let dogmaAttributeModel = result?.0,
          let categoryID = dogmaAttributeModel.categoryID
        else {
          continue
        }
        
        attributesByCategory[categoryID] = (attributesByCategory[categoryID] ?? []) + [dogmaAttributeModel]
      }
      return attributesByCategory
    }
    //print("makeSkillAttributeInfo took \(Date().timeIntervalSince(start))")
    return result
  }
  
  func getAttributeModels(for typeDogmaAttributes: [TypeDogmaAttribute]) async -> [Int64: DogmaAttributeModel] {
    let start = Date()
    
    let result: [Int64: DogmaAttributeModel] = await withTaskGroup(
      of: (DogmaAttributeModel, TypeDogmaAttribute)?.self,
      returning: [Int64: DogmaAttributeModel].self
    ) { taskGroup in
      for typeDogmaAttribute in typeDogmaAttributes {
        taskGroup.addTask {
          guard
            let dogmaAttribute = await self.getDogmaAttribute(for: typeDogmaAttribute.attributeID),
            dogmaAttribute.categoryID != nil else {
            return nil
          }
          return (dogmaAttribute, typeDogmaAttribute)
        }
      }
      
      var requiredSkills = [Int]()
      var skillTimeConstant = 0
      
      var attributesByID = [Int64: DogmaAttributeModel]()
      
      for await result in taskGroup {
        guard
          let dogmaAttributeModel = result?.0
        else {
          continue
        }
        
        attributesByID[dogmaAttributeModel.attributeID] = dogmaAttributeModel
      }
      return attributesByID
    }
    //print("makeSkillAttributeInfo took \(Date().timeIntervalSince(start))")
    return result
  }
  
  func getAttributeCategoryModels(for categoryIDs: [Int64]) async -> [Int64: DogmaAttributeCategoryModel] {
    var values: [DogmaAttributeCategoryModel] = []
    do {
      values = try await DogmaAttributeCategoryModel.query(on: database)
        .filter(\.$categoryId ~~ categoryIDs)
        .all()
        .get()
    } catch let err {
      print("err \(err)")
    }
    var returnValues: [Int64: DogmaAttributeCategoryModel] = [:]
    
    values.forEach { dogmaAttributeCategoryModel in
      returnValues[dogmaAttributeCategoryModel.categoryId] = dogmaAttributeCategoryModel
    }
    
    return returnValues
  }
  
  func makeValues(
    values: [TypeDogmaAttribute],
    for attributeModels: [Int64: DogmaAttributeModel],
    categoryModels: [Int64: DogmaAttributeCategoryModel]
  ) async -> [Int64: [SkillAttributeInfo]] {
    
    let skillAttributeInfos = values.compactMap { typeDogmaAttribute -> SkillAttributeInfo? in
      guard
        let attributeModel = attributeModels[typeDogmaAttribute.attributeID],
        let categoryID = attributeModel.categoryID,
        let attributeCategoryModel = categoryModels[categoryID]
      else {
        return nil
      }
      
      return SkillAttributeInfo(
        typeDogmaAttribute: typeDogmaAttribute,
        attributeModel: attributeModel,
        attributeCategoryModel: attributeCategoryModel
      )
    }
    
    var skillAttributeInfosByCategoryID = [Int64: [SkillAttributeInfo]]()
    
    skillAttributeInfos.forEach { skillAttributeInfo in
      let categoryID = skillAttributeInfo.attributeCategoryModel.categoryId
      skillAttributeInfosByCategoryID[categoryID] = (skillAttributeInfosByCategoryID[categoryID] ?? []) + [skillAttributeInfo]
    }
    
    return skillAttributeInfosByCategoryID
  }
  
  func makeSkillAttributeDomgaInfo(from values: [Int64: [SkillAttributeInfo]]) async {
    var skillMiscAttributes: SkillMiscAttributes?
    for (key, value) in values {
      //print("key \(key), value \(value.count)")
      if key == 7 {
        skillMiscAttributes = await makeSkillMiscAttributes(attributeInfos: value)
      } else if key == 8 {
        let foo = value.map { $0.attributeModel.name }
        //print("\(key) names: \(foo)")
      } else if key == 9 || key == 37 {
        let foo = value.map { $0.attributeModel.name }
        print("\(key) names: \(foo)")
      }
    }
      
  }
  
  func makeSkillMiscAttributes(attributeInfos: [SkillAttributeInfo]) async -> SkillMiscAttributes? {
    var primaryAttribute: DogmaAttributeModel?
    var secondaryAttribute: DogmaAttributeModel?
    var skillTimeConstant: Int?
    
    for attributeInfo in attributeInfos {
      let typeDogmaAttribute = attributeInfo.typeDogmaAttribute
      
      switch typeDogmaAttribute.attributeID {
      case 180:
        primaryAttribute = await self.getDogmaAttribute(for: Int64(typeDogmaAttribute.value))
      case 181:
        secondaryAttribute = await self.getDogmaAttribute(for: Int64(typeDogmaAttribute.value))
      case 275:
        skillTimeConstant = Int(typeDogmaAttribute.value)

      default:
          // process as extra data related to what the skill does
        continue
      }
    }
    
    guard
      let primaryAttribute = primaryAttribute,
        let secondaryAttribute = secondaryAttribute,
        let skillTimeConstant = skillTimeConstant
    else {
      return nil
    }
    
    return SkillMiscAttributes(
      primaryAttribute: primaryAttribute,
      secondaryAttribute: secondaryAttribute,
      skillTimeConstant: skillTimeConstant
    )
  }
  
  func makeRequiredSkills(attributeInfos: [SkillAttributeInfo]) async -> SkillSkillRequirements? {
  
    return nil
  }
}

// MARK: - IndustryJobs {
extension DBManager {
  func getIndustryJobModels() async -> [CharacterIndustryJobModel] {
    do {
      let result = try await CharacterIndustryJobModel
        .query(on: self.database)
        .all()
      
      //try await getIndustryJobDisplayInfo(data: result)
      
      return result
    } catch let error {
      print("query error: \(error.localizedDescription)")
      return []
    }
  }
  
  func getIndustryJobDisplayInfo(data: [CharacterIndustryJobModel]) async throws -> [IndustryJobDisplayable] {
    let result = await withTaskGroup(of: IndustryJobDisplayable?.self, returning: [IndustryJobDisplayable].self) { taskGroup in
      for value in data {
        taskGroup.addTask {
          return try? await self.getIndustryJobDisplayInfo(for: value)
        }
      }
      var returnValue: [IndustryJobDisplayable] = []
      
      for await response in taskGroup {
        guard let response = response else { continue }
        returnValue.append(response)
      }
      
      return returnValue
    }
    
    return result
  }
  
  func getIndustryJobDisplayInfo(
    for jobModel: CharacterIndustryJobModel
  ) async throws -> IndustryJobDisplayable {
    let blueprintId = jobModel.blueprintTypeId
    let locationId = jobModel.blueprintLocationId
    
    let productTypeId = jobModel.productTypeId
    
    let blueprintName = try await getBlueprintName(blueprintId)
    let blueprintLocationName = try await getBlueprintLocationName(locationId)
    var productName: String? = nil
    
    if let productTypeId {
      productName = await getType(for: productTypeId)?.name
    }
    
    return IndustryJobDisplayable(
      industryJobModel: jobModel,
      blueprintName: blueprintName,
      blueprintLocationName: blueprintLocationName,
      productName: productName
    )
  }
  
  func getBlueprintName(_ typeId: Int64) async throws -> String {
    print("get blueprint name for \(typeId)")
    guard let blueprint = try await BlueprintModel.query(on: database)
      .filter(\.$blueprintTypeID == typeId)
      .join(TypeModel.self, on: \TypeModel.$typeId == \BlueprintModel.$blueprintTypeID)
      .first()
      .get()
    else {
     return ""
   }
    
    let typeModel = try blueprint.joined(TypeModel.self)
    
    return typeModel.name
  }
  
  func getBlueprintNames(_ typeIds: [Int64]) async throws -> [(Int64, String)] {
//    let manufacturing = await getManufacturingBlueprintsWithInputs(of: typeIds)
//    let reactions = await getReactionBlueprintsWIthInputs(of: typeIds)
//    let blueprintIds = (manufacturing + reactions).map { $0.blueprintTypeID }
    let result = await withTaskGroup(
      of: (Int64, String?).self,
      returning: [(Int64, String)].self
    ) { taskGroup in
      for typeId in typeIds {
        taskGroup.addTask {
          let name = try? await self.getBlueprintName(typeId)
          return (typeId, name)
        }
      }
      
      var returnValues: [(Int64, String)] = []
      for await result in taskGroup {
        guard let name = result.1 else { continue }
        returnValues.append((result.0, name))
      }
      return returnValues
    }
    return result
  }
  
  func getBlueprintId(named name: String) async -> Int64? {
    let db = await DataManager.shared.dbManager!.database
    let typeModel = try? await TypeModel.query(on: db)
      .filter(\.$name == name).first()
      .get()
    return typeModel?.typeId
  }
  
  func getBlueprintLocationName(_ locationId: Int64) async throws -> String {
    return "UNKNOWN_LOCATION"
  }
}

// MARK: - Assets
extension DBManager {
  // Helper to get all character assets that match the blueprint inputs
  func getCharacterAssetsForBlueprint1(characterID: String, blueprintId: Int64) async -> [AssetQuantityInfo] {
    guard let blueprintModel = await getBlueprintModel(for: blueprintId) else {
      return []
    }
    
    var assetIds: Set<Int64> = []
    
    let reactionInputs = blueprintModel.activities.reaction.materials
    let manufacturingInputs = blueprintModel.activities.manufacturing.materials
    
    // insert inputs into a set
    reactionInputs.forEach { assetIds.insert($0.typeId) }
    manufacturingInputs.forEach { assetIds.insert($0.typeId) }
    
    return await getCharacterAssetsForValues(
      characterID: characterID,
      typeIds: Array(assetIds)
    )
  }
  
  func getCharacterAssetsForBlueprint(characterID: String, blueprintId: Int64) async -> [AssetInfoDisplayable] {
    guard let blueprintModel = await getBlueprintModel(for: blueprintId) else {
      return []
    }
    
    var assetIds: Set<Int64> = []
    
    let reactionInputs = blueprintModel.activities.reaction.materials
    let manufacturingInputs = blueprintModel.activities.manufacturing.materials
    
    // insert inputs into a set
    reactionInputs.forEach { assetIds.insert($0.typeId) }
    manufacturingInputs.forEach { assetIds.insert($0.typeId) }
    
    // get character assets for unique values, since
    let characterAssets = await getCharacterAssetsForValues(
      characterID: characterID,
      typeIds: Array(assetIds)
    )
    
    var assetDict: [Int64: Int64] = [:]
    
    for asset in characterAssets {
      assetDict[asset.typeId, default: 0] += asset.quantity
    }
    
    let typeModels = getTypes(for: Array(assetIds))
    
    let returnValues = typeModels.map { value in
      TypeQuantityDisplayable(quantity: assetDict[value.typeId, default: 0], typeModel: value)
    }
    
    //TypeQuantityDisplayable
    return []
  }
  
  func getDisplayableCharacterAssetsForBlueprint(
    characterID: String,
    blueprintId: Int64
  ) async -> [TypeQuantityDisplayable] {
    guard let blueprintModel = await getBlueprintModel(for: blueprintId) else {
      return []
    }
    
    var assetIds: Set<Int64> = []
    
    let reactionInputs = blueprintModel.activities.reaction.materials
    let manufacturingInputs = blueprintModel.activities.manufacturing.materials
    
    // insert inputs into a set
    reactionInputs.forEach { assetIds.insert($0.typeId) }
    manufacturingInputs.forEach { assetIds.insert($0.typeId) }
    
    // get character assets for unique values, since
    let characterAssets = await getCharacterAssetsForValues(
      characterID: characterID,
      typeIds: Array(assetIds)
    )
    
    var assetDict: [Int64: Int64] = [:]
    var blueprintInputDict: [Int64: Int64] = [:]
    
    for reactionInput in reactionInputs {
      blueprintInputDict[reactionInput.typeId, default: 0] += reactionInput.quantity
    }
    
    for manufacturingInput in manufacturingInputs {
      blueprintInputDict[manufacturingInput.typeId, default: 0] += manufacturingInput.quantity
    }
    
    for asset in characterAssets {
      assetDict[asset.typeId, default: 0] += asset.quantity
    }
    
    let keySet1: Set<Int64> = Set(blueprintInputDict.keys)
    let keySet2: Set<Int64> = Set(assetDict.keys)
    
    let keySet3: Set<Int64> = keySet1.symmetricDifference(keySet2)
    let keySet4: Set<Int64> = keySet2.symmetricDifference(keySet1)
    
    print("keySet3 \(keySet3)")
    print("keySet4 \(keySet4)")
    
    let typeModels = getTypes(for: Array(assetIds))
    
    let returnValues: [TypeQuantityDisplayable] = typeModels.compactMap { value -> TypeQuantityDisplayable? in
      guard let existingValue = assetDict[value.typeId] else {
        return nil
      }
      
      return TypeQuantityDisplayable(quantity: existingValue, typeModel: value)
    }
    
    return returnValues
  }
  
  // gets the assets a character has that matches in blueprint inputs
  func getCharacterAssetsForReaction(
    characterID: String,
    blueprintModel: BlueprintModel
  ) async -> [AssetInfoDisplayable] {
    let materials: [QuantityTypeModel] = blueprintModel.activities.reaction.materials
    let materialIDs: [Int64] = materials.map({ $0.typeId })
    
    return await getCharacterAssetsWithTypeForValues(characterID: characterID, typeIds: materialIDs)
  }
  
  // gets the assets a character has that matches in blueprint inputs
  func getCharacterAssetsWithTypeForValues(
    characterID: String,
    typeIds: [Int64]
  ) async -> [AssetInfoDisplayable] {
    
    guard let character = await getCharacter(by: characterID) else { return [] }
    
    let assets = try! await character.$assetsData.query(on: database)
      .filter(\.$typeId ~~ typeIds)
      .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId)
      .all()
      .get()
    
    // not necessary
    let results = assets.map { asset in
      let typeModel = try! asset.joined(TypeModel.self)
      return AssetInfoDisplayable(asset: asset, typeModel: typeModel)
    }
      
    return results
  }
  
  func getCharacterAssetsWithTypeForValues(
    characterID: String,
    typeIds: [Int64]
  ) -> [AssetInfoDisplayable] {
    
    guard let character = getCharacter(by: characterID) else { return [] }
    
    let assets = try! character.$assetsData.query(on: database)
      .filter(\.$typeId ~~ typeIds)
      .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId)
      .all()
      .wait()
    
    // not necessary
    let results = assets.map { asset in
      let typeModel = try! asset.joined(TypeModel.self)
      return AssetInfoDisplayable(asset: asset, typeModel: typeModel)
    }
      
    return results
  }
  
  func getCharacterAssetsForValues(
    characterID: String,
    typeIds: [Int64]
  ) async -> [AssetQuantityInfo] {
    guard let character = await getCharacter(by: characterID) else { return [] }
    
    let assets = try! await character.$assetsData.query(on: database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .get()

    return assets.map { AssetQuantityInfo(typeId: $0.typeId, quantity: Int64($0.quantity)) }
  }
}

// MARK: - TypeModel

extension DBManager {
  func searchTypeName(searchText: String) -> [IdentifiedString] {
    do {
      let results = try TypeModel.query(on: database)
        .filter(\.$name ~~ searchText)
        .all()
        .wait()
      return results.map { IdentifiedString(id: $0.typeId, value: $0.name) }
    } catch let err {
      print("search type name error \(err)")
      return []
    }
  }
}

struct AssetQuantityInfo {
  let typeId: Int64
  let quantity: Int64
}

struct SkillAttributeInfo {
  let typeDogmaAttribute: TypeDogmaAttribute
  let attributeModel: DogmaAttributeModel
  let attributeCategoryModel: DogmaAttributeCategoryModel
}

struct SkillMiscAttributes {
  let primaryAttribute: DogmaAttributeModel
  let secondaryAttribute: DogmaAttributeModel
  let skillTimeConstant: Int
}

struct SkillSkillRequirements {
  let requiredSkill1: Int64
  let requiredSkill1Level: Int
}
