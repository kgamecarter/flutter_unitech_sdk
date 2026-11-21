package tw.kgame.app.plugin.unitech_sdk

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class ScannerBroadcastHandler(
    private val context: Context,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    private val receivers = mutableMapOf<Int, BroadcastReceiver>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val id = call.arguments as? Int ?: run {
            result.error("invalid_receiver", "Expected a scanner receiver ID.", null)
            return
        }
        when (call.method) {
            "startReceiver" -> start(id)
            "stopReceiver" -> stop(id)
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    @Suppress("DEPRECATION")
    private fun start(id: Int) {
        if (id in receivers) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action != SCAN_ACTION) return
                val extras = intent.extras
                val data = extras?.keySet()?.associateWith { key -> normalize(extras.get(key)) }
                    ?: emptyMap()
                channel.invokeMethod(
                    "receiveBroadcast",
                    mapOf("receiverId" to id, "name" to SCAN_ACTION, "data" to data),
                )
            }
        }
        val filter = IntentFilter(SCAN_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            context.registerReceiver(receiver, filter)
        }
        receivers[id] = receiver
    }

    private fun stop(id: Int) {
        val receiver = receivers[id] ?: return
        context.unregisterReceiver(receiver)
        receivers.remove(id)
    }

    fun close() {
        receivers.keys.toList().forEach(::stop)
    }

    private fun normalize(value: Any?): Any? = when (value) {
        null, is Boolean, is Int, is Long, is Float, is Double, is String,
        is Byte, is Short, is java.math.BigInteger, is ByteArray, is IntArray,
        is LongArray, is FloatArray, is DoubleArray -> value
        is List<*> -> value.map(::normalize)
        is Map<*, *> -> value.mapValues { (_, item) -> normalize(item) }
        else -> value.toString()
    }

    private companion object {
        const val SCAN_ACTION = "unitech.scanservice.data"
    }
}
