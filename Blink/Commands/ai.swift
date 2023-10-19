import Foundation
import NonStdIO
import ArgumentParser
import AVFoundation

struct AI: NonStdIOCommand {
  static var configuration = CommandConfiguration(
    commandName: "AI",
    abstract: "AI 音频转文本，AI 功能",
    subcommands: [On.self, Off.self],
    defaultSubcommand: On.self
  )

  @OptionGroup var verboseOptions: VerboseOptions
  var io = NonStdIO.standart

  // 开始录制
  struct On: NonStdIOCommand {
    static var configuration = CommandConfiguration(
      abstract: "录制音频",
      discussion: "执行 AI 命令，开始录音转文本"
    )

    @OptionGroup var verboseOptions: VerboseOptions
    var io = NonStdIO.standart

    func run() throws {
      var sema: DispatchSemaphore? = nil

      printDebug("Checking authorization status")
      switch AVCaptureDevice.authorizationStatus(for: .audio) {
      case .notDetermined:
        printDebug("Status is not determined. Requesting access...")
        sema = .init(value: 1)
        var accessGranted = false
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
          accessGranted = granted
          sema?.signal()
        })
        sema?.wait()
        if accessGranted {
          printDebug("授予访问权限。")
          print("开始录音。。。")
        } else {
          printDebug("未授予访问权限.")
        }

      case .restricted:
        printDebug("访问受限")
        print("Warning: Please grant Audio access to Blink.app in Settings.app.")
      case .denied:
        printDebug("拒绝访问")
        print("Warning: Please grant Audio access to Blink.app in Settings.app")
      case .authorized:
        printDebug("状态被授权")
        print("开始畅所欲言吧。。。")
      @unknown default: break
      }

      let session = Unmanaged<MCPSession>.fromOpaque(thread_context).takeUnretainedValue()
      DispatchQueue.main.async {
        if let spcCtrl = session.device.view.window?.rootViewController as? SpaceController {
          AIManager.attach(spaceCtrl: spcCtrl)
        }
      }

    }
  }

  struct Off: NonStdIOCommand {
    static var configuration = CommandConfiguration(
      abstract: "结束录音"
    )

    @OptionGroup var verboseOptions: VerboseOptions
    var io = NonStdIO.standart

    func run() throws {
      print("下次见")
      DispatchQueue.main.async {
        AIManager.turnOff()
      }
    }
  }
}

@_cdecl("ai_main")
public func AI_main(argc: Int32, argv: Argv) -> Int32 {
  setvbuf(thread_stdin, nil, _IONBF, 0)
  setvbuf(thread_stdout, nil, _IONBF, 0)
  setvbuf(thread_stderr, nil, _IONBF, 0)

  let io = NonStdIO.standart
  io.out = OutputStream(file: thread_stdout)
  io.err = OutputStream(file: thread_stderr)

  return AI.main(Array(argv.args(count: argc)[1...]), io: io)
}
