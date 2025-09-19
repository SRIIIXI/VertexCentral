using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Application
    {
        [Required]
        [StringLength(64)]
        public string ApplicationId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string ApplicationName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string Version { get; set; } = string.Empty;

        [StringLength(64)]
        public string Vendor { get; set; } = string.Empty;

        [StringLength(64)]
        public string CategoryId { get; set; } = string.Empty;

        [StringLength(64)]
        public string SubcategoryId { get; set; } = string.Empty;

        public Feature[] Features { get; set; } = new Feature[ModelConstants.MaxFeaturesPerApplication];

        public uint FeaturesCount { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}