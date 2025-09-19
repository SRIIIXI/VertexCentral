using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    // Device related classes
    public class Device
    {
        [Required]
        [StringLength(64)]
        public string DeviceId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string DeviceName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string SerialNo { get; set; } = string.Empty;

        [StringLength(64)]
        public string HardwareId { get; set; } = string.Empty;

        [StringLength(64)]
        public string FirmwareVersion { get; set; } = string.Empty;

        [StringLength(64)]
        public string Model { get; set; } = string.Empty;

        [StringLength(64)]
        public string Manufacturer { get; set; } = string.Empty;

        public DeviceType DeviceType { get; set; }

        public DeviceSubType DeviceSubType { get; set; }

        public DeviceInventoryLifeCycle DeviceInventoryLifeCycle { get; set; }

        public bool IsActive { get; set; }

        public bool IsConnected { get; set; }

        public bool IsConfigured { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}