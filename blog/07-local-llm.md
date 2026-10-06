# Running the model myself

Using a hosted AI model means trusting someone else's server with
whatever you type into it, trusting their uptime, and trusting that the
model doesn't change out from under you overnight. Running one locally
means none of those are someone else's decision anymore — at the cost of
needing the hardware and the patience to actually make it work.

## The engine, tuned for the hardware that's actually here

Inference runs through [ik_llama.cpp](https://github.com/ikawrakow/ik_llama.cpp),
a performance-focused `llama.cpp` fork, built from source with CPU-variant
kernels baked in rather than relying on a generic prebuilt binary:

```nix
services.llama-cpp.package =
  inputs.ik-llama.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DGGML_CPU_ALL_VARIANTS=ON"
      "-DGGML_BACKEND_DL=ON"
    ];
  });
```

That's the difference between "a model runs" and "a model runs as fast as
this specific CPU can make it run" — the kind of tuning that only makes
sense because the whole build is declarative and reproducible in the first
place. Change the flags, rebuild, compare, keep what's faster — no manual
recompilation ritual to repeat every time.

## A real interface, not a terminal prompt

The model serves an OpenAI-compatible API locally, which means it plugs
straight into a proper chat interface instead of living exclusively in a
curl command or a bare REPL — conversation history, multiple providers
side by side, the same UI quality a hosted product would give you,
pointed at a server that happens to be a laptop.

## Why bother, when the hosted options are good

Partly curiosity, partly the straightforward appeal of a tool that works
the same whether or not there's a connection to anywhere else. Mostly,
though, it's the same instinct behind the rest of this config: understand
the whole stack, own the whole stack, and don't hand a piece of your
workflow to a server you don't control if a laptop you already own can do
the job.
