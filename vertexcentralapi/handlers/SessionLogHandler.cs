
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class SessionLogHandler : HandlerBase
{
    private static RepositoryBase? repository = null;
    private static DataInterface? dataInterface = null;

    public static void Initialize(RepositoryBase repo, DataInterface datainterface)
    {
        repository = (SessionLogRepository)repo;
        dataInterface = datainterface;
    }

    public static Task GetAll(Microsoft.AspNetCore.Http.HttpContext context)
    {
        string message = "";
        String jsonResult = "{}";
        String errorMessage = "";
        bool success = false;

        if (repository == null || dataInterface == null)
        {
            message = "Handler not initialized properly.";
        }
        else
        {
            success = dataInterface.GetAllRecords(ref repository, ref jsonResult, ref errorMessage);

            if (success)
            {
                message = jsonResult;
            }
            else
            {
                message = $"Error: {errorMessage}";
            }
        } 

        context.Response.ContentType = "application/json";
        return context.Response.WriteAsync(message);
    }

    public static Task Get(Microsoft.AspNetCore.Http.HttpContext context)
    {
        string message = "Hello from .NET 9 Web Service!";
        context.Response.ContentType = "text/plain";

        return context.Response.WriteAsync(message);
    }
}
