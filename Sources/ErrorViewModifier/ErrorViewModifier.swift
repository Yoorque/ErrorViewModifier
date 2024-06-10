// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct ErrorDisplayModifier: ViewModifier {
	var text: String
	@Binding var showError: Bool
	var displayTimeout: Double
	var blurParent: Bool
	
	func body(content: Content) -> some View {
		let work = DispatchWorkItem {
			showError = false
		}
		ZStack(alignment: .top) {
			content
				.blur(radius: showError && blurParent ? 2 : 0)
				.disabled(showError && blurParent)
			if showError {
				Text(text)
					.font(.caption)
					.bold()
					.foregroundStyle(.red)
					.padding()
					.shadow(radius: 8, x: 2, y: 2)
					.padding(.top, 8)
					.transition(.move(edge: .top))
					.onTapGesture {
						hideError(work: work)
					}
					.task {
						DispatchQueue.main.asyncAfter(deadline: .now() + displayTimeout, execute: work)
					}
					.zIndex(1)
			}
		}
		.contentShape(Rectangle())
		.onTapGesture {
			hideError(work: work)
		}
		.animation(.easeInOut, value: showError)
	}
	
	private func hideError(work: DispatchWorkItem) {
		showError = false
		work.cancel()
	}
}

public extension View {
	func showError(_ text: String, show: Binding<Bool>, displayTimeout: Double = 3, blurParent: Bool = false) -> some View {
		self.modifier(ErrorDisplayModifier(text: text, showError: show, displayTimeout: displayTimeout, blurParent: blurParent))
	}
}
