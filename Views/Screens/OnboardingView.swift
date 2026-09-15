//
//  OnboardingView.swift
//  MedCare


import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "pills.fill",
            title: "Log Your Prescriptions",
            message: "Add each medicine once — dosage, instructions, and color tag — and MedCare keeps track from there."
        ),
        OnboardingPage(
            symbol: "bell.badge.fill",
            title: "Never Miss a Dose",
            message: "Set custom daily reminder times and get gently nudged with push notifications when it's time to take your medicine."
        ),
        OnboardingPage(
            symbol: "chart.bar.fill",
            title: "See Your Health Grade",
            message: "Every dose you mark Taken or Missed feeds a real-time A–F grade, so you always know how you're doing."
        )
    ]

    var body: some View {
        ZStack {
            BotanicalBackgroundView()
            VStack {
                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Button {
                    if pageIndex < pages.count - 1 {
                        withAnimation { pageIndex += 1 }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(pageIndex < pages.count - 1 ? "Next" : "Get Started")
                        .font(Theme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.leafGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

                if pageIndex < pages.count - 1 {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .font(Theme.captionFont)
                    .secondaryTextStyle()
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

private struct OnboardingPage {
    let symbol: String
    let title: String
    let message: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: 64))
                .foregroundColor(Theme.leafGreen)
            Text(page.title)
                .font(Theme.titleFont)
                .multilineTextAlignment(.center)
            Text(page.message)
                .font(Theme.bodyFont)
                .secondaryTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AccessibilitySettings())
}
