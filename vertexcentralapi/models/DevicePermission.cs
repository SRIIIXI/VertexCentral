using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class DevicePermission
    {
        [Required]
        [StringLength(64)]
        public string DevicePermissionId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string DevicePermissionName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string DeviceId { get; set; } = string.Empty;

        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        public PermissionType PermissionType { get; set; }

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}