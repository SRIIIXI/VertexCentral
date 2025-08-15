#include <stdlib.h>
#include <string.h>
#include "Model.h"

void copy_device_t(device_t *dest, const device_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(device_t));
}

void copy_asset_t(asset_t *dest, const asset_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(asset_t));
}

void copy_asset_to_sensor_mapping_t(asset_to_sensor_mapping_t *dest, const asset_to_sensor_mapping_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(asset_to_sensor_mapping_t));
}

void copy_device_hierarchy_t(device_hierarchy_t *dest, const device_hierarchy_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(device_hierarchy_t));
}

void copy_device_permission_t(device_permission_t *dest, const device_permission_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(device_permission_t));
}

void copy_device_attribute_t(device_attribute_t *dest, const device_attribute_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(device_attribute_t));
}

//-----

void copy_area_t(area_t *dest, const area_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(area_t));
}

void copy_zone_t(zone_t *dest, const zone_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(zone_t));
}

void copy_level_t(level_t *dest, const level_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(level_t));
}

void copy_site_t(site_t *dest, const site_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(site_t));
}

//-----

void copy_feature_t(feature_t *dest, const feature_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(feature_t));
}

void copy_application_t(application_t *dest, const application_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(application_t));
}

void copy_rule_t(rule_t *dest, const rule_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(rule_t));
}

//------

void copy_user_t(user_t *dest, const user_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(user_t));
}

void copy_enterprise_t(enterprise_t *dest, const enterprise_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(enterprise_t));
}

void copy_application_permission_t(application_permission_t *dest, const application_permission_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(application_permission_t));
}

void copy_role_t(role_t *dest, const role_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(role_t));
}

void copy_user_role_mapping_t(user_role_mapping_t *dest, const user_role_mapping_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(user_role_mapping_t));
}

void copy_login_session_t(login_session_t *dest, const login_session_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(login_session_t));
}

//-----

void copy_telemetry_data_t(telemetry_data_t *dest, const telemetry_data_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(telemetry_data_t));
}

void copy_alarm_t(alarm_t *dest, const alarm_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }

    memcpy(dest, src, sizeof(alarm_t));

    if (src->related_telemetry != NULL && src->related_telemetry_count > 0)
    {
        dest->related_telemetry = malloc(sizeof(telemetry_data_t) * src->related_telemetry_count);
        if (dest->related_telemetry != NULL)
        {
            for (unsigned int i = 0; i < src->related_telemetry_count; i++)
            {
                copy_telemetry_data_t(&dest->related_telemetry[i], &src->related_telemetry[i]);
            }
        }
    }
    else
    {
        dest->related_telemetry = NULL;
    }
}

void copy_notification_t(notification_t *dest, const notification_t *src)
{
    if (dest == NULL || src == NULL)
    {
        return;
    }
    memcpy(dest, src, sizeof(notification_t));
}
