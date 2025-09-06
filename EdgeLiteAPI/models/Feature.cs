using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    // Application, rules and feature related classes
    public class Feature
    {
        [Required]
        [StringLength(64)]
        public string FeatureId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string FeatureName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string ApplicationId { get; set; } = string.Empty;

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}