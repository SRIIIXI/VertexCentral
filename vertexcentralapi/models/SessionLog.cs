using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class SessionLog
    {
        [Required]
        [StringLength(64)]
        public string SessionId { get; set; } = string.Empty;

        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        public ulong TimeLoggedIn { get; set; }

        public ulong TimeLoggedOut { get; set; }

        public Coordinate Location { get; set; } = new Coordinate();

        public bool IpAddress { get; set; }

        public bool IsSystem { get; set; }

        public bool IsActive { get; set; }

        public string UserAgent { get; set; } = string.Empty;
    }
}