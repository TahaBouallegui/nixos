# A private cloud, sized for the people who actually use it

Somewhere between "use the big cloud providers for everything" and
"self-host nothing" there's a smaller option that gets talked about less:
run your own services, but only make them reachable by the handful of
devices and people you'd actually hand a key to. Not a product, not a
public offering — a cloud with a guest list.

That's what the home server is for. [Immich](https://immich.app/) backs up
photos the way Google Photos would, except the photos stay on a disk I
own. [Jellyfin](https://jellyfin.org/) is the media server, [Grocy](https://grocy.info/)
tracks household inventory, [SearXNG](https://docs.searxng.org/) is a
meta-search engine that doesn't log anything because there's no business
model that would want it to.

## Nothing is exposed to the internet, on purpose

None of these services open a port to the outside world. All of them sit
behind [Tailscale](https://tailscale.com/), reachable only from devices
I've personally authorized onto the tailnet:

```nix
networking.firewall.trustedInterfaces = [ "tailscale0" ];
```

```nix
services.jellyfin = {
  enable = true;
  openFirewall = false;  # no WAN exposure -- reachable via tailnet only
};
```

This isn't a weaker version of "real" self-hosting with a reverse proxy
and TLS certs and a domain name — it's a deliberately different shape. A
public-facing service has to defend against the entire internet forever.
A tailnet-only service only has to be correct for a known, small,
authenticated set of devices, and an entire category of attack surface —
the unauthenticated kind — simply doesn't exist. No port scanners find
it. No certificate to renew. No login page to brute-force, because
there's no login page reachable at all without already being on the
tailnet.

## The trade-off, honestly

The obvious cost: nobody outside the tailnet can use any of it, ever,
without first being added to the tailnet. That's a feature here, not a
compromise — these aren't products, they're infrastructure for a specific
small group of people who already trust each other, running on hardware
one of us owns and maintains. The barrier to entry for a new user isn't a
signup form, it's "ask to be added to the tailnet," which is exactly the
right amount of friction for something that's closer to a shared house
than a service.
