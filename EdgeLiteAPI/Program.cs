using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection; 


public class RootHandler
{
    public static Task Handle(Microsoft.AspNetCore.Http.HttpContext context)
    {
        string message = "Hello from .NET 9 Web Service!";
        context.Response.ContentType = "text/plain";
        return context.Response.WriteAsync(message);
    }
}

public class RoutingConfiguration
{
    public static void Configure(IApplicationBuilder app)
    {
        app.UseRouting();
        app.UseEndpoints(ConfigureEndpoints);
    }

    private static void ConfigureEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/", RootHandler.Handle);
    }
}

public class WebHostConfiguration
{
    public static void Configure(IWebHostBuilder builder)
    {
        builder.Configure(RoutingConfiguration.Configure);
    }
}

public class Program
{
    public static void Main(string[] args)
    {
        Microsoft.AspNetCore.Hosting.IWebHostBuilder hostBuilder = Microsoft.AspNetCore.WebHost.CreateDefaultBuilder(args);
        WebHostConfiguration.Configure(hostBuilder);

        Microsoft.AspNetCore.Hosting.IWebHost host = hostBuilder.Build();
        host.Run();
    }
}
