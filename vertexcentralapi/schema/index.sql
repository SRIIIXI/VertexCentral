
-- Add firmware version tracking to existing tables
ALTER TABLE "Devices" ADD COLUMN "CurrentFirmwareVersion" VARCHAR(64);
ALTER TABLE "Devices" ADD COLUMN "CurrentFirmwareControlId" VARCHAR(64);
ALTER TABLE "Devices" ADD COLUMN "LastFirmwareUpdateAt" TIMESTAMP WITH TIME ZONE;
ALTER TABLE "Assets" ADD COLUMN "CurrentFirmwareVersion" VARCHAR(64);
ALTER TABLE "Assets" ADD COLUMN "CurrentFirmwareControlId" VARCHAR(64);
ALTER TABLE "Assets" ADD COLUMN "LastFirmwareUpdateAt" TIMESTAMP WITH TIME ZONE;

-- Countries indexes
CREATE INDEX "IdxCountriesIsDeleted" ON "Countries"("IsDeleted");
CREATE INDEX "IdxCountriesIsoCode2" ON "Countries"("IsoCode2");
CREATE INDEX "IdxCountriesIsoCode3" ON "Countries"("IsoCode3");
CREATE INDEX "IdxCountriesGeoClusters" ON "Countries" USING gin(string_to_array("GeoClusters", ';'));

-- User indexes
CREATE INDEX "IdxUsersEnterpriseId" ON "Users"("EnterpriseId");
CREATE INDEX "IdxUsersIsDeleted" ON "Users"("IsDeleted");
CREATE INDEX "IdxUsersEmail" ON "Users"("Email");
CREATE INDEX "IdxUsersCreatedAt" ON "Users"("CreatedAt");

-- Site indexes (updated to remove cluster references)
CREATE INDEX "IdxSitesEnterpriseId" ON "Sites"("EnterpriseId");
CREATE INDEX "IdxSitesCountryId" ON "Sites"("CountryId");
CREATE INDEX "IdxSitesSiteType" ON "Sites"("SiteType");
CREATE INDEX "IdxSitesIsDeleted" ON "Sites"("IsDeleted");

-- Level indexes
CREATE INDEX "IdxLevelsSiteId" ON "Levels"("SiteId");
CREATE INDEX "IdxLevelsLevelNumber" ON "Levels"("LevelNumber");
CREATE INDEX "IdxLevelsIsDeleted" ON "Levels"("IsDeleted");

-- Zone indexes
CREATE INDEX "IdxZonesLevelId" ON "Zones"("LevelId");
CREATE INDEX "IdxZonesIsDeleted" ON "Zones"("IsDeleted");

-- Device indexes
CREATE INDEX "IdxDevicesDeviceType" ON "Devices"("DeviceType");
CREATE INDEX "IdxDevicesDeviceSubType" ON "Devices"("DeviceSubType");
CREATE INDEX "IdxDevicesManufacturer" ON "Devices"("Manufacturer");
CREATE INDEX "IdxDevicesIsDeletedConnected" ON "Devices"("IsDeleted", "IsConnected");
CREATE INDEX "IdxDevicesSerialNo" ON "Devices"("SerialNo");
CREATE INDEX "IdxDevicesCreatedAt" ON "Devices"("CreatedAt");

-- Asset indexes
CREATE INDEX "IdxAssetsSiteId" ON "Assets"("SiteId");
CREATE INDEX "IdxAssetsLevelId" ON "Assets"("LevelId");
CREATE INDEX "IdxAssetsCategory" ON "Assets"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxAssetsIsDeleted" ON "Assets"("IsDeleted");

-- Asset device mapping indexes
CREATE INDEX "IdxAssetDeviceMappingsAssetId" ON "AssetDeviceMappings"("AssetId");
CREATE INDEX "IdxAssetDeviceMappingsIsDeleted" ON "AssetDeviceMappings"("IsDeleted");
CREATE INDEX "IdxAssetDevicesDeviceId" ON "AssetDevices"("DeviceId");

-- Device hierarchy indexes
CREATE INDEX "IdxDeviceHierarchiesParentId" ON "DeviceHierarchies"("ParentDeviceId");
CREATE INDEX "IdxDeviceHierarchiesChildId" ON "DeviceHierarchies"("ChildDeviceId");
CREATE INDEX "IdxDeviceHierarchiesIsDeleted" ON "DeviceHierarchies"("IsDeleted");

-- Device permission indexes
CREATE INDEX "IdxDevicePermissionsDeviceUser" ON "DevicePermissions"("DeviceId", "UserId");
CREATE INDEX "IdxDevicePermissionsUserId" ON "DevicePermissions"("UserId");
CREATE INDEX "IdxDevicePermissionsIsDeleted" ON "DevicePermissions"("IsDeleted");

-- Device attribute indexes
CREATE INDEX "IdxDeviceAttributesDeviceId" ON "DeviceAttributes"("DeviceId");
CREATE INDEX "IdxDeviceAttributesAttributeType" ON "DeviceAttributes"("AttributeType");
CREATE INDEX "IdxDeviceAttributesIsDeleted" ON "DeviceAttributes"("IsDeleted");

-- Telemetry Control indexes (Critical for file management)
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

-- Firmware Control indexes (Critical for firmware management)
CREATE INDEX "IdxFirmwareControlManufacturer" ON "FirmwareControl"("Manufacturer");
CREATE INDEX "IdxFirmwareControlModel" ON "FirmwareControl"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareControlVersion" ON "FirmwareControl"("Manufacturer", "Model", "Version");
CREATE INDEX "IdxFirmwareControlTargetType" ON "FirmwareControl"("TargetType");
CREATE INDEX "IdxFirmwareControlFileStatus" ON "FirmwareControl"("FileStatus");
CREATE INDEX "IdxFirmwareControlIsDeleted" ON "FirmwareControl"("IsDeleted");
CREATE INDEX "IdxFirmwareControlSecurity" ON "FirmwareControl"("IsSecurityUpdate", "IsCriticalUpdate");
CREATE INDEX "IdxFirmwareControlApproval" ON "FirmwareControl"("FileStatus", "ApprovedAt");
CREATE INDEX "IdxFirmwareControlChecksum" ON "FirmwareControl"("Checksum");

-- Firmware Deployments indexes
CREATE INDEX "IdxFirmwareDeploymentsTarget" ON "FirmwareDeployments"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareDeploymentsFirmware" ON "FirmwareDeployments"("FirmwareControlId");
CREATE INDEX "IdxFirmwareDeploymentsStatus" ON "FirmwareDeployments"("DeploymentStatus");
CREATE INDEX "IdxFirmwareDeploymentsRetry" ON "FirmwareDeployments"("DeploymentStatus", "NextRetryAt") WHERE "DeploymentStatus" = 'FAILED' AND "NextRetryAt" IS NOT NULL;
CREATE INDEX "IdxFirmwareDeploymentsIsDeleted" ON "FirmwareDeployments"("IsDeleted");
CREATE INDEX "IdxFirmwareDeploymentsProgress" ON "FirmwareDeployments"("DeploymentStatus", "DeploymentProgress");

-- Firmware Compatibility indexes
CREATE INDEX "IdxFirmwareCompatibilityTarget" ON "FirmwareCompatibility"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareCompatibilityFirmware" ON "FirmwareCompatibility"("FirmwareControlId");
CREATE INDEX "IdxFirmwareCompatibilityModel" ON "FirmwareCompatibility"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareCompatibilityIsDeleted" ON "FirmwareCompatibility"("IsDeleted");

-- Device firmware tracking indexes
CREATE INDEX "IdxDevicesCurrentFirmware" ON "Devices"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxDevicesFirmwareVersion" ON "Devices"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

-- Asset firmware tracking indexes
CREATE INDEX "IdxAssetsCurrentFirmware" ON "Assets"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxAssetsFirmwareVersion" ON "Assets"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

-- Application indexes
CREATE INDEX "IdxApplicationsCategory" ON "Applications"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxApplicationsVendor" ON "Applications"("Vendor");
CREATE INDEX "IdxApplicationsIsDeleted" ON "Applications"("IsDeleted");

-- Feature indexes
CREATE INDEX "IdxFeaturesApplicationId" ON "Features"("ApplicationId");
CREATE INDEX "IdxFeaturesIsDeleted" ON "Features"("IsDeleted");

-- Rule indexes
CREATE INDEX "IdxRulesRuleType" ON "Rules"("RuleType");
CREATE INDEX "IdxRulesPriority" ON "Rules"("Priority");
CREATE INDEX "IdxRulesIsDeleted" ON "Rules"("IsDeleted");

-- Application permission indexes
CREATE INDEX "IdxAppPermissionsAppUser" ON "ApplicationPermissions"("ApplicationId", "UserId");
CREATE INDEX "IdxAppPermissionsUserId" ON "ApplicationPermissions"("UserId");
CREATE INDEX "IdxAppPermissionsIsDeleted" ON "ApplicationPermissions"("IsDeleted");

-- Role indexes
CREATE INDEX "IdxRolesIsDeleted" ON "Roles"("IsDeleted");

-- User role mapping indexes
CREATE INDEX "IdxUserRoleMappingsUserId" ON "UserRoleMappings"("UserId");
CREATE INDEX "IdxUserRoleMappingsRoleId" ON "UserRoleMappings"("RoleId");
CREATE INDEX "IdxUserRoleMappingsIsDeleted" ON "UserRoleMappings"("IsDeleted");

-- Session logs indexes
CREATE INDEX "IdxSessionLogsUserId" ON "SessionLogs"("UserId");
CREATE INDEX "IdxSessionLogsExpires" ON "SessionLogs"("TimestampCreatedAt");
CREATE INDEX "IdxSessionLogsIsDeleted" ON "SessionLogs"("IsDeleted");

-- Alarm indexes
CREATE INDEX "IdxAlarmsDeviceTimestamp" ON "Alarms"("DeviceId", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsAlarmTypeTimestamp" ON "Alarms"("AlarmType", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsTimestamp" ON "Alarms"("UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsIsDeleted" ON "Alarms"("IsDeleted");

-- Notification indexes
CREATE INDEX "IdxNotificationsUserTimestamp" ON "Notifications"("UserId", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsUserRead" ON "Notifications"("UserId", "IsRead");
CREATE INDEX "IdxNotificationsTypeTimestamp" ON "Notifications"("NotificationType", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsIsDeleted" ON "Notifications"("IsDeleted");

