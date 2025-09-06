
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection; 


public class TelemetryHandler
{
    public static Task Handle(Microsoft.AspNetCore.Http.HttpContext context)
    {
        string message = "Hello from .NET 9 Web Service!";
        context.Response.ContentType = "text/plain";
        return context.Response.WriteAsync(message);
    }
}