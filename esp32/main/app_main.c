#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs_flash.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include <inttypes.h>
#include <string.h>
#include "config.h"
#include "nerdy_wifi.h"
#include "nerdy_udp_client.h"
#include "nerdy_udp_server.h"
#include "nerdy_udp_server_event.h"
#include "nerdy_mac_address.h"
#include "nerdy_temperature.h"

static const char *TAG = "MAIN";
static const char *UPDATE_MESSAGE = "update";

/**
 * Sends temperature sensor value to the network
*/
static void send_udp_temperature() 
{
    char *message;
    // Build a message 
    asprintf(&message, "{\"mac_address\": \"%s\" , \"temperature\": \"%f\"}\n", nerdy_get_mac_address(), nerdy_temperature_get());
    // Send message
    nerdy_udp_client_send_message(nerdy_wifi_ip_broadcast, UDP_PORT_CLIENT, message);
    // Release message from memory
    free(message);
    // Log to the console
    ESP_LOGI(TAG, "Message is sent to %s %d", nerdy_wifi_ip_broadcast, UDP_PORT_CLIENT);
}

/**
 * Receives messages from UDP server
*/
static void udp_server_event_handler(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data) 
{
    if (event_base != NERDY_UDP_SERVER_EVENT) return;
    if (event_id == NERDY_UDP_SERVER_EVENT_MESSAGE) {
        char *message = (char*)event_data;
        ESP_LOGI(TAG, "Received in main: %s", message);
        if (strncmp(message, UPDATE_MESSAGE, strlen(UPDATE_MESSAGE)) == 0) {
            send_udp_temperature();
        }
    }
}

/**
 * App entry point
*/
void app_main(void)
{
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }

    ESP_ERROR_CHECK(ret);

    // Connect ESP32 to a Wi-Fi network. 
    // Change Access Point Name and Password in the config. 
    // Read the README.md or nerdy_wifi/README.md for details!!!
    nerdy_wifi_connect();
    nerdy_temperature_init();
    nerdy_udp_server_start(UDP_PORT_SERVER);
    esp_event_handler_instance_t instance;
    ESP_ERROR_CHECK(
        esp_event_handler_instance_register(
            NERDY_UDP_SERVER_EVENT, 
            NERDY_UDP_SERVER_EVENT_MESSAGE, 
            &udp_server_event_handler,
            NULL, 
            &instance
        )
    );
}