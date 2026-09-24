//
//  RegisterView.swift
//  MedCare

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMatch: Bool { password == confirmPassword }

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6 &&
        passwordsMatch
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BotanicalBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 46))
                                .foregroundColor(Theme.leafGreen)
                            Text("Create Your Account")
                                .font(Theme.headingFont)
                            Text("Track your prescriptions and adherence, all in one place.")
                                .font(Theme.captionFont)
                                .secondaryTextStyle()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 14) {
                            TextField(loc.t("Email"), text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.sage, lineWidth: 1))

                            SecureField("Password (6+ characters)", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.sage, lineWidth: 1))

                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            confirmPassword.isEmpty || passwordsMatch ? Theme.sage : Theme.petalPink,
                                            lineWidth: 1
                                        )
                                )

                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("Passwords don't match.")
                                    .font(Theme.captionFont)
                                    .foregroundColor(Theme.petalPink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if let errorMessage = auth.errorMessage {
                            Text(errorMessage)
                                .font(Theme.captionFont)
                                .foregroundColor(Theme.petalPink)
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            Task {
                                await auth.signUp(email: email, password: password)
                                if auth.isAuthenticated { dismiss() }
                            }
                        } label: {
                            Group {
                                if auth.isProcessing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(loc.t("Create Account")).font(Theme.bodyFont.weight(.semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: Theme.minTapTarget)
                            .background(Theme.leafGreen)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .disabled(!isValid || auth.isProcessing)
                        .opacity(isValid ? 1 : 0.6)
                    }
                    .padding(.horizontal, 28)
                }
            }
            .navigationTitle(loc.t("Sign Up"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("Cancel")) {
                        auth.errorMessage = nil
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthController())
        .environmentObject(AccessibilitySettings())
        .environmentObject(LocalizationManager())
}
