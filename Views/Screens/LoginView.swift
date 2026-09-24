//
//  LoginView.swift
//  MedCare

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var loc: LocalizationManager

    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegister = false
    @State private var isShowingForgotPassword = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.leafGreen)
                        Text("MedCare")
                            .font(Theme.titleFont)
                        Text("Sign in to your account")
                            .font(Theme.bodyFont)
                            .secondaryTextStyle()
                    }
                    .padding(.top, 40)

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

                        SecureField(loc.t("Password"), text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.sage, lineWidth: 1))
                    }

                    Button {
                        auth.errorMessage = nil
                        auth.passwordResetMessage = nil
                        isShowingForgotPassword = true
                    } label: {
                        Text(loc.t("Forgot Password?"))
                            .font(Theme.captionFont.weight(.semibold))
                            .foregroundColor(Theme.leafGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    if let errorMessage = auth.errorMessage {
                        Text(errorMessage)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.petalPink)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await auth.signIn(email: email, password: password) }
                    } label: {
                        Group {
                            if auth.isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Text(loc.t("Sign In")).font(Theme.bodyFont.weight(.semibold))
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

                    Button {
                        auth.errorMessage = nil
                        isShowingRegister = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(loc.t("Don't have an account?"))
                                .secondaryTextStyle()
                            Text(loc.t("Create one"))
                                .foregroundColor(Theme.leafGreen)
                                .fontWeight(.semibold)
                        }
                        .font(Theme.captionFont)
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .sheet(isPresented: $isShowingRegister) {
            RegisterView()
        }
        .sheet(isPresented: $isShowingForgotPassword) {
            ForgotPasswordView()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthController())
        .environmentObject(AccessibilitySettings())
        .environmentObject(LocalizationManager())
}
