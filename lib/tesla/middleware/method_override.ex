defmodule Tesla.Middleware.MethodOverride do
  @behaviour Tesla.Middleware

  @moduledoc """
  Middleware that adds X-Http-Method-Override header with original request
  method and sends the request as post.

  Useful when there's an issue with sending non-post request.

  ### Example
  ```
  defmodule MyClient do
    use Tesla

    plug Tesla.Middleware.MethodOverride
  end
  ```

  ### Options
  - `:override` - list of http methods that should be overriden,
  everything except `:get` and `:post` if not specified
  """

  def call(env, next, opts) do
    if overridable?(env, opts) do
      env
      |> override
      |> Tesla.run(next)
    else
      env
      |> Tesla.run(next)
    end
  end

  defp override(env) do
    env
    |> Tesla.Middleware.Headers.call([], %{"X-Http-Method-Override" => "#{env.method}"})
    |> Map.put(:method, :post)
  end

  defp overridable?(env, opts) do
    if opts[:override] do
      env.method in opts[:override]
    else
      not env.method in [:get, :post]
    end
  end
end
