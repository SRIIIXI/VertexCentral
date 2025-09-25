-- ============================================================================
-- TRIGGERS.SQL
-- ============================================================================
-- Attaches AFTER INSERT and AFTER UPDATE triggers for all tables
-- to invoke the generic OnInsert() and OnUpdate() functions.
-- Notifications are always sent to the common channel 'table_events'.
-- ============================================================================

-- Helper: drop existing triggers to avoid duplicate definitions
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE trigger_name LIKE 'trg\_%\_notify'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I', r.trigger_name, r.event_object_table);
    END LOOP;
END;
$$;

-- ============================================================================
-- Enterprises
-- ============================================================================
CREATE TRIGGER trg_enterprises_insert_notify
AFTER INSERT ON "Enterprises"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_enterprises_update_notify
AFTER UPDATE ON "Enterprises"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Countries
-- ============================================================================
CREATE TRIGGER trg_countries_insert_notify
AFTER INSERT ON "Countries"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_countries_update_notify
AFTER UPDATE ON "Countries"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Users
-- ============================================================================
CREATE TRIGGER trg_users_insert_notify
AFTER INSERT ON "Users"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_users_update_notify
AFTER UPDATE ON "Users"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- BoundsArea
-- ============================================================================
CREATE TRIGGER trg_boundsarea_insert_notify
AFTER INSERT ON "BoundsArea"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_boundsarea_update_notify
AFTER UPDATE ON "BoundsArea"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Sites
-- ============================================================================
CREATE TRIGGER trg_sites_insert_notify
AFTER INSERT ON "Sites"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_sites_update_notify
AFTER UPDATE ON "Sites"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Levels
-- ============================================================================
CREATE TRIGGER trg_levels_insert_notify
AFTER INSERT ON "Levels"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_levels_update_notify
AFTER UPDATE ON "Levels"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Zones
-- ============================================================================
CREATE TRIGGER trg_zones_insert_notify
AFTER INSERT ON "Zones"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_zones_update_notify
AFTER UPDATE ON "Zones"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Devices
-- ============================================================================
CREATE TRIGGER trg_devices_insert_notify
AFTER INSERT ON "Devices"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_devices_update_notify
AFTER UPDATE ON "Devices"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Assets
-- ============================================================================
CREATE TRIGGER trg_assets_insert_notify
AFTER INSERT ON "Assets"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_assets_update_notify
AFTER UPDATE ON "Assets"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- AssetDeviceMappings
-- ============================================================================
CREATE TRIGGER trg_assetdevicemappings_insert_notify
AFTER INSERT ON "AssetDeviceMappings"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_assetdevicemappings_update_notify
AFTER UPDATE ON "AssetDeviceMappings"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- DeviceHierarchies
-- ============================================================================
CREATE TRIGGER trg_devicehierarchies_insert_notify
AFTER INSERT ON "DeviceHierarchies"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_devicehierarchies_update_notify
AFTER UPDATE ON "DeviceHierarchies"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- DeviceAttributes
-- ============================================================================
CREATE TRIGGER trg_deviceattributes_insert_notify
AFTER INSERT ON "DeviceAttributes"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_deviceattributes_update_notify
AFTER UPDATE ON "DeviceAttributes"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Applications
-- ============================================================================
CREATE TRIGGER trg_applications_insert_notify
AFTER INSERT ON "Applications"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_applications_update_notify
AFTER UPDATE ON "Applications"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Features
-- ============================================================================
CREATE TRIGGER trg_features_insert_notify
AFTER INSERT ON "Features"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_features_update_notify
AFTER UPDATE ON "Features"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Rules
-- ============================================================================
CREATE TRIGGER trg_rules_insert_notify
AFTER INSERT ON "Rules"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_rules_update_notify
AFTER UPDATE ON "Rules"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Actions
-- ============================================================================
CREATE TRIGGER trg_actions_insert_notify
AFTER INSERT ON "Actions"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_actions_update_notify
AFTER UPDATE ON "Actions"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- RolePermissions
-- ============================================================================
CREATE TRIGGER trg_rolepermissions_insert_notify
AFTER INSERT ON "RolePermissions"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_rolepermissions_update_notify
AFTER UPDATE ON "RolePermissions"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- UserRoleMappings
-- ============================================================================
CREATE TRIGGER trg_userrolemappings_insert_notify
AFTER INSERT ON "UserRoleMappings"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_userrolemappings_update_notify
AFTER UPDATE ON "UserRoleMappings"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- SessionLogs
-- ============================================================================
CREATE TRIGGER trg_sessionlogs_insert_notify
AFTER INSERT ON "SessionLogs"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_sessionlogs_update_notify
AFTER UPDATE ON "SessionLogs"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Alarms
-- ============================================================================
CREATE TRIGGER trg_alarms_insert_notify
AFTER INSERT ON "Alarms"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_alarms_update_notify
AFTER UPDATE ON "Alarms"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- AlarmTelemetryRelations
-- ============================================================================
CREATE TRIGGER trg_alarmtelemetryrelations_insert_notify
AFTER INSERT ON "AlarmTelemetryRelations"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_alarmtelemetryrelations_update_notify
AFTER UPDATE ON "AlarmTelemetryRelations"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- Notifications
-- ============================================================================
CREATE TRIGGER trg_notifications_insert_notify
AFTER INSERT ON "Notifications"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_notifications_update_notify
AFTER UPDATE ON "Notifications"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- TelemetryControl
-- ============================================================================
CREATE TRIGGER trg_telemetrycontrol_insert_notify
AFTER INSERT ON "TelemetryControl"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_telemetrycontrol_update_notify
AFTER UPDATE ON "TelemetryControl"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- FirmwareControl
-- ============================================================================
CREATE TRIGGER trg_firmwarecontrol_insert_notify
AFTER INSERT ON "FirmwareControl"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_firmwarecontrol_update_notify
AFTER UPDATE ON "FirmwareControl"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- FirmwareDeployments
-- ============================================================================
CREATE TRIGGER trg_firmwaredeployments_insert_notify
AFTER INSERT ON "FirmwareDeployments"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_firmwaredeployments_update_notify
AFTER UPDATE ON "FirmwareDeployments"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();

-- ============================================================================
-- FirmwareCompatibility
-- ============================================================================
CREATE TRIGGER trg_firmwarecompatibility_insert_notify
AFTER INSERT ON "FirmwareCompatibility"
FOR EACH ROW EXECUTE FUNCTION OnInsert();

CREATE TRIGGER trg_firmwarecompatibility_update_notify
AFTER UPDATE ON "FirmwareCompatibility"
FOR EACH ROW EXECUTE FUNCTION OnUpdate();
