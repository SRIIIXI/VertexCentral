
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class SessionLogRepository : RepositoryBase
{
    public SessionLogRepository() : base("SessionLogs")
    {
    }

    public void Initialize(DataInterface? dataInterface)
    {
        selfReference = new SessionLogRepository();
        selfReference.connection = dataInterface;
    }
    public override String GetInsertSQL()
    {
        return "";
    }
    
    public override String GetUpdateSQL()
    {
        return "";
    }
}