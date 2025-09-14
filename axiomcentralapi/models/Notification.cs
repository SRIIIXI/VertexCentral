using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Notification
    {
        [Required]
        [StringLength(64)]
        public string NotificationId { get; set; } = string.Empty;

        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        public ulong UnixTimestamp { get; set; }

        public NotificationType NotificationType { get; set; }

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public bool IsRead { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}