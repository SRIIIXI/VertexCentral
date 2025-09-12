using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection; 

public class Program
{
    public static void Main(string[] args)
    {
        Microsoft.AspNetCore.Hosting.IWebHostBuilder hostBuilder = Microsoft.AspNetCore.WebHost.CreateDefaultBuilder(args);
        WebHostConfiguration.Configure(hostBuilder);

        Microsoft.AspNetCore.Hosting.IWebHost host = hostBuilder.Build();
        host.Start();
        Console.WriteLine("Web service is running. Press Ctrl+C to shut down.");
        host.WaitForShutdown();
    }
}

public class WebHostConfiguration
{
    public static void Configure(IWebHostBuilder builder)
    {
        builder.Configure(RoutingConfiguration.Configure);
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
        ConfigureGetEndpoints(endpoints);
        ConfigurePutEndpoints(endpoints);
        ConfigurePostEndpoints(endpoints);
        ConfigureDeleteEndpoints(endpoints);
    }

    private static void ConfigureGetEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/", RootHandler.GetRoot);

        endpoints.MapGet("/api/v1/alarm", AlarmHandler.GetAll);
        endpoints.MapGet("/api/v1/alarm/{id}", AlarmHandler.Get);

        endpoints.MapGet("/api/v1/application", ApplicationHandler.GetAll);
        endpoints.MapGet("/api/v1/application/{id}", ApplicationHandler.Get);

        endpoints.MapGet("/api/v1/device", DeviceHandler.GetAll);
        endpoints.MapGet("/api/v1/device/{id}", DeviceHandler.Get);
    }

    private static void ConfigurePutEndpoints(IEndpointRouteBuilder endpoints)
    {

    }

    private static void ConfigurePostEndpoints(IEndpointRouteBuilder endpoints)
    {

    }
    
    private static void ConfigureDeleteEndpoints(IEndpointRouteBuilder endpoints)
    {
            
    }
}

