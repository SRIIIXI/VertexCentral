using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Rule
    {
        [Required]
        [StringLength(64)]
        public string RuleId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string RuleName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public RuleType RuleType { get; set; }

        [StringLength(1024)]
        public string RuleExpression { get; set; } = string.Empty;

        public uint Priority { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}