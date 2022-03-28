# FlySwatter

A tool to ping urls and report the data to Logflare.

Use cases:
  * Continuously ping a function each minute to generate data for function logs
  * Update data in a Supabase database to constantly generate a Realtime stream to listen to
  * Check the uptime of a project continuously and report to Logflare

Data:
  * Data for pings is being sent to the Logflare [Supabase Staging account](https://logflare.app/sources/16363) as a simple POST request
  * Fly logs are sent [here](https://logflare.app/sources/16662) with the Fly log shipper
  * And the Elixir application logs are being sent to [their own Logflare source](https://logflare.app/sources/19486) via the `LogflareLoggerBackend`

## Usage

Currently pinged endpoints are static. To add an endpoint:
  * Create a stack function in `FlySwatter.Stacks` which returns a `%FlySwatter.Stack{}`
  * Add it to the list of stacks in `FlySwatter.PingerManager.init` 

## Phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
