-- ============================================================================
-- NOTIFICATION LISTENING EXAMPLES FOR APPLICATION DEVELOPERS
-- ============================================================================

/*
To listen for database changes in your application, use PostgreSQL's LISTEN command:

-- Listen to all data changes
LISTEN data_changes;

-- Listen to specific table changes
LISTEN table_devices;
LISTEN table_telemetrycontrol;
LISTEN table_alarms;

-- In your application code (example for Node.js with pg library):
client.on('notification', (msg) => {
    const payload = JSON.parse(msg.payload);
    console.log('Database change:', payload);
    // Handle the change notification
    // payload structure:
    // {
    //   table: 'Devices',
    //   operation: 'INSERT|UPDATE|DELETE',
    //   recordId: 'DEV_123456',
    //   userId: null,
    //   timestamp: 1640995200,
    //   data: { ... additional data ... }
    // }
});
*/

-- ============================================================================
-- PERFORMANCE OPTIMIZATION HINTS (Updated)
-- ============================================================================

-- Consider creating additional partial indexes for frequently queried conditions
-- Example partial indexes for better performance on active/non-deleted records:

-- CREATE INDEX "IdxDevicesActiveConnected" ON "Devices"("DeviceId") WHERE "IsDeleted" = FALSE AND "IsConnected" = TRUE;
-- CREATE INDEX "IdxTelemetryControlActiveFiles" ON "TelemetryControl"("DeviceId", "Year", "Month") WHERE "IsDeleted" = FALSE AND "FileStatus" = 'ACTIVE';
-- CREATE INDEX "IdxAlarmsRecentCritical" ON "Alarms"("DeviceId", "UnixTimestamp" DESC) WHERE "IsDeleted" = FALSE AND "AlarmType" = 'C';

-- For time-series queries on TelemetryControl, consider:
-- CREATE INDEX "IdxTelemetryControlTimeRange" ON "TelemetryControl"("MinTimestamp", "MaxTimestamp") WHERE "IsDeleted" = FALSE;

-- ============================================================================
-- COMMENTS AND DOCUMENTATION (Updated)
-- ============================================================================

COMMENT ON DATABASE "IotPlatform" IS 'IoT Platform Database - Pascal Case Version with Parquet File Management';

COMMENT ON TABLE "Enterprises" IS 'Master table for enterprise/organization management';
COMMENT ON TABLE "Users" IS 'User accounts with enterprise association';
COMMENT ON TABLE "Devices" IS 'IoT devices and sensors registry';
COMMENT ON TABLE "TelemetryControl" IS 'Control table for Parquet telemetry files with metadata and statistics';
COMMENT ON TABLE "Alarms" IS 'Alert and alarm events from devices';
COMMENT ON TABLE "Assets" IS 'Physical assets that devices are attached to';

-- Column comments for critical tables
COMMENT ON COLUMN "TelemetryControl"."FilePath" IS 'Directory path: enterprise/site/device/year/month/hour';
COMMENT ON COLUMN "TelemetryControl"."FileStatus" IS 'ACTIVE=Currently being written, CLOSED=Complete, ARCHIVED=Old data, CORRUPTED=Needs repair';
COMMENT ON COLUMN "Devices"."IsConnected" IS 'Real-time connection status of device';
COMMENT ON COLUMN "Devices"."IsConfigured" IS 'Whether device has been properly configured';
COMMENT ON COLUMN "Alarms"."AlarmType" IS 'C=Critical, W=Warning, I=Info';
COMMENT ON COLUMN "Alarms"."RelatedTelemetryFileIds" IS 'Array of TelemetryControl IDs related to this alarm';

-- ============================================================================
-- NOTES ON CASE SENSITIVITY IN POSTGRESQL (Unchanged)
-- ============================================================================

-- IMPORTANT: PostgreSQL converts all unquoted identifiers to lowercase
-- To preserve PascalCase, ALL identifiers must be quoted with double quotes
-- 
-- Examples:
-- - Table name: "Enterprises" (not Enterprises)
-- - Column name: "EnterpriseId" (not EnterpriseId) 
-- - Index name: "IdxEnterprisesIsDeleted" (not IdxEnterprisesIsDeleted)
-- - Function name: "UpdateUpdatedAtColumn" (not UpdateUpdatedAtColumn)
--
-- When querying, you must also use quotes:
-- SELECT "EnterpriseId", "EnterpriseName" FROM "Enterprises" WHERE "IsDeleted" = FALSE;

-- ============================================================================
-- FUTURE PLACEHOLDER TABLES (For Summary, Insights, Analytics)
-- ============================================================================

-- Placeholder comments for future table implementations:

-- CREATE TABLE "TelemetrySummary" (
--     -- Hourly/Daily/Weekly/Monthly aggregated telemetry data
--     -- Will contain pre-computed statistics from Parquet files
-- );

-- CREATE TABLE "DeviceInsights" (
--     -- Machine learning insights and patterns for devices
--     -- Anomaly detection results, predictive maintenance alerts
-- );

-- CREATE TABLE "AnalyticsReports" (
--     -- Pre-computed analytical reports and dashboards data
--     -- Performance metrics, usage statistics, trends
-- );

-- CREATE TABLE "TelemetryAggregates" (
--     -- Time-series aggregates at different granularities
--     -- Min/Max/Avg/Count values for different time windows
-- );

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
