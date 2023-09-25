import Foundation
import PackagePlugin

@main
struct RubiconPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        log("Directory: \(context.package.directory)", context: context)
//        let rubicon = try context.tool(named: "rubicon-cli")
//        log("TOOL: \(rubicon)", context: context)
//        log("pluginWorkDirectory: \(context.pluginWorkDirectory)", context: context)
//        log("package.directory: \(context.package.directory)", context: context)
        log("targets: \(context.package.targets.map(\.directory.string))", context: context)
//        log("arguments: \(arguments)", context: context)


//        let rubiconCli = URL(fileURLWithPath: rubicon.path.string)
//        log("rubiconCli: \(rubiconCli)", context: context)
//        let process = try Process.run(rubiconCli, arguments: arguments)
    }

    private func log(_ text: String, context: PackagePlugin.PluginContext) {
        let filePath = context.package.directory.appending(subpath: "log.txt").string
        let content = (try? String(contentsOfFile: filePath, encoding: .utf8)) ?? ""
        _ = try? (content + text + "\n").write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}
