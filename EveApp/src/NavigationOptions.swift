/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An enumeration of navigation options in the app.
*/

import SwiftUI

enum SideBarItem: String, Identifiable, CaseIterable {
  var id: String { rawValue }
  
  case auth
  case skills
  case algoHelper
  case industryPlanner
  case characterInfo
  case industryHelper
  case reprocessingHelper
  case blueprintExplorer
  case devSettings
  case assets
  case potentialIndustry
  case reactionHelper
  case killboard
  case characterIndustryView
  case wallet
  case search
  
  var symbolName: String {
      switch self {
      default: "map"
//      case .landmarks: "building.columns"
//      case .map: "map"
//      case .collections: "book.closed"
      }
  }
}

/// An enumeration of navigation options in the app.
enum NavigationOptions: Equatable, Hashable, Identifiable {
    case auth
    case skills
    case algoHelper
    case industryPlanner
    case characterInfo
    case industryHelper
    case reprocessingHelper
    case blueprintExplorer
    case devSettings
    case assets
    case potentialIndustry
    case reactionHelper
    case killboard
    case characterIndustryView
    case wallet
    case search
    
    static let mainPages: [NavigationOptions] = [.auth, .characterInfo, .skills,.killboard]
    
    var id: String {
        switch self {
        case .auth: return "Auth"
        case .characterInfo: return "Character Info"
        case .skills: return "Skills"
        case .killboard: return "Killboard"
        default: return ""
        }
    }
    
    var name: LocalizedStringResource {
        switch self {
        case .auth: return "Auth"
        case .characterInfo: return "Character Info"
        case .skills: return "Skills"
        case .killboard: return "Killboard"
        default: return "Default"
        }
    }
    
    var symbolName: String {
        switch self {
        case .auth: "lock"
        case .characterInfo: "person.crop.circle"
        case .skills: "list.bullet"
        case .killboard: "square.and.arrow.up"
        default: ""
        }
    }
    
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .auth: AuthView()
        case .characterInfo: CharacterInfoView()
        case .skills: SkillsRootView()
        case .killboard: KillboardView()
        default: EmptyView()
        }
    }
}
