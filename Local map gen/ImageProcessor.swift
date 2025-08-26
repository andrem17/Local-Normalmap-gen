import SwiftUI
import AppKit

// MARK: - Cores (laterais mais claras que o centro)
private let centerBG = Color(nsColor: .windowBackgroundColor)          // painel central (mais escuro)
private let sidebarBG = Color(nsColor: .controlBackgroundColor)        // sidebars (mais claras)
private let tileBG = Color(nsColor: .separatorColor).opacity(0.15)
private let dottedColor = Color.white.opacity(0.25)
private let headerFont = Font.headline.weight(.semibold)

