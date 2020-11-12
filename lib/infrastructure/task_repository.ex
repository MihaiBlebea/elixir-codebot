defmodule Codebot.Adapter.TaskRepository do
    # https://hexdocs.pm/myxql/readme.html

    @table_name "tasks"

    @db_app :codebot_db

    @spec create_table :: :ok | :fail
    def create_table() do
        MyXQL.query(
            @db_app,
            "CREATE TABLE #{ @table_name } (
                id INT NOT NULL AUTO_INCREMENT,
                title VARCHAR(255) NOT NULL,
                description VARCHAR(255),
                completed INT(1) DEFAULT 0,
                created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id)
            )"
        ) |> handle_result
    end

    @spec destory_table :: :ok | :fail
    def destory_table() do
        MyXQL.query(
            @db_app,
            "DROP TABLE #{ @table_name }"
        ) |> handle_result
    end

    @spec add_task(map) :: :ok | :fail | integer
    def add_task(%{"title" => title, "description" => description}) do
        MyXQL.query(
            @db_app,
            "INSERT INTO #{ @table_name } (title, description) VALUES (?, ?)",
            [title, description]
        ) |> handle_result
    end

    def add_task(%{"title" => title}) do
        add_task(%{"title" => title, "description" => nil})
    end

    @spec find_today_tasks :: :fail | [map]
    def find_today_tasks() do
        MyXQL.query(
            @db_app,
            "SELECT * FROM #{ @table_name } WHERE DATE_FORMAT(created, '%Y-%m-%d') = CURRENT_DATE()"
        ) |> cast
    end

    @spec find_by_id(integer) :: map | :fail
    def find_by_id(id) do
        MyXQL.query(
            @db_app,
            "SELECT * FROM #{ @table_name } WHERE id = ?",
            [id]
        ) |> cast
    end

    @spec complete_task(any) :: :ok | :fail
    def complete_task(task_id) do
        MyXQL.query(
            @db_app,
            "UPDATE #{ @table_name } SET completed = 1 WHERE id = ?",
            [task_id]
        ) |> handle_result
    end

    defp handle_result({:ok, result}) do
        case Map.fetch!(result, :last_insert_id) do
            0 -> :ok
            id -> id
        end
    end

    defp handle_result({:error, _result}) do
        :fail
    end

    defp cast({:ok, %MyXQL.Result{} = result}) do
        %MyXQL.Result{columns: columns, rows: rows} = result
        rows
        |> Enum.map(fn (row)->
            Enum.zip(columns, row) |> Enum.into(%{}) |> cast_completed_boolean
        end)
        |> cast_one?
    end

    defp cast({:error, _result}) do
        :fail
    end

    defp cast_one?(list) when is_list(list) do
        case length(list) do
            1 -> Enum.at(list, 0)
            _ -> list
        end
    end

    defp cast_completed_boolean(task) do
        key = "completed"
        case Map.fetch!(task, key) do
            0 -> Map.put(task, key, false)
            1 -> Map.put(task, key, true)
        end
    end
end
