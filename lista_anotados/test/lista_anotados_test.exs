defmodule ListaAnotados.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = ListaAnotados.Registry.start_link
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert ListaAnotados.Registry.lookup(registry, "elixirc") == :error

    ListaAnotados.Registry.create(registry, "elixirc")
    assert {:ok, bucket} = ListaAnotados.Registry.lookup(registry, "elixirc")

    ListaAnotados.Bucket.put(bucket, "juan", 1)
    assert ListaAnotados.Bucket.get(bucket, "juan") == 1
  end
end
