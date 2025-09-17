using System;
using System.Data;
using System.Data.Common;

public abstract class ModelBase
{
    public DataInterface? connection = null;
    public ModelBase? selfReference = null;
    private String tableName = String.Empty;

    public ModelBase(String tableName)
    {
        this.tableName = tableName;
    }

    public String TableName
    {
        get { return tableName; }
    }
    
    public abstract Boolean Insert<T>(T item);
    public abstract Boolean Remove<T>(T item);
    public abstract Boolean Update<T>(T item);
    public abstract Boolean GetOneOf<T, V>(T item, V value);
    public abstract Boolean GetAll<T>(T item);
}