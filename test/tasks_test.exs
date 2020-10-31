defmodule TasksTest do
    use ExUnit.Case

    alias Codebot.Adapter.TaskMock, as: Tasks

    setup do
        Tasks.wipe_tasks()
    end

    test "can create a task and list it" do
        Tasks.store_task(%{"title" => "Go and buy a dog"})
        [%{"title" => title} | _] = Tasks.list_tasks()

        assert title == "Go and buy a dog"
    end

    test "can save more then one task and list them" do
        1..100
        |> Enum.map(fn (index)-> Tasks.store_task(%{"title" => "Task nr #{ Integer.to_string(index) }"}) end)
        tasks = Tasks.list_tasks()

        assert length(tasks) == 100
        assert Map.fetch!(Enum.at(tasks, 99), "title") == "Task nr 100"
    end
end
