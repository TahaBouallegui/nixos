# Secrets, kept with keys I already had

A config published in the open still needs real secrets in it somewhere —
API keys, service passwords, things that genuinely can't be public. The
usual advice is to keep them out of git entirely, in some separate vault,
behind some separate login. I went a different way: the secrets live
*in* the repo, encrypted, and the only keys that can open them are ones
I already had lying around.

## Encrypted in place, not kept elsewhere

[sops-nix](https://github.com/Mic92/sops-nix) encrypts a YAML file with
[age](https://github.com/FiloSottile/age) and lets NixOS decrypt it
declaratively at activation time. The file sits right in the repo:

```yaml
samba-share-password: ENC[AES256_GCM,data:Woc7Szy...,type:str]
sops:
  age:
    - recipient: age1u2wj4l5rjafnmk9dyaw5adz67yxt9z5lqktfyfe35g2hnwaxqyhqm34r5t
      enc: |
        -----BEGIN AGE ENCRYPTED FILE-----
        ...
```

Perfectly safe to commit, perfectly useless to anyone without the matching
private key. The part I like is where that key comes from: not a new
keypair generated specifically for this purpose, but
[`ssh-to-age`](https://github.com/Mic92/ssh-to-age) deriving an age
identity directly from SSH keys that already exist — my own, and each
machine's own host key.

```sh
nix run nixpkgs#ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# age18gr72wn9rg2nhnj3j073f4y6l82wc9uxgxy36gvnzesdtr46nvzs9c2dcd
```

That public key goes in `.sops.yaml` as a recipient. The machine decrypts
its own secrets at boot using the SSH host key it already had for
completely unrelated reasons — no separate identity to generate, rotate,
or lose track of.

## Trust that matches reality

The nice side effect of deriving keys from SSH identities is that the
*access list* for secrets mirrors something I was already maintaining
anyway: which machines and which personal keys I actually trust. Onboarding
a new machine is three steps — convert its host key, add it as a
recipient, `sops updatekeys` — and it's the exact same three steps whether
it's the first secret or the fiftieth.

Placeholders, not plaintext, flow through the rest of the config:

```nix
sops.templates.credentials.content = ''
  password=${config.sops.placeholder."samba-share-password"}
'';
```

`nix eval` on that template shows the literal string
`<SOPS:...:PLACEHOLDER>` — never a real value, not even transiently. The
actual secret only ever materializes decrypted, at activation, directly
into `/run/secrets/`. It never touches the Nix store, never gets baked into
a build artifact, and never shows up in a `nix derivation show`. The
repository can be entirely public and the secrets inside it stay exactly
as private as the handful of SSH keys that were already guarding everything
else.
