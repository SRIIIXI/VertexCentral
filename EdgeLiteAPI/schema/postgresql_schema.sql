-- IoT Data Model - PostgreSQL Schema Creation Script
-- Generated from C header file model definitions

-- Create database (run this separately if needed)
-- CREATE DATABASE iot_platform;
-- \c iot_platform;

-- Enable PostGIS extension for geographic data (if needed)
-- CREATE EXTENSION IF NOT EXISTS postgis;

-- Create custom data types for enums
CREATE TYPE site_type_enum AS ENUM ('I', 'O'); -- Indoor, Outdoor
CREATE TYPE alarm_type_enum AS ENUM ('C', 'W', 'I'); -- Critical, Warning, Info
CREATE TYPE notification_type_enum AS ENUM ('A', 'T', 'E'); -- Alarm, Telemetry, Event
CREATE TYPE telemetry_data_type_enum AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE permission_type_enum AS ENUM ('READ', 'WRITE', 'EXECUTE', 'DELETE', 'ADMIN', 'CUSTOM');
CREATE TYPE device_type_enum AS ENUM ('SENSOR', 'ACTUATOR', 'CONTROLLER', 'GATEWAY', 'VIRTUAL', 'OTHER');
CREATE TYPE device_sub_type_enum AS ENUM ('TEMPERATURE_SENSOR', 'HUMIDITY_SENSOR', 'PRESSURE_SENSOR', 'LIGHT_SENSOR', 'MOTION_SENSOR', 'OTHER');
CREATE TYPE device_life_cycle_enum AS ENUM ('NEW', 'IN_USE', 'DECOMMISSIONED', 'RETIRED', 'OTHER');
CREATE TYPE device_attribute_type_enum AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE rule_type_enum AS ENUM ('A', 'C', 'E'); -- Automation, Condition, Event

-- Create composite type for coordinates
CREATE TYPE coordinate_type AS (
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    altitude DOUBLE PRECISION
);

-- ============================================================================
-- ENTERPRISES TABLE
-- ============================================================================
CREATE TABLE enterprises (
    enterprise_id VARCHAR(64) PRIMARY KEY,
    enterprise_name VARCHAR(64) NOT NULL,
    description VARCHAR(255),
    contact_mo VARCHAR(31),
    contact_email VARCHAR(256),
    contact_first_name VARCHAR(64),
    contact_last_name VARCHAR(64),
    unix_timestamp_created BIGINT,
    whitelabel_text VARCHAR(1024),
    address_line1 VARCHAR(256),
    address_line2 VARCHAR(256),
    address_city VARCHAR(32),
    address_state VARCHAR(32),
    address_country VARCHAR(32),
    address_pin_code VARCHAR(16),
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE users (
    user_id VARCHAR(64) PRIMARY KEY,
    enterprise_id VARCHAR(64) NOT NULL,
    user_name VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    contact_mo VARCHAR(31),
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    password_hash VARCHAR(256),
    password_salt VARCHAR(256),
    unix_timestamp_last_login BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(enterprise_id) ON DELETE CASCADE
);

-- ============================================================================
-- CLUSTERS TABLE
-- ============================================================================
CREATE TABLE clusters (
    cluster_id VARCHAR(64) PRIMARY KEY,
    cluster_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    enterprise_id VARCHAR(64) NOT NULL,
    cluster_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(enterprise_id) ON DELETE CASCADE
);

-- ============================================================================
-- SITES TABLE
-- ============================================================================
CREATE TABLE sites (
    site_id VARCHAR(64) PRIMARY KEY,
    cluster_id VARCHAR(64) NOT NULL,
    site_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    site_type site_type_enum NOT NULL,
    site_level_count INTEGER DEFAULT 0,
    is_master_site BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id) ON DELETE CASCADE
);

-- ============================================================================
-- AREAS TABLE
-- ============================================================================
CREATE TABLE areas (
    area_id VARCHAR(64) PRIMARY KEY,
    area_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    area_points coordinate_type[],
    area_points_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT max_area_points CHECK (area_points_count <= 4096)
);

-- ============================================================================
-- LEVELS TABLE
-- ============================================================================
CREATE TABLE levels (
    level_id VARCHAR(64) PRIMARY KEY,
    site_id VARCHAR(64) NOT NULL,
    level_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    level_number INTEGER NOT NULL,
    bounds_area_id VARCHAR(64),
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES sites(site_id) ON DELETE CASCADE,
    FOREIGN KEY (bounds_area_id) REFERENCES areas(area_id) ON DELETE SET NULL
);

-- ============================================================================
-- ZONES TABLE
-- ============================================================================
CREATE TABLE zones (
    zone_id VARCHAR(64) PRIMARY KEY,
    level_id VARCHAR(64) NOT NULL,
    zone_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    zone_points coordinate_type[],
    zone_points_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (level_id) REFERENCES levels(level_id) ON DELETE CASCADE,
    CONSTRAINT max_zone_points CHECK (zone_points_count <= 4096)
);

-- ============================================================================
-- DEVICES TABLE
-- ============================================================================
CREATE TABLE devices (
    device_id VARCHAR(64) PRIMARY KEY,
    device_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    serial_no VARCHAR(64),
    hardware_id VARCHAR(64),
    firmware_version VARCHAR(64),
    model VARCHAR(64),
    manufacturer VARCHAR(64),
    device_type device_type_enum NOT NULL,
    device_sub_type device_sub_type_enum NOT NULL,
    device_inventory_life_cycle device_life_cycle_enum NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_connected BOOLEAN DEFAULT FALSE,
    is_configured BOOLEAN DEFAULT FALSE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ASSETS TABLE
-- ============================================================================
CREATE TABLE assets (
    asset_id VARCHAR(64) PRIMARY KEY,
    asset_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    serial_no VARCHAR(64),
    hardware_id VARCHAR(64),
    firmware_version VARCHAR(64),
    model VARCHAR(64),
    manufacturer VARCHAR(64),
    category_id VARCHAR(64),
    subcategory_id VARCHAR(64),
    site_id VARCHAR(64),
    level_id VARCHAR(64),
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES sites(site_id) ON DELETE SET NULL,
    FOREIGN KEY (level_id) REFERENCES levels(level_id) ON DELETE SET NULL
);

-- ============================================================================
-- ASSET_SENSOR_MAPPINGS TABLE
-- ============================================================================
CREATE TABLE asset_sensor_mappings (
    asset_sensor_mapping_id VARCHAR(64) PRIMARY KEY,
    asset_id VARCHAR(64) NOT NULL,
    sensor_count INTEGER DEFAULT 0,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE,
    CONSTRAINT max_sensors_per_asset CHECK (sensor_count <= 32)
);

-- ============================================================================
-- ASSET_SENSORS TABLE (Junction table for asset-sensor many-to-many relationship)
-- ============================================================================
CREATE TABLE asset_sensors (
    id SERIAL PRIMARY KEY,
    asset_sensor_mapping_id VARCHAR(64) NOT NULL,
    device_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_sensor_mapping_id) REFERENCES asset_sensor_mappings(asset_sensor_mapping_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    UNIQUE(asset_sensor_mapping_id, device_id)
);

-- ============================================================================
-- DEVICE_HIERARCHIES TABLE
-- ============================================================================
CREATE TABLE device_hierarchies (
    device_hierarchy_id VARCHAR(64) PRIMARY KEY,
    device_hierarchy_name VARCHAR(64),
    description VARCHAR(256),
    parent_device_id VARCHAR(64) NOT NULL,
    child_device_id VARCHAR(64) NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (child_device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    CONSTRAINT no_self_reference CHECK (parent_device_id != child_device_id)
);

-- ============================================================================
-- DEVICE_PERMISSIONS TABLE
-- ============================================================================
CREATE TABLE device_permissions (
    device_permission_id VARCHAR(64) PRIMARY KEY,
    device_permission_name VARCHAR(64),
    description VARCHAR(256),
    device_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    permission_type permission_type_enum NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================================
-- DEVICE_ATTRIBUTES TABLE
-- ============================================================================
CREATE TABLE device_attributes (
    device_attribute_id VARCHAR(64) PRIMARY KEY,
    device_attribute_name VARCHAR(64),
    description VARCHAR(256),
    device_id VARCHAR(64) NOT NULL,
    attribute_type device_attribute_type_enum NOT NULL,
    value_string VARCHAR(256),
    value_number DOUBLE PRECISION,
    value_boolean BOOLEAN,
    value_location coordinate_type,
    unit VARCHAR(32),
    accuracy DOUBLE PRECISION,
    precision_val DOUBLE PRECISION, -- 'precision' is reserved keyword
    range_min DOUBLE PRECISION,
    range_max DOUBLE PRECISION,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

-- ============================================================================
-- APPLICATIONS TABLE
-- ============================================================================
CREATE TABLE applications (
    application_id VARCHAR(64) PRIMARY KEY,
    application_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    version VARCHAR(64),
    vendor VARCHAR(64),
    category_id VARCHAR(64),
    subcategory_id VARCHAR(64),
    features_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT max_features_per_app CHECK (features_count <= 1024)
);

-- ============================================================================
-- FEATURES TABLE
-- ============================================================================
CREATE TABLE features (
    feature_id VARCHAR(64) PRIMARY KEY,
    feature_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    application_id VARCHAR(64) NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE
);

-- ============================================================================
-- RULES TABLE
-- ============================================================================
CREATE TABLE rules (
    rule_id VARCHAR(64) PRIMARY KEY,
    rule_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    rule_type rule_type_enum NOT NULL,
    rule_expression VARCHAR(1024),
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- APPLICATION_PERMISSIONS TABLE
-- ============================================================================
CREATE TABLE application_permissions (
    application_permission_id VARCHAR(64) PRIMARY KEY,
    application_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    permission_type permission_type_enum NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================================
-- ROLES TABLE
-- ============================================================================
CREATE TABLE roles (
    role_id VARCHAR(64) PRIMARY KEY,
    role_name VARCHAR(64) NOT NULL,
    description VARCHAR(256),
    permissions_count INTEGER DEFAULT 0,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT max_permissions_per_role CHECK (permissions_count <= 1024)
);

-- ============================================================================
-- ROLE_PERMISSIONS TABLE (Junction table for role-permission many-to-many relationship)
-- ============================================================================
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id VARCHAR(64) NOT NULL,
    application_permission_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (application_permission_id) REFERENCES application_permissions(application_permission_id) ON DELETE CASCADE,
    UNIQUE(role_id, application_permission_id)
);

-- ============================================================================
-- USER_ROLE_MAPPINGS TABLE
-- ============================================================================
CREATE TABLE user_role_mappings (
    user_role_mapping_id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    role_id VARCHAR(64) NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_updated BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- ============================================================================
-- LOGIN_SESSIONS TABLE
-- ============================================================================
CREATE TABLE login_sessions (
    session_id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    unix_timestamp_created BIGINT,
    unix_timestamp_expires BIGINT,
    location coordinate_type,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================================
-- TELEMETRY_DATA TABLE (Partitioned by time for better performance)
-- ============================================================================
CREATE TABLE telemetry_data (
    telemetry_data_id VARCHAR(64) NOT NULL,
    device_id VARCHAR(64) NOT NULL,
    unix_timestamp BIGINT NOT NULL,
    data_type telemetry_data_type_enum NOT NULL,
    value_string VARCHAR(256),
    value_number DOUBLE PRECISION,
    value_boolean BOOLEAN,
    value_location coordinate_type,
    unit VARCHAR(32),
    accuracy DOUBLE PRECISION,
    precision_val DOUBLE PRECISION,
    range_min DOUBLE PRECISION,
    range_max DOUBLE PRECISION,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (telemetry_data_id, unix_timestamp),
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
) PARTITION BY RANGE (unix_timestamp);

-- Create monthly partitions for telemetry data (example for 2024-2025)
-- You can create more partitions as needed
CREATE TABLE telemetry_data_2024_01 PARTITION OF telemetry_data
    FOR VALUES FROM (1704067200) TO (1706745599); -- Jan 2024

CREATE TABLE telemetry_data_2024_02 PARTITION OF telemetry_data
    FOR VALUES FROM (1706745600) TO (1709251199); -- Feb 2024

-- Add more partition tables as needed...

-- ============================================================================
-- ALARMS TABLE
-- ============================================================================
CREATE TABLE alarms (
    alarm_id VARCHAR(64) PRIMARY KEY,
    device_id VARCHAR(64) NOT NULL,
    unix_timestamp BIGINT NOT NULL,
    alarm_type alarm_type_enum NOT NULL,
    description VARCHAR(256),
    related_telemetry_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

-- ============================================================================
-- ALARM_TELEMETRY_RELATIONS TABLE (Junction table for alarm-telemetry relationship)
-- ============================================================================
CREATE TABLE alarm_telemetry_relations (
    id SERIAL PRIMARY KEY,
    alarm_id VARCHAR(64) NOT NULL,
    telemetry_data_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alarm_id) REFERENCES alarms(alarm_id) ON DELETE CASCADE
    -- Note: FK to telemetry_data is complex due to partitioning
);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================
CREATE TABLE notifications (
    notification_id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    unix_timestamp BIGINT NOT NULL,
    notification_type notification_type_enum NOT NULL,
    description VARCHAR(256),
    is_read BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================================
-- CREATE INDEXES FOR OPTIMAL PERFORMANCE
-- ============================================================================

-- Enterprise indexes
CREATE INDEX idx_enterprises_is_active ON enterprises(is_active);
CREATE INDEX idx_enterprises_created_at ON enterprises(created_at);

-- User indexes
CREATE INDEX idx_users_enterprise_id ON users(enterprise_id);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Cluster indexes
CREATE INDEX idx_clusters_enterprise_id ON clusters(enterprise_id);
CREATE INDEX idx_clusters_is_active ON clusters(is_active);

-- Site indexes
CREATE INDEX idx_sites_cluster_id ON sites(cluster_id);
CREATE INDEX idx_sites_site_type ON sites(site_type);
CREATE INDEX idx_sites_is_active ON sites(is_active);

-- Level indexes
CREATE INDEX idx_levels_site_id ON levels(site_id);
CREATE INDEX idx_levels_level_number ON levels(level_number);
CREATE INDEX idx_levels_is_active ON levels(is_active);

-- Zone indexes
CREATE INDEX idx_zones_level_id ON zones(level_id);
CREATE INDEX idx_zones_is_active ON zones(is_active);

-- Device indexes
CREATE INDEX idx_devices_device_type ON devices(device_type);
CREATE INDEX idx_devices_device_sub_type ON devices(device_sub_type);
CREATE INDEX idx_devices_manufacturer ON devices(manufacturer);
CREATE INDEX idx_devices_is_active_connected ON devices(is_active, is_connected);
CREATE INDEX idx_devices_serial_no ON devices(serial_no);
CREATE INDEX idx_devices_created_at ON devices(created_at);

-- Asset indexes
CREATE INDEX idx_assets_site_id ON assets(site_id);
CREATE INDEX idx_assets_level_id ON assets(level_id);
CREATE INDEX idx_assets_category ON assets(category_id, subcategory_id);
CREATE INDEX idx_assets_is_active ON assets(is_active);

-- Asset sensor mapping indexes
CREATE INDEX idx_asset_sensor_mappings_asset_id ON asset_sensor_mappings(asset_id);
CREATE INDEX idx_asset_sensor_mappings_is_active ON asset_sensor_mappings(is_active);
CREATE INDEX idx_asset_sensors_device_id ON asset_sensors(device_id);

-- Device hierarchy indexes
CREATE INDEX idx_device_hierarchies_parent_id ON device_hierarchies(parent_device_id);
CREATE INDEX idx_device_hierarchies_child_id ON device_hierarchies(child_device_id);
CREATE INDEX idx_device_hierarchies_is_active ON device_hierarchies(is_active);

-- Device permission indexes
CREATE INDEX idx_device_permissions_device_user ON device_permissions(device_id, user_id);
CREATE INDEX idx_device_permissions_user_id ON device_permissions(user_id);
CREATE INDEX idx_device_permissions_is_active ON device_permissions(is_active);

-- Device attribute indexes
CREATE INDEX idx_device_attributes_device_id ON device_attributes(device_id);
CREATE INDEX idx_device_attributes_attribute_type ON device_attributes(attribute_type);
CREATE INDEX idx_device_attributes_is_active ON device_attributes(is_active);

-- Application indexes
CREATE INDEX idx_applications_category ON applications(category_id, subcategory_id);
CREATE INDEX idx_applications_vendor ON applications(vendor);
CREATE INDEX idx_applications_is_active ON applications(is_active);

-- Feature indexes
CREATE INDEX idx_features_application_id ON features(application_id);
CREATE INDEX idx_features_is_active ON features(is_active);

-- Rule indexes
CREATE INDEX idx_rules_rule_type ON rules(rule_type);
CREATE INDEX idx_rules_priority ON rules(priority);
CREATE INDEX idx_rules_is_active ON rules(is_active);

-- Application permission indexes
CREATE INDEX idx_app_permissions_app_user ON application_permissions(application_id, user_id);
CREATE INDEX idx_app_permissions_user_id ON application_permissions(user_id);
CREATE INDEX idx_app_permissions_is_active ON application_permissions(is_active);

-- Role indexes
CREATE INDEX idx_roles_is_active ON roles(is_active);

-- User role mapping indexes
CREATE INDEX idx_user_role_mappings_user_id ON user_role_mappings(user_id);
CREATE INDEX idx_user_role_mappings_role_id ON user_role_mappings(role_id);
CREATE INDEX idx_user_role_mappings_is_active ON user_role_mappings(is_active);

-- Login session indexes
CREATE INDEX idx_login_sessions_user_id ON login_sessions(user_id);
CREATE INDEX idx_login_sessions_expires ON login_sessions(unix_timestamp_expires);
CREATE INDEX idx_login_sessions_is_active ON login_sessions(is_active);

-- Telemetry data indexes (Critical for IoT performance)
CREATE INDEX idx_telemetry_device_timestamp ON telemetry_data(device_id, unix_timestamp DESC);
CREATE INDEX idx_telemetry_timestamp ON telemetry_data(unix_timestamp DESC);
CREATE INDEX idx_telemetry_data_type ON telemetry_data(data_type);
CREATE INDEX idx_telemetry_is_active ON telemetry_data(is_active);
CREATE INDEX idx_telemetry_device_type_timestamp ON telemetry_data(device_id, data_type, unix_timestamp DESC);

-- Alarm indexes
CREATE INDEX idx_alarms_device_timestamp ON alarms(device_id, unix_timestamp DESC);
CREATE INDEX idx_alarms_alarm_type_timestamp ON alarms(alarm_type, unix_timestamp DESC);
CREATE INDEX idx_alarms_timestamp ON alarms(unix_timestamp DESC);
CREATE INDEX idx_alarms_is_active ON alarms(is_active);

-- Notification indexes
CREATE INDEX idx_notifications_user_timestamp ON notifications(user_id, unix_timestamp DESC);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_type_timestamp ON notifications(notification_type, unix_timestamp DESC);
CREATE INDEX idx_notifications_is_active ON notifications(is_active);

-- ============================================================================
-- CREATE FUNCTIONS AND TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for all tables with updated_at columns
CREATE TRIGGER update_enterprises_updated_at BEFORE UPDATE ON enterprises FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clusters_updated_at BEFORE UPDATE ON clusters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sites_updated_at BEFORE UPDATE ON sites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_areas_updated_at BEFORE UPDATE ON areas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_levels_updated_at BEFORE UPDATE ON levels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_zones_updated_at BEFORE UPDATE ON zones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON devices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON assets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_sensor_mappings_updated_at BEFORE UPDATE ON asset_sensor_mappings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_device_hierarchies_updated_at BEFORE UPDATE ON device_hierarchies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_device_permissions_updated_at BEFORE UPDATE ON device_permissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_device_attributes_updated_at BEFORE UPDATE ON device_attributes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_features_updated_at BEFORE UPDATE ON features FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_rules_updated_at BEFORE UPDATE ON rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_application_permissions_updated_at BEFORE UPDATE ON application_permissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_role_mappings_updated_at BEFORE UPDATE ON user_role_mappings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_login_sessions_updated_at BEFORE UPDATE ON login_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_alarms_updated_at BEFORE UPDATE ON alarms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for active devices with their hierarchies
CREATE VIEW active_devices_with_hierarchy AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.device_sub_type,
    d.is_connected,
    dh.parent_device_id,
    pd.device_name as parent_device_name
FROM devices d
LEFT JOIN device_hierarchies 