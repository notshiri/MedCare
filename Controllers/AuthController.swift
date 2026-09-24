//
//  AuthController.swift
//  MedCare

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

@MainActor
final class AuthController: ObservableObject {

    @Published private(set) var userId: String?
    @Published private(set) var userEmail: String?
    @Published var errorMessage: String?
    @Published var isProcessing = false

    @Published var passwordResetMessage: String?

    var isAuthenticated: Bool { userId != nil }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.userId = user?.uid
                self?.userEmail = user?.email
            }
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    func resetPassword(email: String) async {
        errorMessage = nil
        passwordResetMessage = nil
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            passwordResetMessage = "If an account exists for that email, a reset link is on its way."
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
    }

    private func friendlyMessage(for error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .invalidEmail: return "That email address doesn't look right."
        case .emailAlreadyInUse: return "An account with that email already exists."
        case .weakPassword: return "Please choose a password with at least 6 characters."
        case .wrongPassword, .invalidCredential: return "Incorrect email or password."
        case .userNotFound: return "No account found with that email."
        case .networkError: return "Network error — please check your connection."
        default: return error.localizedDescription
        }
    }
}
