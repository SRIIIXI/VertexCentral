
-- ============================================================================
-- CREATE VIEWS FOR COMMON QUERIES (Updated for new schema)
-- ============================================================================

-- View for active devices with their hierarchies
CREATE VIEW "ActiveDevicesWithHierarchy" AS
SELECT 
    d."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."DeviceSubType",
    d."IsConnected",
    dh."ParentDeviceId",
    pd."DeviceName" AS "ParentDeviceName"
FROM "Devices" d
LEFT JOIN "DeviceHierarchies" dh ON d."DeviceId" = dh."ChildDeviceId" AND dh."IsDeleted" = FALSE
LEFT JOIN "Devices" pd ON dh."ParentDeviceId" = pd."DeviceId"
WHERE d."IsDeleted" = FALSE;

-- View for user permissions across devices and applications
CREATE VIEW "UserPermissionsSummary" AS
SELECT 
    u."UserId",
    u."UserName",
    u."Email",
    'DEVICE' AS "PermissionScope",
    dp."DeviceId" AS "ScopeId",
    d."DeviceName" AS "ScopeName",
    dp."PermissionType"
FROM "Users" u
JOIN "DevicePermissions" dp ON u."UserId" = dp."UserId"
JOIN "Devices" d ON dp."DeviceId" = d."DeviceId"
WHERE u."IsDeleted" = FALSE AND dp."IsDeleted" = FALSE AND d."IsDeleted" = FALSE

UNION ALL

SELECT 
    u."UserId",
    u."UserName",
    u."Email",
    'APPLICATION' AS "PermissionScope",
    ap."ApplicationId" AS "ScopeId",
    a."ApplicationName" AS "ScopeName",
    ap."PermissionType"
FROM "Users" u
JOIN "ApplicationPermissions" ap ON u."UserId" = ap."UserId"
JOIN "Applications" a ON ap."ApplicationId" = a."ApplicationId"
WHERE u."IsDeleted" = FALSE AND ap."IsDeleted" = FALSE AND a."IsDeleted" = FALSE;

-- View for enterprise hierarchy (updated without clusters)
CREATE VIEW "EnterpriseHierarchy" AS
SELECT 
    e."EnterpriseId",
    e."EnterpriseName",
    s."SiteId",
    s."SiteName",
    s."SiteType",
    c."CountryId",
    c."CountryName",
    c."GeoClusters",
    l."LevelId",
    l."LevelName",
    l."LevelNumber"
FROM "Enterprises" e
LEFT JOIN "Sites" s ON e."EnterpriseId" = s."EnterpriseId" AND s."IsDeleted" = FALSE
LEFT JOIN "Countries" c ON s."CountryId" = c."CountryId" AND c."IsDeleted" = FALSE
LEFT JOIN "Levels" l ON s."SiteId" = l."SiteId" AND l."IsDeleted" = FALSE
WHERE e."IsDeleted" = FALSE;

-- View for recent alarms with device information
CREATE VIEW "RecentAlarmsWithDevices" AS
SELECT 
    a."AlarmId",
    a."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."Manufacturer",
    a."AlarmType",
    a."Description",
    a."UnixTimestamp",
    a."CreatedAt"
FROM "Alarms" a
JOIN "Devices" d ON a."DeviceId" = d."DeviceId"
WHERE a."IsDeleted" = FALSE AND d."IsDeleted" = FALSE
ORDER BY a."UnixTimestamp" DESC;

-- View for telemetry file summary with device context
CREATE VIEW "TelemetryFileSummaryWithDeviceContext" AS
SELECT 
    tc."TelemetryControlId",
    tc."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."DeviceSubType",
    d."Manufacturer",
    tc."EnterpriseId",
    e."EnterpriseName",
    tc."SiteId",
    s."SiteName",
    tc."Year",
    tc."Month",
    tc."Hour",
    tc."FilePath",
    tc."FileName",
    tc."FileStatus",
    tc."FileSizeBytes",
    tc."RecordCount",
    tc."DataTypes",
    tc."MinTimestamp",
    tc."MaxTimestamp",
    tc."CreatedAt"
FROM "TelemetryControl" tc
JOIN "Devices" d ON tc."DeviceId" = d."DeviceId"
JOIN "Enterprises" e ON tc."EnterpriseId" = e."EnterpriseId"
JOIN "Sites" s ON tc."SiteId" = s."SiteId"
WHERE tc."IsDeleted" = FALSE 
AND d."IsDeleted" = FALSE 
AND e."IsDeleted" = FALSE 
AND s."IsDeleted" = FALSE;

-- View for firmware deployment summary with device/asset context
CREATE VIEW "FirmwareDeploymentSummary" AS
SELECT 
    fd."FirmwareDeploymentId",
    fd."TargetType",
    fd."TargetId",
    CASE 
        WHEN fd."TargetType" = 'DEVICE' THEN d."DeviceName"
        WHEN fd."TargetType" = 'ASSET' THEN a."AssetName"
        ELSE 'Unknown'
    END AS "TargetName",
    CASE 
        WHEN fd."TargetType" = 'DEVICE' THEN d."Manufacturer"
        WHEN fd."TargetType" = 'ASSET' THEN a."Manufacturer"
        ELSE NULL
    END AS "TargetManufacturer",
    CASE 
        WHEN fd."TargetType" = 'DEVICE' THEN d."Model"
        WHEN fd."TargetType" = 'ASSET' THEN a."Model"
        ELSE NULL
    END AS "TargetModel",
    fc."Version" AS "FirmwareVersion",
    fc."IsSecurityUpdate",
    fc."IsCriticalUpdate",
    fd."DeploymentStatus",
    fd."DeploymentProgress",
    fd."DeploymentStarted",
    fd."DeploymentCompleted",
    fd."IsRollback",
    fd."RetryCount",
    u."UserName" AS "InitiatedByUser"
FROM "FirmwareDeployments" fd
JOIN "FirmwareControl" fc ON fd."FirmwareControlId" = fc."FirmwareControlId"
LEFT JOIN "Devices" d ON fd."TargetType" = 'DEVICE' AND fd."TargetId" = d."DeviceId"
LEFT JOIN "Assets" a ON fd."TargetType" = 'ASSET' AND fd."TargetId" = a."AssetId"
LEFT JOIN "Users" u ON fd."InitiatedBy" = u."UserId"
WHERE fd."IsDeleted" = FALSE;

-- View for firmware inventory with compatibility summary
CREATE VIEW "FirmwareInventoryWithCompatibility" AS
SELECT 
    fc."FirmwareControlId",
    fc."Manufacturer",
    fc."Model",
    fc."Version",
    fc."TargetType",
    fc."FileStatus",
    fc."IsSecurityUpdate",
    fc."IsCriticalUpdate",
    fc."ReleaseDate",
    fc."FileSizeBytes",
    COUNT(fcomp."FirmwareCompatibilityId") AS "CompatibilityRecords",
    COUNT(CASE WHEN fcomp."IsCompatible" = TRUE THEN 1 END) AS "CompatibleTargets",
    COUNT(CASE WHEN fcomp."IsCompatible" = FALSE THEN 1 END) AS "IncompatibleTargets",
    fc."ApprovedBy",
    ua."UserName" AS "ApprovedByUser",
    fc."UploadedBy",
    uu."UserName" AS "UploadedByUser"
FROM "FirmwareControl" fc
LEFT JOIN "FirmwareCompatibility" fcomp ON fc."FirmwareControlId" = fcomp."FirmwareControlId" 
    AND fcomp."IsDeleted" = FALSE
LEFT JOIN "Users" ua ON fc."ApprovedBy" = ua."UserId"
LEFT JOIN "Users" uu ON fc."UploadedBy" = uu."UserId"
WHERE fc."IsDeleted" = FALSE
GROUP BY fc."FirmwareControlId", fc."Manufacturer", fc."Model", fc."Version", 
         fc."TargetType", fc."FileStatus", fc."IsSecurityUpdate", fc."IsCriticalUpdate",
         fc."ReleaseDate", fc."FileSizeBytes", fc."ApprovedBy", ua."UserName", 
         fc."UploadedBy", uu."UserName";

-- View for device/asset current firmware status
CREATE VIEW "CurrentFirmwareStatus" AS
SELECT 
    'DEVICE' AS "TargetType",
    d."DeviceId" AS "TargetId",
    d."DeviceName" AS "TargetName",
    d."Manufacturer",
    d."Model",
    d."CurrentFirmwareVersion",
    d."LastFirmwareUpdateAt",
    fc."FirmwareControlId",
    fc."FileStatus" AS "FirmwareFileStatus",
    fc."IsSecurityUpdate",
    fc."IsCriticalUpdate",
    fc."ReleaseDate" AS "FirmwareReleaseDate",
    -- Check if newer firmware is available
    EXISTS(
        SELECT 1 FROM "FirmwareControl" fc_newer
        WHERE fc_newer."Manufacturer" = d."Manufacturer"
        AND fc_newer."Model" = d."Model"
        AND fc_newer."TargetType" = 'DEVICE'
        AND fc_newer."FileStatus" = 'APPROVED'
        AND fc_newer."ReleaseDate" > fc."ReleaseDate"
        AND fc_newer."IsDeleted" = FALSE
    ) AS "HasNewerFirmware"
FROM "Devices" d
LEFT JOIN "FirmwareControl" fc ON d."CurrentFirmwareControlId" = fc."FirmwareControlId"
WHERE d."IsDeleted" = FALSE

UNION ALL

SELECT 
    'ASSET' AS "TargetType",
    a."AssetId" AS "TargetId",
    a."AssetName" AS "TargetName",
    a."Manufacturer",
    a."Model",
    a."CurrentFirmwareVersion",
    a."LastFirmwareUpdateAt",
    fc."FirmwareControlId",
    fc."FileStatus" AS "FirmwareFileStatus",
    fc."IsSecurityUpdate",
    fc."IsCriticalUpdate",
    fc."ReleaseDate" AS "FirmwareReleaseDate",
    -- Check if newer firmware is available
    EXISTS(
        SELECT 1 FROM "FirmwareControl" fc_newer
        WHERE fc_newer."Manufacturer" = a."Manufacturer"
        AND fc_newer."Model" = a."Model"
        AND fc_newer."TargetType" = 'ASSET'
        AND fc_newer."FileStatus" = 'APPROVED'
        AND fc_newer."ReleaseDate" > fc."ReleaseDate"
        AND fc_newer."IsDeleted" = FALSE
    ) AS "HasNewerFirmware"
FROM "Assets" a
LEFT JOIN "FirmwareControl" fc ON a."CurrentFirmwareControlId" = fc."FirmwareControlId"
WHERE a."IsDeleted" = FALSE;
CREATE VIEW "DeviceTelemetryStats" AS
SELECT 
    d."DeviceId",
    d."DeviceName",
    d."DeviceType",
    COUNT(tc."TelemetryControlId") AS "TotalFiles",
    SUM(tc."FileSizeBytes") AS "TotalSizeBytes",
    SUM(tc."RecordCount") AS "TotalRecords",
    MIN(tc."MinTimestamp") AS "EarliestData",
    MAX(tc."MaxTimestamp") AS "LatestData",
    COUNT(CASE WHEN tc."FileStatus" = 'ACTIVE' THEN 1 END) AS "ActiveFiles",
    COUNT(CASE WHEN tc."FileStatus" = 'CLOSED' THEN 1 END) AS "ClosedFiles",
    COUNT(CASE WHEN tc."FileStatus" = 'ARCHIVED' THEN 1 END) AS "ArchivedFiles"
FROM "Devices" d
LEFT JOIN "TelemetryControl" tc ON d."DeviceId" = tc."DeviceId" AND tc."IsDeleted" = FALSE
WHERE d."IsDeleted" = FALSE
GROUP BY d."DeviceId", d."DeviceName", d."DeviceType";

