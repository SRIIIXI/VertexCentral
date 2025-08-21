// IoT MongoDB Schema - Flat Structure
// Generated from C header model

// ============================================================================
// DEVICE COLLECTIONS
// ============================================================================

// devices collection
db.devices.createIndex({ "device_id": 1 }, { unique: true });
db.devices.createIndex({ "device_type": 1 });
db.devices.createIndex({ "is_active": 1 });
db.devices.createIndex({ "is_connected": 1 });

const deviceSchema = {
  device_id: String,           // char[65] -> String
  device_name: String,         // char[65] -> String
  description: String,         // char[257] -> String
  serial_no: String,           // char[65] -> String
  hardware_id: String,         // char[65] -> String
  firmware_version: String,    // char[65] -> String
  model: String,               // char[65] -> String
  manufacturer: String,        // char[65] -> String
  device_type: Number,         // device_type_t enum -> Number
  device_sub_type: Number,     // device_sub_type_t enum -> Number
  device_inventory_life_cycle: Number, // device_inventory_life_cycle_t enum -> Number
  is_active: Boolean,          // bool -> Boolean
  is_connected: Boolean,       // bool -> Boolean
  is_configured: Boolean,      // bool -> Boolean
  is_system: Boolean          // bool -> Boolean
};

// assets collection
db.assets.createIndex({ "asset_id": 1 }, { unique: true });
db.assets.createIndex({ "site_id": 1 });
db.assets.createIndex({ "category_id": 1 });
db.assets.createIndex({ "is_active": 1 });

const assetSchema = {
  asset_id: String,            // char[65] -> String
  asset_name: String,          // char[65] -> String
  description: String,         // char[257] -> String
  serial_no: String,           // char[65] -> String
  hardware_id: String,         // char[65] -> String
  firmware_version: String,    // char[65] -> String
  model: String,               // char[65] -> String
  manufacturer: String,        // char[65] -> String
  category_id: String,         // char[65] -> String
  subcategory_id: String,      // char[65] -> String
  site_id: String,             // char[65] -> String
  level_id: String,            // char[65] -> String
  is_active: Boolean,          // bool -> Boolean
  is_system: Boolean          // bool -> Boolean
};

// asset_sensor_mappings collection (flattened from asset_to_sensor_mapping_t)
db.asset_sensor_mappings.createIndex({ "asset_sensor_mapping_id": 1 }, { unique: true });
db.asset_sensor_mappings.createIndex({ "asset_id": 1 });
db.asset_sensor_mappings.createIndex({ "device_id": 1 });

const assetSensorMappingSchema = {
  asset_sensor_mapping_id: String,  // char[65] -> String
  asset_id: String,                 // char[65] -> String
  device_id: String,                // Individual sensor device ID (flattened from array)
  unix_timestamp_created: Number,   // unsigned long long -> Number
  unix_timestamp_updated: Number,   // unsigned long long -> Number
  is_active: Boolean,               // bool -> Boolean
  is_system: Boolean               // bool -> Boolean
};

// device_hierarchies collection
db.device_hierarchies.createIndex({ "device_hierarchy_id": 1 }, { unique: true });
db.device_hierarchies.createIndex({ "parent_device_id": 1 });
db.device_hierarchies.createIndex({ "child_device_id": 1 });

const deviceHierarchySchema = {
  device_hierarchy_id: String,     // char[65] -> String
  device_hierarchy_name: String,   // char[65] -> String
  description: String,             // char[257] -> String
  parent_device_id: String,        // char[65] -> String
  child_device_id: String,         // char[65] -> String
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_updated: Number,  // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// device_permissions collection
db.device_permissions.createIndex({ "device_permission_id": 1 }, { unique: true });
db.device_permissions.createIndex({ "device_id": 1 });
db.device_permissions.createIndex({ "user_id": 1 });

const devicePermissionSchema = {
  device_permission_id: String,    // char[65] -> String
  device_permission_name: String,  // char[65] -> String
  description: String,             // char[257] -> String
  device_id: String,               // char[65] -> String
  user_id: String,                 // char[65] -> String
  permission_type: Number,         // permission_type_t enum -> Number
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_updated: Number,  // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// device_attributes collection
db.device_attributes.createIndex({ "device_attribute_id": 1 }, { unique: true });
db.device_attributes.createIndex({ "device_id": 1 });
db.device_attributes.createIndex({ "attribute_type": 1 });

const deviceAttributeSchema = {
  device_attribute_id: String,     // char[65] -> String
  device_attribute_name: String,   // char[65] -> String
  description: String,             // char[257] -> String
  device_id: String,               // char[65] -> String
  attribute_type: String,          // device_attribute_type_t enum (char) -> String
  value_string: String,            // char[257] -> String
  value_number: Number,            // double -> Number
  value_boolean: Boolean,          // bool -> Boolean
  value_location_latitude: Number, // coordinate_t.latitude -> Number (flattened)
  value_location_longitude: Number, // coordinate_t.longitude -> Number (flattened)
  value_location_altitude: Number, // coordinate_t.altitude -> Number (flattened)
  unit: String,                    // char[33] -> String
  accuracy: Number,                // double -> Number
  precision: Number,               // double -> Number
  range_min: Number,               // double -> Number
  range_max: Number,               // double -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// ============================================================================
// GEOGRAPHIC COLLECTIONS
// ============================================================================

// area_points collection (flattened from area_t)
db.area_points.createIndex({ "area_id": 1 });
db.area_points.createIndex({ "point_index": 1 });

const areaPointSchema = {
  area_id: String,                 // char[65] -> String
  point_index: Number,             // Index in the array -> Number
  latitude: Number,                // coordinate_t.latitude -> Number
  longitude: Number,               // coordinate_t.longitude -> Number
  altitude: Number                 // coordinate_t.altitude -> Number
};

// areas collection (metadata only, points separated)
db.areas.createIndex({ "area_id": 1 }, { unique: true });

const areaSchema = {
  area_id: String,                 // char[65] -> String
  area_name: String,               // char[65] -> String
  description: String,             // char[257] -> String
  area_points_count: Number,       // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// zone_points collection (flattened from zone_t)
db.zone_points.createIndex({ "zone_id": 1 });
db.zone_points.createIndex({ "point_index": 1 });

const zonePointSchema = {
  zone_id: String,                 // char[65] -> String
  point_index: Number,             // Index in the array -> Number
  latitude: Number,                // coordinate_t.latitude -> Number
  longitude: Number,               // coordinate_t.longitude -> Number
  altitude: Number                 // coordinate_t.altitude -> Number
};

// zones collection (metadata only, points separated)
db.zones.createIndex({ "zone_id": 1 }, { unique: true });

const zoneSchema = {
  zone_id: String,                 // char[65] -> String
  zone_name: String,               // char[65] -> String
  description: String,             // char[257] -> String
  zone_points_count: Number,       // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// level_zones collection (flattened from level_t.zones array)
db.level_zones.createIndex({ "level_id": 1 });
db.level_zones.createIndex({ "zone_id": 1 });

const levelZoneSchema = {
  level_id: String,                // char[65] -> String
  zone_id: String                  // char[65] -> String (from zones array)
};

// levels collection
db.levels.createIndex({ "level_id": 1 }, { unique: true });
db.levels.createIndex({ "level_number": 1 });

const levelSchema = {
  level_id: String,                // char[65] -> String
  level_name: String,              // char[65] -> String
  description: String,             // char[257] -> String
  level_number: Number,            // unsigned int -> Number
  bounds_area_id: String,          // Reference to area_t -> String
  zones_count: Number,             // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// site_levels collection (flattened from site_t.levels array)
db.site_levels.createIndex({ "site_id": 1 });
db.site_levels.createIndex({ "level_id": 1 });

const siteLevelSchema = {
  site_id: String,                 // char[65] -> String
  level_id: String                 // char[65] -> String (from levels array)
};

// sites collection
db.sites.createIndex({ "site_id": 1 }, { unique: true });
db.sites.createIndex({ "site_type": 1 });

const siteSchema = {
  site_id: String,                 // char[65] -> String
  site_name: String,               // char[65] -> String
  description: String,             // char[257] -> String
  site_type: String,               // site_type_t enum (char) -> String
  site_level_count: Number,        // unsigned int -> Number
  is_master_site: Boolean,         // bool -> Boolean
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// cluster_sites collection (flattened from cluster_t.sites array)
db.cluster_sites.createIndex({ "cluster_id": 1 });
db.cluster_sites.createIndex({ "site_id": 1 });

const clusterSiteSchema = {
  cluster_id: String,              // char[65] -> String
  site_id: String                  // char[65] -> String (from sites array)
};

// clusters collection
db.clusters.createIndex({ "cluster_id": 1 }, { unique: true });
db.clusters.createIndex({ "enterprise_id": 1 });

const clusterSchema = {
  cluster_id: String,              // char[65] -> String
  cluster_name: String,            // char[65] -> String
  description: String,             // char[257] -> String
  enterprise_id: String,           // char[65] -> String
  cluster_count: Number,           // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// ============================================================================
// APPLICATION COLLECTIONS
// ============================================================================

// features collection
db.features.createIndex({ "feature_id": 1 }, { unique: true });
db.features.createIndex({ "application_id": 1 });

const featureSchema = {
  feature_id: String,              // char[65] -> String
  feature_name: String,            // char[65] -> String
  description: String,             // char[257] -> String
  application_id: String,          // char[65] -> String
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_updated: Number,  // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// application_features collection (flattened from application_t.features array)
db.application_features.createIndex({ "application_id": 1 });
db.application_features.createIndex({ "feature_id": 1 });

const applicationFeatureSchema = {
  application_id: String,          // char[65] -> String
  feature_id: String               // char[65] -> String (from features array)
};

// applications collection
db.applications.createIndex({ "application_id": 1 }, { unique: true });
db.applications.createIndex({ "category_id": 1 });

const applicationSchema = {
  application_id: String,          // char[65] -> String
  application_name: String,        // char[65] -> String
  description: String,             // char[257] -> String
  version: String,                 // char[65] -> String
  vendor: String,                  // char[65] -> String
  category_id: String,             // char[65] -> String
  subcategory_id: String,          // char[65] -> String
  features_count: Number,          // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// rules collection
db.rules.createIndex({ "rule_id": 1 }, { unique: true });
db.rules.createIndex({ "rule_type": 1 });
db.rules.createIndex({ "priority": 1 });

const ruleSchema = {
  rule_id: String,                 // char[65] -> String
  rule_name: String,               // char[65] -> String
  description: String,             // char[257] -> String
  rule_type: String,               // rule_type_t enum (char) -> String
  rule_expression: String,         // char[1025] -> String
  priority: Number,                // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// ============================================================================
// USER & ENTERPRISE COLLECTIONS
// ============================================================================

// users collection
db.users.createIndex({ "user_id": 1 }, { unique: true });
db.users.createIndex({ "enterprise_id": 1 });
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "user_name": 1 });

const userSchema = {
  user_id: String,                 // char[65] -> String
  enterprise_id: String,           // char[65] -> String
  user_name: String,               // char[65] -> String
  email: String,                   // char[256] -> String
  contact_mo: String,              // char[32] -> String
  first_name: String,              // char[65] -> String
  last_name: String,               // char[65] -> String
  password_hash: String,           // char[257] -> String
  password_salt: String,           // char[257] -> String
  unix_timestamp_last_login: Number, // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// enterprises collection
db.enterprises.createIndex({ "enterprise_id": 1 }, { unique: true });

const enterpriseSchema = {
  enterprise_id: String,           // char[65] -> String
  enterprise_name: String,         // char[65] -> String
  description: String,             // char[256] -> String
  contact_mo: String,              // char[32] -> String
  contact_email: String,           // char[257] -> String
  contact_first_name: String,      // char[65] -> String
  contact_last_name: String,       // char[65] -> String
  unix_timestamp_created: Number,  // unsigned long long -> Number
  whitelabel_text: String,         // char[1025] -> String
  address_line1: String,           // char[257] -> String
  address_line2: String,           // char[257] -> String
  address_city: String,            // char[33] -> String
  address_state: String,           // char[33] -> String
  address_country: String,         // char[33] -> String
  address_pin_code: String,        // char[17] -> String
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// application_permissions collection
db.application_permissions.createIndex({ "application_permission_id": 1 }, { unique: true });
db.application_permissions.createIndex({ "application_id": 1 });
db.application_permissions.createIndex({ "user_id": 1 });

const applicationPermissionSchema = {
  application_permission_id: String, // char[65] -> String
  application_id: String,           // char[65] -> String
  user_id: String,                  // char[65] -> String
  permission_type: Number,          // permission_type_t enum -> Number
  unix_timestamp_created: Number,   // unsigned long long -> Number
  unix_timestamp_updated: Number,   // unsigned long long -> Number
  is_active: Boolean,               // bool -> Boolean
  is_system: Boolean               // bool -> Boolean
};

// role_permissions collection (flattened from role_t.permissions array)
db.role_permissions.createIndex({ "role_id": 1 });
db.role_permissions.createIndex({ "application_permission_id": 1 });

const rolePermissionSchema = {
  role_id: String,                  // char[65] -> String
  application_permission_id: String // char[65] -> String (from permissions array)
};

// roles collection
db.roles.createIndex({ "role_id": 1 }, { unique: true });

const roleSchema = {
  role_id: String,                 // char[65] -> String
  role_name: String,               // char[65] -> String
  description: String,             // char[257] -> String
  permissions_count: Number,       // unsigned int -> Number
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_updated: Number,  // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// user_role_mappings collection
db.user_role_mappings.createIndex({ "user_role_mapping_id": 1 }, { unique: true });
db.user_role_mappings.createIndex({ "user_id": 1 });
db.user_role_mappings.createIndex({ "role_id": 1 });

const userRoleMappingSchema = {
  user_role_mapping_id: String,    // char[65] -> String
  user_id: String,                 // char[65] -> String
  role_id: String,                 // char[65] -> String
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_updated: Number,  // unsigned long long -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// login_sessions collection
db.login_sessions.createIndex({ "session_id": 1 }, { unique: true });
db.login_sessions.createIndex({ "user_id": 1 });
db.login_sessions.createIndex({ "unix_timestamp_expires": 1 });

const loginSessionSchema = {
  session_id: String,              // char[65] -> String
  user_id: String,                 // char[65] -> String
  unix_timestamp_created: Number,  // unsigned long long -> Number
  unix_timestamp_expires: Number,  // unsigned long long -> Number
  location_latitude: Number,       // coordinate_t.latitude -> Number (flattened)
  location_longitude: Number,      // coordinate_t.longitude -> Number (flattened)
  location_altitude: Number,       // coordinate_t.altitude -> Number (flattened)
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// ============================================================================
// TELEMETRY & DATA COLLECTIONS
// ============================================================================

// telemetry_data collection
db.telemetry_data.createIndex({ "telemetry_data_id": 1 }, { unique: true });
db.telemetry_data.createIndex({ "device_id": 1 });
db.telemetry_data.createIndex({ "unix_timestamp": 1 });
db.telemetry_data.createIndex({ "data_type": 1 });

const telemetryDataSchema = {
  telemetry_data_id: String,       // char[65] -> String
  device_id: String,               // char[65] -> String
  unix_timestamp: Number,          // unsigned long long -> Number
  data_type: String,               // telemetry_data_type_t enum (char) -> String
  value_string: String,            // char[257] -> String
  value_number: Number,            // double -> Number
  value_boolean: Boolean,          // bool -> Boolean
  value_location_latitude: Number, // coordinate_t.latitude -> Number (flattened)
  value_location_longitude: Number, // coordinate_t.longitude -> Number (flattened)
  value_location_altitude: Number, // coordinate_t.altitude -> Number (flattened)
  unit: String,                    // char[33] -> String
  accuracy: Number,                // double -> Number
  precision: Number,               // double -> Number
  range_min: Number,               // double -> Number
  range_max: Number,               // double -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// alarm_related_telemetry collection (flattened from alarm_t.related_telemetry array)
db.alarm_related_telemetry.createIndex({ "alarm_id": 1 });
db.alarm_related_telemetry.createIndex({ "telemetry_data_id": 1 });

const alarmRelatedTelemetrySchema = {
  alarm_id: String,                // char[65] -> String
  telemetry_data_id: String        // char[65] -> String (from related_telemetry array)
};

// alarms collection
db.alarms.createIndex({ "alarm_id": 1 }, { unique: true });
db.alarms.createIndex({ "device_id": 1 });
db.alarms.createIndex({ "unix_timestamp": 1 });
db.alarms.createIndex({ "alarm_type": 1 });

const alarmSchema = {
  alarm_id: String,                // char[65] -> String
  device_id: String,               // char[65] -> String
  unix_timestamp: Number,          // unsigned long long -> Number
  alarm_type: String,              // alarm_type_t enum (char) -> String
  description: String,             // char[257] -> String
  related_telemetry_count: Number, // unsigned int -> Number
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// notifications collection
db.notifications.createIndex({ "notification_id": 1 }, { unique: true });
db.notifications.createIndex({ "user_id": 1 });
db.notifications.createIndex({ "unix_timestamp": 1 });
db.notifications.createIndex({ "notification_type": 1 });
db.notifications.createIndex({ "is_read": 1 });

const notificationSchema = {
  notification_id: String,         // char[65] -> String
  user_id: String,                 // char[65] -> String
  unix_timestamp: Number,          // unsigned long long -> Number
  notification_type: String,       // notification_type_t enum (char) -> String
  description: String,             // char[257] -> String
  is_read: Boolean,                // bool -> Boolean
  is_active: Boolean,              // bool -> Boolean
  is_system: Boolean              // bool -> Boolean
};

// ============================================================================
// ENUM VALUE MAPPINGS (for reference)
// ============================================================================

const enumMappings = {
  site_type_t: {
    SITE_TYPE_INDOOR: 'I',
    SITE_TYPE_OUTDOOR: 'O'
  },
  alarm_type_t: {
    ALARM_TYPE_CRITICAL: 'C',
    ALARM_TYPE_WARNING: 'W',
    ALARM_TYPE_INFO: 'I'
  },
  notification_type_t: {
    NOTIFICATION_TYPE_ALARM: 'A',
    NOTIFICATION_TYPE_TELEMETRY: 'T',
    NOTIFICATION_TYPE_EVENT: 'E'
  },
  telemetry_data_type_t: {
    TELEMETRY_DATA_TYPE_STRING: 'S',
    TELEMETRY_DATA_TYPE_NUMBER: 'N',
    TELEMETRY_DATA_TYPE_BOOLEAN: 'B',
    TELEMETRY_DATA_TYPE_LOCATION: 'L'
  },
  permission_type_t: {
    PERMISSION_READ: 0,
    PERMISSION_WRITE: 1,
    PERMISSION_EXECUTE: 2,
    PERMISSION_DELETE: 3,
    PERMISSION_ADMIN: 4,
    PERMISSION_CUSTOM: 5
  },
  device_type_t: {
    DEVICE_TYPE_SENSOR: 0,
    DEVICE_TYPE_ACTUATOR: 1,
    DEVICE_TYPE_CONTROLLER: 2,
    DEVICE_TYPE_GATEWAY: 3,
    DEVICE_TYPE_VIRTUAL: 4,
    DEVICE_TYPE_OTHER: 5
  },
  device_sub_type_t: {
    DEVICE_SUB_TYPE_TEMPERATURE_SENSOR: 0,
    DEVICE_SUB_TYPE_HUMIDITY_SENSOR: 1,
    DEVICE_SUB_TYPE_PRESSURE_SENSOR: 2,
    DEVICE_SUB_TYPE_LIGHT_SENSOR: 3,
    DEVICE_SUB_TYPE_MOTION_SENSOR: 4,
    DEVICE_SUB_TYPE_OTHER: 5
  },
  device_inventory_life_cycle_t: {
    DEVICE_LIFE_CYCLE_NEW: 0,
    DEVICE_LIFE_CYCLE_IN_USE: 1,
    DEVICE_LIFE_CYCLE_DECOMMISSIONED: 2,
    DEVICE_LIFE_CYCLE_RETIRED: 3,
    DEVICE_LIFE_CYCLE_OTHER: 4
  },
  device_attribute_type_t: {
    DEVICE_ATTRIBUTE_TYPE_STRING: 'S',
    DEVICE_ATTRIBUTE_TYPE_NUMBER: 'N',
    DEVICE_ATTRIBUTE_TYPE_BOOLEAN: 'B',
    DEVICE_ATTRIBUTE_TYPE_LOCATION: 'L'
  },
  rule_type_t: {
    RULE_TYPE_AUTOMATION: 'A',
    RULE_TYPE_CONDITION: 'C',
    RULE_TYPE_EVENT: 'E'
  }
};