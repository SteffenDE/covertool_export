defmodule CovertoolConfig do
  require Record

  Record.defrecord(
    :config,
    Record.extract(:config, from_lib: "covertool/include/covertool.hrl")
  )
end

defmodule Mix.Tasks.Covertool do
  use Mix.Task

  @preferred_cli_env :test
  @recursive true

  require CovertoolConfig

  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [file: :string])
    file = Keyword.fetch!(opts, :file)

    {:ok, srcdir} = :file.get_cwd()

    c =
      CovertoolConfig.config(
        appname: Keyword.fetch!(Mix.Project.config(), :app),
        sources: [srcdir],
        beams: [to_charlist(Mix.Project.compile_path())],
        cover_data: :no_import
      )

    _ = :cover.stop()
    {:ok, pid} = :cover.start()
    :ok = :cover.import(to_charlist(file))

    # Silence analyse import messages emitted by cover
    # see https://github.com/elixir-lang/elixir/blob/7b0d4d6707fd221be6a83379a36ca0f4d63c65a7/lib/mix/lib/mix/tasks/test.coverage.ex#L163
    {:ok, string_io} = StringIO.open("")
    Process.group_leader(pid, string_io)

    :covertool.generate_report(c, :cover.imported_modules())
  end
end
