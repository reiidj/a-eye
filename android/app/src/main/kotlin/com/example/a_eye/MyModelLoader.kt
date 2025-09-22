package com.example.a_eye

import android.content.Context
import org.pytorch.IValue
import org.pytorch.Module
import org.pytorch.Tensor
import java.io.File

class MyModelLoader(private val context: Context) {

    private val modelFileName = "16AEYEMODEL.ptl"
    lateinit var module: Module

    fun loadModel() {
        val file = File(context.filesDir, modelFileName)

        // Copy from assets if it doesn't exist
        if (!file.exists()) {
            context.assets.open(modelFileName).use { input ->
                file.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }

        // Load the PyTorch model
        module = Module.load(file.absolutePath)
    }

    // Returns a single float value, which is the model's direct output
    fun runInference(inputTensor: FloatArray, shape: LongArray): Float {
        val input = Tensor.fromBlob(inputTensor, shape)
        val output = module.forward(IValue.from(input)).toTensor()
        return output.dataAsFloatArray[0]
    }
}