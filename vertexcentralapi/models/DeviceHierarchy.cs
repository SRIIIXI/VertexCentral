using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class DeviceHierarchy
    {
        [Required]
        [StringLength(64)]
        public string DeviceHierarchyId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string DeviceHierarchyName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string ParentDeviceId { get; set; } = string.Empty;

        [StringLength(64)]
        public string ChildDeviceId { get; set; } = string.Empty;

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}