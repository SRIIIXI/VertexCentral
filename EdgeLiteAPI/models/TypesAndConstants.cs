using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    // Constants
    public static class ModelConstants
    {
        public const int MaxLevels = 256;
        public const int MaxZones = 1024;
        public const int MaxPolygonPoints = 4096;
        public const int MaxSensorsPerAsset = 32;
        public const int MaxFeaturesPerApplication = 1024;
        public const int MaxApplicationPermissionPerRole = 1024;
        public const int MaxSites = 256;
        public const int MaxClusters = 256;
    }

    // Enums
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum SiteType : byte
    {
        [Display(Name = "Indoor")]
        Indoor = (byte)'I',
        
        [Display(Name = "Outdoor")]
        Outdoor = (byte)'O'
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum AlarmType : byte
    {
        [Display(Name = "Critical")]
        Critical = (byte)'C',
        
        [Display(Name = "Warning")]
        Warning = (byte)'W',
        
        [Display(Name = "Info")]
        Info = (byte)'I'
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum NotificationType : byte
    {
        [Display(Name = "Alarm")]
        Alarm = (byte)'A',
        
        [Display(Name = "Telemetry")]
        Telemetry = (byte)'T',
        
        [Display(Name = "Event")]
        Event = (byte)'E'
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum TelemetryType : byte
    {
        [Display(Name = "String")]
        String = (byte)'S',
        
        [Display(Name = "Number")]
        Number = (byte)'N',
        
        [Display(Name = "Boolean")]
        Boolean = (byte)'B',
        
        [Display(Name = "Location")]
        Location = (byte)'L'
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum PermissionType
    {
        [Display(Name = "Read")]
        Read = 0,
        
        [Display(Name = "Write")]
        Write = 1,
        
        [Display(Name = "Execute")]
        Execute = 2,
        
        [Display(Name = "Delete")]
        Delete = 3,
        
        [Display(Name = "Admin")]
        Admin = 4,
        
        [Display(Name = "Custom")]
        Custom = 5
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DeviceType
    {
        [Display(Name = "Sensor")]
        Sensor = 0,
        
        [Display(Name = "Actuator")]
        Actuator = 1,
        
        [Display(Name = "Controller")]
        Controller = 2,
        
        [Display(Name = "Gateway")]
        Gateway = 3,
        
        [Display(Name = "Virtual")]
        Virtual = 4,
        
        [Display(Name = "Other")]
        Other = 5
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DeviceSubType
    {
        [Display(Name = "Temperature Sensor")]
        TemperatureSensor = 0,
        
        [Display(Name = "Humidity Sensor")]
        HumiditySensor = 1,
        
        [Display(Name = "Pressure Sensor")]
        PressureSensor = 2,
        
        [Display(Name = "Light Sensor")]
        LightSensor = 3,
        
        [Display(Name = "Motion Sensor")]
        MotionSensor = 4,
        
        [Display(Name = "Other")]
        Other = 5
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DeviceInventoryLifeCycle
    {
        [Display(Name = "New")]
        New = 0,
        
        [Display(Name = "In Use")]
        InUse = 1,
        
        [Display(Name = "Decommissioned")]
        Decommissioned = 2,
        
        [Display(Name = "Retired")]
        Retired = 3,
        
        [Display(Name = "Other")]
        Other = 4
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DeviceAttributeType : byte
    {
        [Display(Name = "String")]
        String = (byte)'S',
        
        [Display(Name = "Number")]
        Number = (byte)'N',
        
        [Display(Name = "Boolean")]
        Boolean = (byte)'B',
        
        [Display(Name = "Location")]
        Location = (byte)'L'
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum RuleType : byte
    {
        [Display(Name = "Automation")]
        Automation = (byte)'A',
        
        [Display(Name = "Condition")]
        Condition = (byte)'C',
        
        [Display(Name = "Event")]
        Event = (byte)'E'
    }
}