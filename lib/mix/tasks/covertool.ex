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

    _ = :cover.start()
    :cover.import(to_charlist(file))
    modules = :cover.imported_modules()
    :cover.modules() |> IO.inspect()
    Mix.shell().info("Imported #{length(modules)} modules!")

    :covertool.generate_report(c, :cover.imported_modules())
  end
end
