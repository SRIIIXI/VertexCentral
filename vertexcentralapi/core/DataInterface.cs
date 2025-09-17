using System;
using System.Data;
using System.Data.Common;
using Npgsql;
using NpgsqlTypes;
using System.Collections.Generic;

public class DataInterface
{
    DbConnection? connection = null;
    private string? connectionString = null;
    List<string>? tableNames = null;

    public DataInterface()
    {
    }

    public DataInterface(String iconnectionString)
    {
        connectionString = iconnectionString;
    }

    public void Dispose()
    {
        CloseConnection();
    }

    ~DataInterface()
    {
        Dispose();
    }

    public String ConnectionString
    {
        get { return connectionString ?? string.Empty; }
        set { connectionString = value; }
    }

    public List<string>? TableNames
    {
        get { return tableNames; }
    }

    public Boolean OpenConnection()
    {
        try
        {
            if (connectionString == null)
            {
                throw new InvalidOperationException("Connection string is not set.");
            }

            if (connection != null && connection.State == ConnectionState.Open)
            {
                return true; // Connection is already open
            }

            connection = new NpgsqlConnection(connectionString);
            connection.Open();
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error opening connection: {ex.Message}");
        }
        return false;
    }

    public Boolean IsConnected()
    {
        return connection != null && connection.State == ConnectionState.Open;
    }

    public Boolean LoadTableNames()
    {
        if (!IsConnected() || connection == null)
        {
            return false;
        }

        try
        {
            tableNames = new List<string>();
            DataTable schema = connection.GetSchema("Tables");
            foreach (DataRow row in schema.Rows)
            {
                string tableName = row["table_name"].ToString() ?? string.Empty;
                tableNames.Add(tableName);
            }
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error loading table names: {ex.Message}");
            return false;
        }
    }

    public void CloseConnection()
    {
        if (connection != null && connection.State != ConnectionState.Closed)
        {
            connection.Close();
            connection = null;
        }
    }

    public Boolean ExecuteDML(String sql)
    {
        if (!IsConnected() || connection == null)
        {
            return false;
        }

        try
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = sql;
                command.ExecuteNonQuery();
            }
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error executing non-query: {ex.Message}");
            return false;
        }
    }

    public Boolean ExecuteSQL(String sql, ref DataTable resultTable, ref String errorMessage)
    {
        if (!IsConnected() || connection == null)
        {
            return false;
        }

        try
        {
            using (DbCommand command = connection.CreateCommand())
            {
                command.CommandText = sql;
                using (DbDataAdapter adapter = new NpgsqlDataAdapter((NpgsqlCommand)command))
                {
                    resultTable = new DataTable();
                    adapter.Fill(resultTable);
                    return true;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error executing query: {ex.Message}");
            errorMessage = ex.Message;
            return false;
        }
    }

    public Boolean GetAllRecords(ref RepositoryBase model, ref DataTable resultTable, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        string sql = $"SELECT * FROM {model.TableName};";
        return ExecuteSQL(sql, ref resultTable, ref errorMessage);
    }

    public Boolean GetFilteredRecords(ref RepositoryBase model, String filterCondition, ref DataTable resultTable, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        string sql = $"SELECT * FROM {model.TableName} WHERE {filterCondition};";
        return ExecuteSQL(sql, ref resultTable, ref errorMessage);
    }

    public Boolean InsertRecord<T>(ref RepositoryBase model, T item, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        return false;
    }
}