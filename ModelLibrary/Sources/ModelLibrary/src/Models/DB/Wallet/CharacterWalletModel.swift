//
//  CharacterWalletModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 12/10/24.
//
import Foundation
import Fluent


final public class CharacterWalletModel: Model, @unchecked Sendable {
  static public let schema = Schemas.characterWalletModel.rawValue
  
  @ID(key: .id) public var id: UUID?
  
  @Parent(key: "character_id")
  public var characterDataModel: CharacterDataModel
  
  @Field(key: "balance")
  public var balance: Double?
  
  @Children(for: \.$walletModel)
  public var journalEntries: [CharacterWalletJournalEntryModel]
  
  @Children(for: \.$walletModel)
  public var transactions: [CharacterWalletTransactionModel]
  
  public init() { }
  
  public struct ModelMigration: AsyncMigration {
    public init() { }
    public func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(CharacterWalletModel.schema)
        .id()
        .field(
          "character_id",
          .uuid,
          .required,
          .references(Schemas.characterDataModel.rawValue, "id")
        )
        .field("balance", .double)
        .unique(on: "character_id")
        .create()
    }
    
    public func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(CharacterWalletModel.schema)
        .delete()
    }
  }
  
}

final public class CharacterWalletJournalEntryModel: Model, @unchecked Sendable {
  static public let schema = Schemas.characterWalletJournalEntryModel.rawValue
  
  @ID(custom: "character_wallet_journal_entry_id", generatedBy: .user)
  public var id: Int64?
  
  @Parent(key: "walletId")
  var walletModel: CharacterWalletModel
  
  @Field(key: "amount")
  public var amount: Double?
  
  @Field(key: "balance")
  public var balance: Double?
  
  @Field(key: "contextId")
  public var contextId: Int64?
  
  @Field(key: "contextIdType")
  public var contextIdType: String?//ContextIdType?
  
  @Field(key: "date")
  public var date: Date
  
  @Field(key: "entryDescription")
  public var entryDescription: String
  
  @Field(key: "firstPartyId")
  public var firstPartyId: Int?
  
  @Field(key: "journalId")
  public var journalId: Int64
  
  @Field(key: "reason")
  public var reason: String?
  
  @Field(key: "refType")
  public var refType: String//RefType
  
  @Field(key: "secondPartyId")
  public var secondPartyId: Int?
  
  @Field(key: "tax")
  public var tax: Double?
  
  @Field(key: "taxReceiverId")
  public var taxReceiverId: Int?
  
  public init() {}
  
  public init(
    id: Int64,
    amount: Double? = nil,
    balance: Double? = nil,
    contextId: Int64? = nil, contextIdType: String? = nil, date: Date, _description: String, firstPartyId: Int? = nil, _id: Int64, reason: String? = nil, refType: String, secondPartyId: Int? = nil, tax: Double? = nil, taxReceiverId: Int? = nil) {
      self.amount = amount
      self.balance = balance
      self.contextId = contextId
      self.contextIdType = contextIdType
      self.date = date
      self.entryDescription = _description
      self.firstPartyId = firstPartyId
      self.journalId = _id
      self.reason = reason
      self.refType = refType
      self.secondPartyId = secondPartyId
      self.tax = tax
      self.taxReceiverId = taxReceiverId
      self.id = id
    }
  
  public init(data: GetCharactersCharacterIdWalletJournal) {
    self.amount = data.amount
    self.balance = data.balance
    self.contextId = data.contextId
    self.contextIdType = data.contextIdType?.rawValue ?? ""
    self.date = ISO8601DateFormatter().date(from:data.date) ?? Date()//Date(rfc1123: data.date) ?? Date()
    self.entryDescription = data._description
    self.firstPartyId = data.firstPartyId
    self.journalId = data._id
    self.reason = data.reason
    self.refType = data.refType.rawValue
    self.secondPartyId = data.secondPartyId
    self.tax = data.tax
    self.taxReceiverId = data.taxReceiverId
    self.id = data._id
  }
  
  public struct ModelMigration: AsyncMigration {
    public init() { }
    public func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(CharacterWalletJournalEntryModel.schema)
        .id()
        .field("character_wallet_journal_entry_id", .int64)
        .field(
          "walletId",
          .uuid,
          .required,
          .references(Schemas.characterWalletModel.rawValue, "id")
        )
        .field("amount", .double)
        .field("balance", .double)
        .field("contextId", .int64)
        .field("contextIdType", .string)
        .field("date", .date)
        .field("entryDescription", .string, .required)
        .field("firstPartyId", .int)
        .field("journalId", .int64)
        .field("reason", .string)
        .field("refType", .string)
        .field("secondPartyId", .int)
        .field("tax", .double)
        .field("taxReceiverId", .int)
        .unique(on: "character_wallet_journal_entry_id")
        .create()
    }
    
    public func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(CharacterWalletJournalEntryModel.schema)
        .delete()
    }
  }
}

final public class CharacterWalletTransactionModel: Model, @unchecked Sendable {
  static public let schema = Schemas.characterWalletTransactionModel.rawValue
  
  @ID(custom: "character_wallet_transaction_id", generatedBy: .user)
  public var id: Int64?
  
  @Parent(key: "walletId")
  var walletModel: CharacterWalletModel
  
  @Field(key: "clientId")
  public var clientId: Int
  
  @Field(key: "date")
  public var date: String
  
  @Field(key: "isBuy")
  public var isBuy: Bool
  
  @Field(key: "isPersonal")
  public var isPersonal: Bool
  
  @Field(key: "journalRefId")
  public var journalRefId: Int64
  
  @Field(key: "locationId")
  public var locationId: Int64
  
  @Field(key: "quantity")
  public var quantity: Int
  
  @Field(key: "transactionId")
  public var transactionId: Int64
  
  @Field(key: "typeId")
  public var typeId: Int
  
  @Field(key: "unitPrice")
  public var unitPrice: Double
  
  public init(id: Int64, clientId: Int, date: String, isBuy: Bool, isPersonal: Bool, journalRefId: Int64, locationId: Int64, quantity: Int, transactionId: Int64, typeId: Int, unitPrice: Double) {
    self.id = id
    self.clientId = clientId
    self.date = date
    self.isBuy = isBuy
    self.isPersonal = isPersonal
    self.journalRefId = journalRefId
    self.locationId = locationId
    self.quantity = quantity
    self.transactionId = transactionId
    self.typeId = typeId
    self.unitPrice = unitPrice
  }
  
  public init(data: GetCharactersCharacterIdWalletTransactions200Ok) {
    self.id = data.transactionId
    self.clientId = data.clientId
    self.date = data.date
    self.isBuy = data.isBuy
    self.isPersonal = data.isPersonal
    self.journalRefId = data.journalRefId
    self.locationId = data.locationId
    self.quantity = data.quantity
    self.transactionId = data.transactionId
    self.typeId = data.typeId
    self.unitPrice = data.unitPrice
  }
  
  public init() { }
  
  public struct ModelMigration: AsyncMigration {
    public init() { }
    public func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(CharacterWalletTransactionModel.schema)
        .id()
        .field("character_wallet_transaction_id", .int64)
        .field(
          "walletId",
          .uuid,
          .required,
          .references(Schemas.characterWalletModel.rawValue, "id")
        )
        .field("clientId", .int, .required)
        .field("date", .string, .required)
        .field("isBuy", .bool, .required)
        .field("isPersonal", .bool, .required)
        .field("journalRefId", .int64, .required)
        .field("locationId", .int64, .required)
        .field("quantity", .int, .required)
        .field("transactionId", .int64, .required)
        .field("typeId", .int, .required)
        .field("unitPrice", .double, .required)
        .unique(on: "character_wallet_transaction_id")
        .create()
    }
    
    public func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(CharacterWalletTransactionModel.schema)
        .delete()
    }
  }
}

public struct GetCharactersCharacterIdWalletJournal: Codable {
  
  public enum ContextIdType: String, Codable {
    case structureId = "structure_id"
    case stationId = "station_id"
    case marketTransactionId = "market_transaction_id"
    case characterId = "character_id"
    case corporationId = "corporation_id"
    case allianceId = "alliance_id"
    case eveSystem = "eve_system"
    case industryJobId = "industry_job_id"
    case contractId = "contract_id"
    case planetId = "planet_id"
    case systemId = "system_id"
    case typeId = "type_id"
  }
  
  public enum RefType: String, Codable {
    case accelerationGateFee = "acceleration_gate_fee"
    case advertisementListingFee = "advertisement_listing_fee"
    case agentDonation = "agent_donation"
    case agentLocationServices = "agent_location_services"
    case agentMiscellaneous = "agent_miscellaneous"
    case agentMissionCollateralPaid = "agent_mission_collateral_paid"
    case agentMissionCollateralRefunded = "agent_mission_collateral_refunded"
    case agentMissionReward = "agent_mission_reward"
    case agentMissionRewardCorporationTax = "agent_mission_reward_corporation_tax"
    case agentMissionTimeBonusReward = "agent_mission_time_bonus_reward"
    case agentMissionTimeBonusRewardCorporationTax = "agent_mission_time_bonus_reward_corporation_tax"
    case agentSecurityServices = "agent_security_services"
    case agentServicesRendered = "agent_services_rendered"
    case agentsPreward = "agents_preward"
    case allianceMaintainanceFee = "alliance_maintainance_fee"
    case allianceRegistrationFee = "alliance_registration_fee"
    case assetSafetyRecoveryTax = "asset_safety_recovery_tax"
    case bounty = "bounty"
    case bountyPrize = "bounty_prize"
    case bountyPrizeCorporationTax = "bounty_prize_corporation_tax"
    case bountyPrizes = "bounty_prizes"
    case bountyReimbursement = "bounty_reimbursement"
    case bountySurcharge = "bounty_surcharge"
    case brokersFee = "brokers_fee"
    case cloneActivation = "clone_activation"
    case cloneTransfer = "clone_transfer"
    case contrabandFine = "contraband_fine"
    case contractAuctionBid = "contract_auction_bid"
    case contractAuctionBidCorp = "contract_auction_bid_corp"
    case contractAuctionBidRefund = "contract_auction_bid_refund"
    case contractAuctionSold = "contract_auction_sold"
    case contractBrokersFee = "contract_brokers_fee"
    case contractBrokersFeeCorp = "contract_brokers_fee_corp"
    case contractCollateral = "contract_collateral"
    case contractCollateralDepositedCorp = "contract_collateral_deposited_corp"
    case contractCollateralPayout = "contract_collateral_payout"
    case contractCollateralRefund = "contract_collateral_refund"
    case contractDeposit = "contract_deposit"
    case contractDepositCorp = "contract_deposit_corp"
    case contractDepositRefund = "contract_deposit_refund"
    case contractDepositSalesTax = "contract_deposit_sales_tax"
    case contractPrice = "contract_price"
    case contractPricePaymentCorp = "contract_price_payment_corp"
    case contractReversal = "contract_reversal"
    case contractReward = "contract_reward"
    case contractRewardDeposited = "contract_reward_deposited"
    case contractRewardDepositedCorp = "contract_reward_deposited_corp"
    case contractRewardRefund = "contract_reward_refund"
    case contractSalesTax = "contract_sales_tax"
    case copying = "copying"
    case corporateRewardPayout = "corporate_reward_payout"
    case corporateRewardTax = "corporate_reward_tax"
    case corporationAccountWithdrawal = "corporation_account_withdrawal"
    case corporationBulkPayment = "corporation_bulk_payment"
    case corporationDividendPayment = "corporation_dividend_payment"
    case corporationLiquidation = "corporation_liquidation"
    case corporationLogoChangeCost = "corporation_logo_change_cost"
    case corporationPayment = "corporation_payment"
    case corporationRegistrationFee = "corporation_registration_fee"
    case courierMissionEscrow = "courier_mission_escrow"
    case cspa = "cspa"
    case cspaofflinerefund = "cspaofflinerefund"
    case dailyChallengeReward = "daily_challenge_reward"
    case datacoreFee = "datacore_fee"
    case dnaModificationFee = "dna_modification_fee"
    case dockingFee = "docking_fee"
    case duelWagerEscrow = "duel_wager_escrow"
    case duelWagerPayment = "duel_wager_payment"
    case duelWagerRefund = "duel_wager_refund"
    case essEscrowTransfer = "ess_escrow_transfer"
    case externalTradeDelivery = "external_trade_delivery"
    case externalTradeFreeze = "external_trade_freeze"
    case externalTradeThaw = "external_trade_thaw"
    case factorySlotRentalFee = "factory_slot_rental_fee"
    case fluxPayout = "flux_payout"
    case fluxTax = "flux_tax"
    case fluxTicketRepayment = "flux_ticket_repayment"
    case fluxTicketSale = "flux_ticket_sale"
    case gmCashTransfer = "gm_cash_transfer"
    case industryJobTax = "industry_job_tax"
    case infrastructureHubMaintenance = "infrastructure_hub_maintenance"
    case inheritance = "inheritance"
    case insurance = "insurance"
    case itemTraderPayment = "item_trader_payment"
    case jumpCloneActivationFee = "jump_clone_activation_fee"
    case jumpCloneInstallationFee = "jump_clone_installation_fee"
    case killRightFee = "kill_right_fee"
    case lpStore = "lp_store"
    case manufacturing = "manufacturing"
    case marketEscrow = "market_escrow"
    case marketFinePaid = "market_fine_paid"
    case marketProviderTax = "market_provider_tax"
    case marketTransaction = "market_transaction"
    case medalCreation = "medal_creation"
    case medalIssued = "medal_issued"
    case milestoneRewardPayment = "milestone_reward_payment"
    case missionCompletion = "mission_completion"
    case missionCost = "mission_cost"
    case missionExpiration = "mission_expiration"
    case missionReward = "mission_reward"
    case officeRentalFee = "office_rental_fee"
    case operationBonus = "operation_bonus"
    case opportunityReward = "opportunity_reward"
    case planetaryConstruction = "planetary_construction"
    case planetaryExportTax = "planetary_export_tax"
    case planetaryImportTax = "planetary_import_tax"
    case playerDonation = "player_donation"
    case playerTrading = "player_trading"
    case projectDiscoveryReward = "project_discovery_reward"
    case projectDiscoveryTax = "project_discovery_tax"
    case reaction = "reaction"
    case redeemedIskToken = "redeemed_isk_token"
    case releaseOfImpoundedProperty = "release_of_impounded_property"
    case repairBill = "repair_bill"
    case reprocessingTax = "reprocessing_tax"
    case researchingMaterialProductivity = "researching_material_productivity"
    case researchingTechnology = "researching_technology"
    case researchingTimeProductivity = "researching_time_productivity"
    case resourceWarsReward = "resource_wars_reward"
    case reverseEngineering = "reverse_engineering"
    case seasonChallengeReward = "season_challenge_reward"
    case securityProcessingFee = "security_processing_fee"
    case shares = "shares"
    case skillPurchase = "skill_purchase"
    case sovereignityBill = "sovereignity_bill"
    case storePurchase = "store_purchase"
    case storePurchaseRefund = "store_purchase_refund"
    case structureGateJump = "structure_gate_jump"
    case transactionTax = "transaction_tax"
    case upkeepAdjustmentFee = "upkeep_adjustment_fee"
    case warAllyContract = "war_ally_contract"
    case warFee = "war_fee"
    case warFeeSurrender = "war_fee_surrender"
  }
  /** The amount of ISK given or taken from the wallet as a result of the given transaction. Positive when ISK is deposited into the wallet and negative when ISK is withdrawn */
  public var amount: Double?
  /** Wallet balance after transaction occurred */
  public var balance: Double?
  /** An ID that gives extra context to the particular transaction. Because of legacy reasons the context is completely different per ref_type and means different things. It is also possible to not have a context_id */
  public var contextId: Int64?
  /** The type of the given context_id if present */
  public var contextIdType: ContextIdType?
  /** Date and time of transaction */
  public var date: String
  /** The reason for the transaction, mirrors what is seen in the client */
  public var _description: String
  /** The id of the first party involved in the transaction. This attribute has no consistency and is different or non existant for particular ref_types. The description attribute will help make sense of what this attribute means. For more info about the given ID it can be dropped into the /universe/names/ ESI route to determine its type and name */
  public var firstPartyId: Int?
  /** Unique journal reference ID */
  public var _id: Int64
  /** The user stated reason for the transaction. Only applies to some ref_types */
  public var reason: String?
  /** \&quot;The transaction type for the given. transaction. Different transaction types will populate different attributes.\&quot; */
  public var refType: RefType
  /** The id of the second party involved in the transaction. This attribute has no consistency and is different or non existant for particular ref_types. The description attribute will help make sense of what this attribute means. For more info about the given ID it can be dropped into the /universe/names/ ESI route to determine its type and name */
  public var secondPartyId: Int?
  /** Tax amount received. Only applies to tax related transactions */
  public var tax: Double?
  /** The corporation ID receiving any tax paid. Only applies to tax related transactions */
  public var taxReceiverId: Int?
  
  public init(amount: Double? = nil, balance: Double? = nil, contextId: Int64? = nil, contextIdType: ContextIdType? = nil, date: String, _description: String, firstPartyId: Int? = nil, _id: Int64, reason: String? = nil, refType: RefType, secondPartyId: Int? = nil, tax: Double? = nil, taxReceiverId: Int? = nil) {
    self.amount = amount
    self.balance = balance
    self.contextId = contextId
    self.contextIdType = contextIdType
    self.date = date
    self._description = _description
    self.firstPartyId = firstPartyId
    self._id = _id
    self.reason = reason
    self.refType = refType
    self.secondPartyId = secondPartyId
    self.tax = tax
    self.taxReceiverId = taxReceiverId
  }
  
  public enum CodingKeys: String, CodingKey {
    case amount
    case balance
    case contextId = "context_id"
    case contextIdType = "context_id_type"
    case date
    case _description = "description"
    case firstPartyId = "first_party_id"
    case _id = "id"
    case reason
    case refType = "ref_type"
    case secondPartyId = "second_party_id"
    case tax
    case taxReceiverId = "tax_receiver_id"
  }
  
}
