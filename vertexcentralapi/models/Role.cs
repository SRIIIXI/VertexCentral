using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Role
    {
        [Required]
        [StringLength(64)]
        public string RoleId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string RoleName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public ApplicationPermission[] Permissions { get; set; } = new ApplicationPermission[ModelConstants.MaxApplicationPermissionPerRole];

        public uint PermissionsCount { get; set; }

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}