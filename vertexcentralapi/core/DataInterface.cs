using System;
using System.Data;
using System.Data.Common;
using Npgsql;
using NpgsqlTypes;
using System.Collections.Generic;
using System.Text;

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

    public Boolean GetAllRecords(ref RepositoryBase model, ref String jsonResult, ref String errorMessage)
    {
        Boolean success = false;
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        string sql = $"SELECT json_agg(t) FROM \"{model.TableName}\" t LIMIT {model.PageSize} OFFSET {(model.PageNumber - 1) * model.PageSize};";

        DataTable resultTable = new DataTable();

        success = ExecuteSQL(sql, ref resultTable, ref errorMessage);

        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.Append('[');
        bool isFirstRow = true;

        foreach (DataRow row in resultTable.Rows)
        {
            if (!isFirstRow)
            {
                jsonBuilder.Append(',');
            }

            jsonBuilder.Append(row[0].ToString());
            isFirstRow = false;
        }

        jsonBuilder.Append(']');

        jsonResult = jsonBuilder.ToString();

        return success;
    }

    public Boolean GetFilteredRecords(ref RepositoryBase model, ref String jsonResult, String filterCondition, ref String errorMessage)
    {
        Boolean success = false;
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        string sql = $"SELECT json_agg(t) FROM \"{model.TableName}\" t WHERE {filterCondition} LIMIT {model.PageSize} OFFSET {(model.PageNumber - 1) * model.PageSize};";
        DataTable resultTable = new DataTable();

        success = ExecuteSQL(sql, ref resultTable, ref errorMessage);
        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.Append('[');
        bool isFirstRow = true;

        foreach (DataRow row in resultTable.Rows)
        {
            if (!isFirstRow)
            {
                jsonBuilder.Append(',');
            }

            jsonBuilder.Append(row[0].ToString());
            isFirstRow = false;
        }

        jsonBuilder.Append(']');

        jsonResult = jsonBuilder.ToString();

        return success;
    }

    public Boolean InsertRecord(ref RepositoryBase model, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        if (ExecuteDML(model.GetInsertSQL()))
        {
            return true;
        }   

        errorMessage = "Failed to insert record.";

        return false;
    }

    public Boolean UpdateRecord(ref RepositoryBase model, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        if (ExecuteDML(model.GetUpdateSQL()))
        {
            return true;
        }

        errorMessage = "Failed to update record.";

        return false;
    }
    
    public Boolean DeleteRecord(ref RepositoryBase model, ref String errorMessage)
    {
        if (model == null || string.IsNullOrEmpty(model.TableName))
        {
            errorMessage = "Model or TableName is null.";
            return false;
        }

        string sql = $"DELETE FROM {model.TableName} WHERE id = '{model.Id}';";

        if (ExecuteDML(sql))
        {
            return true;
        }

        errorMessage = "Failed to delete record.";

        return false;
    }
}