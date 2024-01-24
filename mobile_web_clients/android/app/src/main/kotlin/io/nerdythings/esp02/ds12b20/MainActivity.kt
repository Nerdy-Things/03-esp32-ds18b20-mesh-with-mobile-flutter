package io.nerdythings.esp02.ds18b20

import android.os.Bundle
import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // https://issuetracker.google.com/issues/247596083?pli=1
        val wm = getSystemService(Context.WIFI_SERVICE) as WifiManager
        val multicastLock = wm.createMulticastLock("nerdythings.esp02.ds18b20")
        multicastLock.acquire()
    }
}
