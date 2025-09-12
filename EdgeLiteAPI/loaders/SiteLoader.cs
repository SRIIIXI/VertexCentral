
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class SiteLoader : ModelBase
{
    SiteLoader() : base("Sites")
    {
    }
    
    public void Initialize(DataInterface? dataInterface)
    {
        selfReference = this;
        selfReference.connection = dataInterface;
    }

    public override bool Insert<T>(T item)
    {
        throw new NotImplementedException();
    }

    public override bool Remove<T>(T item)
    {
        throw new NotImplementedException();
    }

    public override bool Update<T>(T item)
    {
        throw new NotImplementedException();
    }

    public override bool GetOneOf<T, V>(T item, V value)
    {
        throw new NotImplementedException();
    }

    public override bool GetAll<T>(T item)
    {
        throw new NotImplementedException();
    }
}