package com.scichart.accessebility

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.scichart.charting.visuals.SciChartSurface

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setUpSciChartLicense()
        setContentView(R.layout.activity_main)
        setSupportActionBar(findViewById(R.id.toolbar))
    }

    private fun setUpSciChartLicense() {
        try {
            SciChartSurface.setRuntimeLicenseKey("")
        } catch (e: Exception) {
            Log.e("SciChart", "Error when setting the license", e)
        }
    }
}