//
//  ForgotPasswordView.swift
//  MedCare

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var auth: AuthController
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BotanicalBackgroundView()
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 46))
                            .foregroundColor(Theme.leafGreen)
                        Text("Reset Your Password")
                            .font(Theme.headingFont)
                        Text("Enter your account email and we'll send you a link to reset your password.")
                            .font(Theme.captionFont)
                            .secondaryTextStyle()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    TextField(loc.t("Email"), text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.sage, lineWidth: 1))

                    if let message = auth.passwordResetMessage {
                        Text(message)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.leafGreen)
                            .multilineTextAlignment(.center)
                    }
                    if let errorMessage = auth.errorMessage {
                        Text(errorMessage)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.petalPink)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await auth.resetPassword(email: email) }
                    } label: {
                        Group {
                            if auth.isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Text("Send Reset Link").font(Theme.bodyFont.weight(.semibold))
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

                    Spacer()
                }
                .padding(.horizontal, 28)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("Cancel")) {
                        auth.errorMessage = nil
                        auth.passwordResetMessage = nil
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthController())
        .environmentObject(AccessibilitySettings())
        .environmentObject(LocalizationManager())
}
