using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Asset
    {
        [Required]
        [StringLength(64)]
        public string AssetId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string AssetName { get; set; } = string.Empty;

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

        [StringLength(64)]
        public string CategoryId { get; set; } = string.Empty;

        [StringLength(64)]
        public string SubcategoryId { get; set; } = string.Empty;

        [StringLength(64)]
        public string SiteId { get; set; } = string.Empty;

        [StringLength(64)]
        public string LevelId { get; set; } = string.Empty;

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}