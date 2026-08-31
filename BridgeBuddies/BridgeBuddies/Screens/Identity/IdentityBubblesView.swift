import SwiftUI

/// Identity Bubbles — the user picks the tags that describe them.
///
/// One ordered `tags` array plus a `selected` set is the whole model: both
/// fields are filtered views of the same list, so a tag keeps its place in the
/// pool when it comes back and the two fields can never disagree.
///
/// The move between fields is the screen. Each pill carries a
/// `matchedGeometryEffect` keyed on its text, so the pill physically travels
/// from the pool to the selected field while both fields reflow underneath it;
/// the animation is state-driven (`.animation(_:value: selected)`) so a fast
/// run of taps absorbs into one continuous motion instead of queueing.
struct IdentityBubblesView: View {
    @State private var tags: [String] = [
        "Introvert",
        "Need recharge time after socializing",
        "Prefer planned meetups",
        "Appreciate patience",
        "Here to connect at my own pace",
        "Good listener",
        "Extroverted",
        "Okay talking about personal things",
        "Prefer small groups",
        "Up for spontaneous plans",
        "New to campus",
        "Still figuring things out"
    ]
    @State private var selected: Set<String> = [
        "Introvert",
        "Need recharge time after socializing",
        "Prefer planned meetups",
        "Appreciate patience",
        "Here to connect at my own pace",
        "Good listener"
    ]
    @State private var draft = ""
    @State private var tab: AppTab = .home

    @Namespace private var bubbles
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let headerHeight: CGFloat = 152

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: Spacing.section) {
                        field(tags.filter { selected.contains($0) })

                        RuledLabel(
                            text: "Tap to select",
                            tint: .textPrimary,
                            ruleTint: .textPrimary.opacity(0.35)
                        )

                        field(tags.filter { !selected.contains($0) })
                    }
                    .padding(.horizontal, Spacing.screenH)
                    // Clears the search pill overlapping the header's bottom edge.
                    .padding(.top, 44)
                    .padding(.bottom, Spacing.tabBarClearance)
                    .animation(reflow, value: selected)
                }
            }

            SearchActionBar(
                text: $draft,
                placeholder: "Add your own",
                trailingIcon: "plus",
                onTrailingTap: commitDraft
            )
            .padding(.horizontal, Spacing.screenH)
            .offset(y: headerHeight - 26)
            .onSubmit(commitDraft)

            VStack {
                Spacer()
                BottomTabBar(selected: $tab)
            }
        }
    }

    // MARK: - Pieces

    private var header: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi Zainab!")
                        .font(.displaySM)
                        .foregroundColor(.textPrimary)
                    Text("Your next connection is waiting.")
                        .font(.bodyMD)
                        .foregroundColor(.textSecondary)
                }
                Spacer(minLength: Spacing.stack)
                DualOrbAvatar(size: 56)
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.top, 60)
        }
        .frame(height: headerHeight, alignment: .top)
    }

    private func field(_ items: [String]) -> some View {
        FlowLayout {
            ForEach(items, id: \.self, content: bubble)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func bubble(_ tag: String) -> some View {
        let pill = BubbleTag(text: tag, isSelected: selected.contains(tag)) {
            toggle(tag)
        }

        if reduceMotion {
            // No travel under Reduce Motion — the pill cross-fades in place.
            pill.transition(.opacity)
        } else {
            pill.matchedGeometryEffect(id: tag, in: bubbles)
        }
    }

    // MARK: - Behaviour

    private var reflow: Animation {
        reduceMotion
            ? .easeOut(duration: 0.2)
            : .spring(response: 0.38, dampingFraction: 1.0)
    }

    private func toggle(_ tag: String) {
        if selected.contains(tag) {
            selected.remove(tag)
        } else {
            selected.insert(tag)
        }
    }

    private func commitDraft() {
        let tag = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        if !tags.contains(tag) { tags.append(tag) }
        selected.insert(tag)
        draft = ""
    }
}

#Preview {
    IdentityBubblesView()
}
