using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    // Telemetry and data classes
    public class Telemetry
    {
        [Required]
        [StringLength(64)]
        public string TelemetryId { get; set; } = string.Empty;

        [StringLength(64)]
        public string DeviceId { get; set; } = string.Empty;

        public ulong UnixTimestamp { get; set; }

        public TelemetryType DataType { get; set; }

        [StringLength(256)]
        public string ValueString { get; set; } = string.Empty;

        public double ValueNumber { get; set; }

        public bool ValueBoolean { get; set; }

        public Coordinate ValueLocation { get; set; } = new Coordinate();

        [StringLength(32)]
        public string Unit { get; set; } = string.Empty;

        public double Accuracy { get; set; }

        public double Precision { get; set; }

        public double RangeMin { get; set; }

        public double RangeMax { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }

}