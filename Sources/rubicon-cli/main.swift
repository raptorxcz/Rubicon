import ArgumentParser

struct RubiconCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rubicon",
        abstract: "generate test doubles"
    )
}

RubiconCommand.main()
