package tw.kgame.app.plugin.unitech_sdk

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.unitech.api.clock.ClockCtrl;
import kotlin.concurrent.thread

/** UnitechSdkPlugin */
class UnitechSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "unitech_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setTimeMode" -> {
        var clock = ClockCtrl(context)
        thread (start = true) {
          clock.setTimeMode(call.arguments as Int)
          result.success(null)
        }
      }
      "setDateTime" -> {
        var clock = ClockCtrl(context)
        thread (start = true) {
          var args = call.arguments as ArrayList<String>
          clock.setManualDate(args[0])
          clock.setManualTime(args[1])
          result.success(null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
