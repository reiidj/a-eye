package com.example.a_eye

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var modelLoader: MyModelLoader

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        modelLoader = MyModelLoader(this)
        modelLoader.loadModel() // Load the model once on app start

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.a_eye/pytorch")
            .setMethodCallHandler { call, result ->
                if (call.method == "runInference") {
                    val input = call.argument<List<Double>>("input")!!.map { it.toFloat() }.toFloatArray()
                    val shape = call.argument<List<Int>>("shape")!!.map { it.toLong() }.toLongArray()
                    // Run inference and get the single float output
                    val output = modelLoader.runInference(input, shape)
                    // Send that single result back to Flutter
                    result.success(output)
                } else {
                    result.notImplemented()
                }
            }
    }
}