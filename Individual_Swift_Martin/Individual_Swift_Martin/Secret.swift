//
//  Secret.swift
//  Individual_Swift_Martin
//
//  Created by Martin Todorov on 21/05/2023.
//

import Foundation

enum Secret {
    static let yourOpenAIAPIKey = ProcessInfo.processInfo.environment["OpenAI_API_KEY"] ?? ""
}
