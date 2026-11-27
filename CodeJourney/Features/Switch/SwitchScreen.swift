import SwiftUI

/// Switch careers: pick the job you do now, and see which tech roles are closest to it.
/// This is the list of starting jobs. Each one opens its own page.
struct SwitchScreen: View {
    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xl) {
                CJSectionHeader(eyebrow: "General patterns, not promises", title: "What do you do now?")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: CJSpace.m)], spacing: CJSpace.m) {
                    ForEach(content.switchJobs) { job in
                        NavigationLink {
                            SwitchJobScreen(job: job)
                        } label: {
                            VStack(alignment: .leading, spacing: CJSpace.s) {
                                Text(job.title)
                                    .font(CJFont.headline)
                                    .foregroundStyle(CJColor.ink)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                                Text("\(job.skills.count) head-start skills")
                                    .font(CJFont.caption)
                                    .foregroundStyle(CJColor.accent)
                            }
                            .padding(CJSpace.l)
                            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                                    .fill(CJColor.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle("Switch careers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One starting job: what it gives you, and the tech roles closest to it.
struct SwitchJobScreen: View {
    let job: SwitchJob

    @Environment(ContentStore.self) private var content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CJSpace.xxl) {
                VStack(alignment: .leading, spacing: CJSpace.s) {
                    Text(job.summary)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                }

                strengthsCard

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "\(bridges.count) roles", title: "Closest tech roles")
                    ForEach(bridges) { bridge in
                        bridgeCard(bridge)
                    }
                }

                VStack(alignment: .leading, spacing: CJSpace.m) {
                    CJSectionHeader(eyebrow: "Head start", title: "Skills this job helps with")
                    CJChipWrap(chips: job.skills.map { slug in
                        CJChip(title: content.skill(slug: slug)?.title ?? slug, tone: .accent)
                    })
                }
            }
            .padding(CJLayout.sideMargin)
        }
        .background(CJColor.canvas.ignoresSafeArea())
        .navigationTitle(job.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var strengthsCard: some View {
        VStack(alignment: .leading, spacing: CJSpace.m) {
            Text("STRENGTHS YOU CARRY OVER")
                .font(CJFont.caption)
                .tracking(1.0)
                .foregroundStyle(CJColor.inkSecondary)

            ForEach(job.strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: CJSpace.s) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(CJColor.success)
                    Text(strength)
                        .font(CJFont.body)
                        .foregroundStyle(CJColor.ink)
                }
            }
        }
        .padding(CJSpace.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CJRadius.card, style: .continuous)
                .fill(CJColor.surface)
        )
    }

    @ViewBuilder
    private func bridgeCard(_ bridge: Bridge) -> some View {
        if let role = content.role(slug: bridge.slug) {
            NavigationLink {
                RoleDetailScreen(role: role)
            } label: {
                VStack(alignment: .leading, spacing: CJSpace.m) {
                    HStack(alignment: .center, spacing: CJSpace.m) {
                        VStack(alignment: .leading, spacing: CJSpace.xxs) {
                            Text(bridge.title)
                                .font(CJFont.title)
                                .foregroundStyle(CJColor.ink)
                            Text("\(bridge.toLearn.count) skills still to learn")
                                .font(CJFont.callout)
                                .foregroundStyle(CJColor.inkSecondary)
                        }
                        Spacer(minLength: 0)
                        VStack(spacing: CJSpace.xxs) {
                            CJProgressRing(progress: bridge.share, size: 56, lineWidth: 6, tint: CJColor.success)
                            Text("of route")
                                .font(CJFont.caption)
                                .foregroundStyle(CJColor.inkSecondary)
                        }
                    }

                    Text("YOU LIKELY HAVE")
                        .font(CJFont.caption)
                        .tracking(1.0)
                        .foregroundStyle(CJColor.inkSecondary)
                    CJChipWrap(chips: bridge.have.map { slug in
                        CJChip(title: content.skill(slug: slug)?.title ?? slug, tone: .success)
                    })

                    if let startAt = bridge.startAt {
                        Text("Start at \(startAt)")
                            .font(CJFont.callout)
                            .foregroundStyle(CJColor.accent)
                    }
                }
                .padding(CJSpace.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CJRadius.sheet, style: .continuous)
                        .fill(CJColor.surface)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var bridges: [Bridge] {
        SwitchLogic.bridges(for: job, roles: content.roles)
    }
}

#Preview {
    NavigationStack {
        SwitchScreen()
    }
    .environment(ContentStore())
}
