# My shell is a package

Most people's shell setup is a `.bashrc` or `.config/fish/config.fish`,
accumulated over years, sourced on login, half-remembered. Mine is a Nix
derivation. Not "a shell with a Nix-managed config file" — the shell
*itself*, along with every tool I expect to have on `PATH` the moment I'm
logged in, is one package:

```nix
packages.environment = inputs.wrappers.lib.wrapPackage {
  inherit pkgs;
  package = self'.packages.fish;
  runtimeInputs = [
    # nix tooling
    pkgs.nil pkgs.nixd pkgs.statix pkgs.alejandra pkgs.manix pkgs.nix-inspect pkgs.nh

    # the rest of the toolbelt
    pkgs.fzf pkgs.eza pkgs.fd pkgs.zoxide pkgs.ripgrep pkgs.lazygit
    pkgs.btop pkgs.imagemagick pkgs.ffmpeg-full pkgs.yt-dlp pkgs.wl-clipboard

    # wrapped packages, themed and configured in their own right
    self'.packages.neovim self'.packages.qalc self'.packages.git self'.packages.yazi
  ];
};
```

That's not a list of things I *installed*. It's a list of things that
exist, unconditionally, the instant this one package is built — on any
machine, in any order, every time, because `wrapPackage` builds a fish
binary that has all of this baked into its own `PATH` before it ever reads
a config file.

## One package, every place a shell shows up

The payoff isn't really "convenient tool availability" — plenty of setups
manage that with a package list in `environment.systemPackages`. It's that
this *one derivation* is used everywhere a shell is needed, rather than
each surface area getting its own slightly-different idea of what "my
shell" means:

```nix
# the terminal's default shell
packages.terminal = (inputs.wrappers.wrapperModules.kitty.apply {
  imports = [ self.wrappersModules.kitty ];
  shell = lib.getExe self'.packages.environment;
}).wrapper;
```

```nix
# the actual login shell for the user account
users.users.atb.shell = self.packages.${pkgs.system}.environment;
```

Open a terminal, get this shell. Log into the machine at a TTY, get this
shell. SSH into the server as the account that has it set, get this
shell. There's exactly one definition of "my environment," and every entry
point into a shell resolves to the same build — not three configs that
started identical and will eventually diverge, but one artifact referenced
three times.

## The part that's easy to miss: git's identity lives here too

Tucked into the same wrapping pattern, `git` itself is a wrapped package
with authorship baked in as environment variables on the binary, not a
`~/.gitconfig` entry:

```nix
packages.git = inputs.wrappers.lib.wrapPackage {
  package = pkgs.git;
  env = {
    GIT_AUTHOR_NAME = "Za3ter";
    GIT_AUTHOR_EMAIL = "ahmedtbou@tutamail.com";
  };
};
```

Small detail, same underlying idea: identity and configuration aren't a
dotfile that has to be present and correct on every machine separately —
they're compiled into the tool itself. Move to a new machine, rebuild, the
`git` on `PATH` already knows who's using it. Nothing to sync, because
there was never a second copy to drift out of sync with in the first
place.
