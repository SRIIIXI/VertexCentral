-- ============================================================================
-- COUNTRIES INDEXES
-- ============================================================================
CREATE INDEX "IdxCountriesIsDeleted" ON "Countries"("IsDeleted");
CREATE INDEX "IdxCountriesIsoCode2" ON "Countries"("IsoCode2");
CREATE INDEX "IdxCountriesIsoCode3" ON "Countries"("IsoCode3");
CREATE INDEX "IdxCountriesGeoClusters" ON "Countries" USING gin(string_to_array("GeoClusters", ';'));

-- ============================================================================
-- ENTERPRISES INDEXES
-- ============================================================================
CREATE INDEX "IdxEnterprisesIsDeleted" ON "Enterprises"("IsDeleted");
CREATE INDEX "IdxEnterprisesContactEmail" ON "Enterprises"("ContactEmail");

-- ============================================================================
-- USERS INDEXES
-- ============================================================================
CREATE INDEX "IdxUsersEnterpriseId" ON "Users"("EnterpriseId");
CREATE INDEX "IdxUsersIsDeleted" ON "Users"("IsDeleted");
CREATE INDEX "IdxUsersRoleType" ON "Users"("RoleType");
CREATE INDEX "IdxUsersEnterpriseRole" ON "Users"("EnterpriseId", "RoleType");

-- ============================================================================
-- BOUNDS AREA INDEXES
-- ============================================================================
-- No indexes needed for BoundsArea as it's primarily referenced by FK

-- ============================================================================
-- SITES INDEXES
-- ============================================================================
CREATE INDEX "IdxSitesCountryId" ON "Sites"("CountryId");
CREATE INDEX "IdxSitesSiteType" ON "Sites"("SiteType");
CREATE INDEX "IdxSitesIsDeleted" ON "Sites"("IsDeleted");
CREATE INDEX "IdxSitesMaster" ON "Sites"("IsMasterSite") WHERE "IsMasterSite" = TRUE;

-- ============================================================================
-- LEVELS INDEXES
-- ============================================================================
CREATE INDEX "IdxLevelsSiteId" ON "Levels"("SiteId");
CREATE INDEX "IdxLevelsLevelNumber" ON "Levels"("LevelNumber");
CREATE INDEX "IdxLevelsIsDeleted" ON "Levels"("IsDeleted");
CREATE INDEX "IdxLevelsSiteLevel" ON "Levels"("SiteId", "LevelNumber");

-- ============================================================================
-- ZONES INDEXES
-- ============================================================================
CREATE INDEX "IdxZonesSiteId" ON "Zones"("SiteId");
CREATE INDEX "IdxZonesLevelId" ON "Zones"("LevelId");
CREATE INDEX "IdxZonesIsDeleted" ON "Zones"("IsDeleted");

-- ============================================================================
-- DEVICES INDEXES
-- ============================================================================
CREATE INDEX "IdxDevicesDeviceType" ON "Devices"("DeviceType");
CREATE INDEX "IdxDevicesDeviceSubType" ON "Devices"("DeviceSubType");
CREATE INDEX "IdxDevicesManufacturer" ON "Devices"("Manufacturer");
CREATE INDEX "IdxDevicesManufacturerModel" ON "Devices"("Manufacturer", "Model");
CREATE INDEX "IdxDevicesInventoryLifeCycle" ON "Devices"("InventoryLifeCyle");
CREATE INDEX "IdxDevicesIsDeletedConnected" ON "Devices"("IsDeleted", "IsConnected");
CREATE INDEX "IdxDevicesSerialNo" ON "Devices"("SerialNo") WHERE "SerialNo" IS NOT NULL;
CREATE INDEX "IdxDevicesCurrentFirmware" ON "Devices"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxDevicesFirmwareVersion" ON "Devices"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

-- ============================================================================
-- ASSETS INDEXES
-- ============================================================================
CREATE INDEX "IdxAssetsSiteId" ON "Assets"("SiteId");
CREATE INDEX "IdxAssetsLevelId" ON "Assets"("LevelId");
CREATE INDEX "IdxAssetsCategory" ON "Assets"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxAssetsInventoryLifeCycle" ON "Assets"("InventoryLifeCyle");
CREATE INDEX "IdxAssetsIsDeleted" ON "Assets"("IsDeleted");
CREATE INDEX "IdxAssetsCurrentFirmware" ON "Assets"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxAssetsFirmwareVersion" ON "Assets"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

-- ============================================================================
-- ASSET DEVICE MAPPING INDEXES
-- ============================================================================
CREATE INDEX "IdxAssetDeviceMappingsAssetId" ON "AssetDeviceMappings"("AssetId");
CREATE INDEX "IdxAssetDeviceMappingsDeviceId" ON "AssetDeviceMappings"("DeviceId");
CREATE INDEX "IdxAssetDeviceMappingsIsDeleted" ON "AssetDeviceMappings"("IsDeleted");

-- ============================================================================
-- DEVICE HIERARCHIES INDEXES
-- ============================================================================
CREATE INDEX "IdxDeviceHierarchiesParentId" ON "DeviceHierarchies"("ParentDeviceId");
CREATE INDEX "IdxDeviceHierarchiesChildId" ON "DeviceHierarchies"("ChildDeviceId");
CREATE INDEX "IdxDeviceHierarchiesIsDeleted" ON "DeviceHierarchies"("IsDeleted");

-- ============================================================================
-- DEVICE ATTRIBUTES INDEXES
-- ============================================================================
CREATE INDEX "IdxDeviceAttributesDeviceId" ON "DeviceAttributes"("DeviceId");
CREATE INDEX "IdxDeviceAttributesAttributeType" ON "DeviceAttributes"("AttributeType");
CREATE INDEX "IdxDeviceAttributesIsDeleted" ON "DeviceAttributes"("IsDeleted");
CREATE INDEX "IdxDeviceAttributesDeviceType" ON "DeviceAttributes"("DeviceId", "AttributeType");

-- ============================================================================
-- APPLICATIONS INDEXES
-- ============================================================================
CREATE INDEX "IdxApplicationsCategory" ON "Applications"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxApplicationsVendor" ON "Applications"("Vendor");
CREATE INDEX "IdxApplicationsIsDeleted" ON "Applications"("IsDeleted");
CREATE INDEX "IdxApplicationsPlatform" ON "Applications"("IsPlatform") WHERE "IsPlatform" = TRUE;

-- ============================================================================
-- FEATURES INDEXES
-- ============================================================================
CREATE INDEX "IdxFeaturesApplicationId" ON "Features"("ApplicationId");
CREATE INDEX "IdxFeaturesIsDeleted" ON "Features"("IsDeleted");
CREATE INDEX "IdxFeaturesPlatform" ON "Features"("IsPlatform") WHERE "IsPlatform" = TRUE;

-- ============================================================================
-- RULES INDEXES
-- ============================================================================
CREATE INDEX "IdxRulesRuleType" ON "Rules"("RuleType");
CREATE INDEX "IdxRulesPriority" ON "Rules"("Priority" DESC);
CREATE INDEX "IdxRulesIsDeleted" ON "Rules"("IsDeleted");
CREATE INDEX "IdxRulesTypePriority" ON "Rules"("RuleType", "Priority" DESC);

-- ============================================================================
-- ACTIONS INDEXES
-- ============================================================================
CREATE INDEX "IdxActionsRuleId" ON "Actions"("RuleId");
CREATE INDEX "IdxActionsParentRuleId" ON "Actions"("ParentRuleId");
CREATE INDEX "IdxActionsChildRuleId" ON "Actions"("ChildRuleId");
CREATE INDEX "IdxActionsIsDeleted" ON "Actions"("IsDeleted");

-- ============================================================================
-- ROLE PERMISSIONS INDEXES
-- ============================================================================
CREATE INDEX "IdxRolePermissionsRoleType" ON "RolePermissions"("RoleType");
CREATE INDEX "IdxRolePermissionsApplicationId" ON "RolePermissions"("ApplicationId");
CREATE INDEX "IdxRolePermissionsFeatureId" ON "RolePermissions"("FeatureId");

-- ============================================================================
-- USER ROLE MAPPINGS INDEXES
-- ============================================================================
CREATE INDEX "IdxUserRoleMappingsUserId" ON "UserRoleMappings"("UserId");
CREATE INDEX "IdxUserRoleMappingsRolePermissionId" ON "UserRoleMappings"("RolePermissionId");
CREATE INDEX "IdxUserRoleMappingsIsDeleted" ON "UserRoleMappings"("IsDeleted");

-- ============================================================================
-- SESSION LOGS INDEXES
-- ============================================================================
CREATE INDEX "IdxSessionLogsUserId" ON "SessionLogs"("UserId");
CREATE INDEX "IdxSessionLogsTimestamp" ON "SessionLogs"("TimestampLoggedIn" DESC);
CREATE INDEX "IdxSessionLogsUserTimestamp" ON "SessionLogs"("UserId", "TimestampLoggedIn" DESC);
CREATE INDEX "IdxSessionLogsIsDeleted" ON "SessionLogs"("IsDeleted");

-- ============================================================================
-- ALARMS INDEXES
-- ============================================================================
CREATE INDEX "IdxAlarmsDeviceId" ON "Alarms"("DeviceId");
CREATE INDEX "IdxAlarmsDeviceTimestamp" ON "Alarms"("DeviceId", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsAlarmType" ON "Alarms"("AlarmType");
CREATE INDEX "IdxAlarmsAlarmTypeTimestamp" ON "Alarms"("AlarmType", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsTimestamp" ON "Alarms"("UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsIsDeleted" ON "Alarms"("IsDeleted");

-- ============================================================================
-- ALARM TELEMETRY RELATIONS INDEXES
-- ============================================================================
CREATE INDEX "IdxAlarmTelemetryRelationsAlarmId" ON "AlarmTelemetryRelations"("AlarmId");
CREATE INDEX "IdxAlarmTelemetryRelationsTelemetryId" ON "AlarmTelemetryRelations"("TelemetryDataId");

-- ============================================================================
-- NOTIFICATIONS INDEXES
-- ============================================================================
CREATE INDEX "IdxNotificationsUserId" ON "Notifications"("UserId");
CREATE INDEX "IdxNotificationsUserTimestamp" ON "Notifications"("UserId", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsUserRead" ON "Notifications"("UserId", "IsRead");
CREATE INDEX "IdxNotificationsTypeTimestamp" ON "Notifications"("NotificationType", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsTimestamp" ON "Notifications"("UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsIsDeleted" ON "Notifications"("IsDeleted");

-- ============================================================================
-- TELEMETRY CONTROL INDEXES (Critical for file management)
-- ============================================================================
CREATE INDEX "IdxTelemetryControlDeviceId" ON "TelemetryControl"("DeviceId");
CREATE INDEX "IdxTelemetryControlEnterpriseId" ON "TelemetryControl"("EnterpriseId");
CREATE INDEX "IdxTelemetryControlSiteId" ON "TelemetryControl"("SiteId");
CREATE INDEX "IdxTelemetryControlYearMonth" ON "TelemetryControl"("Year", "Month");
CREATE INDEX "IdxTelemetryControlYearMonthHour" ON "TelemetryControl"("Year", "Month", "Hour");
CREATE INDEX "IdxTelemetryControlFileStatus" ON "TelemetryControl"("FileStatus");
CREATE INDEX "IdxTelemetryControlFilePath" ON "TelemetryControl"("FilePath");
CREATE INDEX "IdxTelemetryControlDeviceTimeRange" ON "TelemetryControl"("DeviceId", "MinTimestamp", "MaxTimestamp");
CREATE INDEX "IdxTelemetryControlIsDeleted" ON "TelemetryControl"("IsDeleted");
CREATE INDEX "IdxTelemetryControlUniqueFile" ON "TelemetryControl"("DeviceId", "Year", "Month", "Hour") WHERE "IsDeleted" = FALSE;
CREATE INDEX "IdxTelemetryControlDeviceYear" ON "TelemetryControl"("DeviceId", "Year", "Month" DESC);

-- ============================================================================
-- FIRMWARE CONTROL INDEXES (Critical for firmware management)
-- ============================================================================
CREATE INDEX "IdxFirmwareControlManufacturer" ON "FirmwareControl"("Manufacturer");
CREATE INDEX "IdxFirmwareControlModel" ON "FirmwareControl"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareControlVersion" ON "FirmwareControl"("Manufacturer", "Model", "Version");
CREATE INDEX "IdxFirmwareControlTargetType" ON "FirmwareControl"("TargetType");
CREATE INDEX "IdxFirmwareControlFileStatus" ON "FirmwareControl"("FileStatus");
CREATE INDEX "IdxFirmwareControlIsDeleted" ON "FirmwareControl"("IsDeleted");
CREATE INDEX "IdxFirmwareControlSecurity" ON "FirmwareControl"("IsSecurityUpdate", "IsCriticalUpdate");
CREATE INDEX "IdxFirmwareControlApproval" ON "FirmwareControl"("FileStatus", "ApprovedAt");
CREATE INDEX "IdxFirmwareControlChecksum" ON "FirmwareControl"("Checksum");
CREATE INDEX "IdxFirmwareControlDeviceTypes" ON "FirmwareControl" USING gin("SupportedDeviceTypes");
CREATE INDEX "IdxFirmwareControlDeviceSubTypes" ON "FirmwareControl" USING gin("SupportedDeviceSubTypes");

-- ============================================================================
-- FIRMWARE DEPLOYMENTS INDEXES
-- ============================================================================
CREATE INDEX "IdxFirmwareDeploymentsFirmwareId" ON "FirmwareDeployments"("FirmwareControlId");
CREATE INDEX "IdxFirmwareDeploymentsTarget" ON "FirmwareDeployments"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareDeploymentsStatus" ON "FirmwareDeployments"("DeploymentStatus");
CREATE INDEX "IdxFirmwareDeploymentsRetry" ON "FirmwareDeployments"("DeploymentStatus", "NextRetryAt") WHERE "DeploymentStatus" = 'F' AND "NextRetryAt" IS NOT NULL;
CREATE INDEX "IdxFirmwareDeploymentsIsDeleted" ON "FirmwareDeployments"("IsDeleted");
CREATE INDEX "IdxFirmwareDeploymentsProgress" ON "FirmwareDeployments"("DeploymentStatus", "DeploymentProgress");
CREATE INDEX "IdxFirmwareDeploymentsInitiatedBy" ON "FirmwareDeployments"("InitiatedBy");
CREATE INDEX "IdxFirmwareDeploymentsStarted" ON "FirmwareDeployments"("DeploymentStarted" DESC);

-- ============================================================================
-- FIRMWARE COMPATIBILITY INDEXES
-- ============================================================================
CREATE INDEX "IdxFirmwareCompatibilityFirmwareId" ON "FirmwareCompatibility"("FirmwareControlId");
CREATE INDEX "IdxFirmwareCompatibilityTarget" ON "FirmwareCompatibility"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareCompatibilityModel" ON "FirmwareCompatibility"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareCompatibilityIsDeleted" ON "FirmwareCompatibility"("IsDeleted");
CREATE INDEX "IdxFirmwareCompatibilityCompatible" ON "FirmwareCompatibility"("IsCompatible") WHERE "IsCompatible" = FALSE;