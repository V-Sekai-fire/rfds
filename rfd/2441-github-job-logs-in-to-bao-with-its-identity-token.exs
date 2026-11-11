# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2441, "a GitHub job logs in to Bao with its identity token", :discussion do
  feature "a release job reads its secrets from Bao with the identity token GitHub gives it."
  scope "the GitHub Actions endpoint's login to Bao, and what that login may read."

  prose ~S"""
  :: hook
  Can a release job reach its signing secrets with no secret stored in GitHub, and with nothing
  for a person to create or renew?
  :: intrigue
  GitHub gives every job a signed identity token that names its repository, branch and
  environment, and Bao can check that token itself. The Tailscale action can join the job to the
  tailnet with the same kind of token. One problem stays open: how the job passes a listener that
  asks for a client certificate before any login.
  :: exit
  The first gate: a job on the protected branch reads one planted secret, and the same job from a
  fork pull request and from an unprotected branch gets "permission denied".
  :: decision
  The GitHub endpoint logs in to Bao (the secret store) with the identity token GitHub issues to
  each job, through Bao's JWT auth method (operator, 2026-11-01).
  - The endpoint's identity is a role: a fixed binding to one repository, one protected branch or
    named environment, and one workflow. A role holds configuration and no secret, and it does not
    expire, so no person creates or renews a credential (operator, 2026-11-01).
  - A role matches claims exactly, with no globs, as RFD66606-2146 (cert-auth is the fence) does
    for common names.
  - The session token Bao returns lives for minutes and carries one policy.
  - The signing secrets live in Bao, and the release job fetches them at run time. GitHub secrets
    hold no long-lived credential.
  - A fork pull request and an unprotected branch match no role.
  - Bao and its FoundationDB run as one machine on Fly, reached over the tailnet through the
    Tailscale sidecar. Bao unseals with Fly KMS at boot, and the last resort is an offline
    division of the seal key with n=1 (operator, 2026-11-01).
  - Other endpoints keep certificate login. This RFD covers GitHub only (operator, 2026-11-01).
  :: related
  - RFD66606-2146 (cert-auth roles), RFD66606-2195 (Bao on Tailscale) and RFD66606-2406 (the desk
    keeps no stored GitHub credentials) set the rules this RFD builds on.
  """

  details_title "a GitHub job logs in to Bao with its identity token"

  prose ~S"""
  :: details What is not known
  No ruling covers these yet, and each needs a decision before a gate can run.
  - Which conditions bind the tailnet identity. The Tailscale action joins a job to the tailnet
    as an ephemeral node with a tag, and it logs in with GitHub's identity token through workload
    identity federation, so no tailnet key is stored (the action's documentation, validated
    January 2026). Bao listens on the tailnet only, and the tag's access rule reaches Bao's
    port. The documentation page does not say how to limit the federated identity to one
    repository and branch, so that setting is unchecked. Without it, any job of a trusted
    repository gets the tag, and only the Bao role stands between it and the secrets. The new
    node also takes time to reach its peers, and the action's ping option waits up to three
    minutes for them.
  - How a job passes the listener. The listener asks for a client certificate before login, and a
    job has none. One option asks for a certificate without requiring it and leaves the tailnet
    access list as the transport gate. Another gives the endpoint a second listener. Both weaken
    or split the second factor of RFD66606-2195, so the operator rules on it.
  - Where Bao gets GitHub's signing keys: fetched from GitHub, which needs outbound access, or
    held as a static set that someone refreshes when GitHub rotates them.
  - Which claims fix a role. Repository, ref, environment and workflow are the candidates, and a
    reusable workflow may change what the workflow claim holds.

  :: details How the Fly Bao unseals
  Fly KMS holds an app secret key, and OpenBao has no seal type for it. Bao runs with a static
  seal instead. The static seal's 32-byte key is stored wrapped by the Fly KMS key, and the
  entrypoint unwraps it at boot through the machine's local socket, so a restart needs no person
  and no other host. The KMS key belongs to one Fly app, so only a machine of that app can unwrap
  it. If that app or its key is lost, the wrapped key is useless. The last resort is the seal
  key divided with Shamir's scheme into one share (n=1), kept offline where the backup bucket's
  credentials do not reach. A division of n=1 holds the whole key in a format that takes more
  shares later.

  :: details Gates
  Each gate has a control that must fail.
  - A job on the protected branch reads the planted secret. Control: the same job from a fork pull
    request gets "permission denied".
  - A job from the named workflow reads it. Control: a different workflow in the same repository
    gets "permission denied".
  - The Fly machine restarts and Bao reports unsealed with no manual step. Control: a machine in
    another Fly app cannot unwrap the key.
  - A fresh token logs in. Control: an expired token is refused.
  - A job joins the tailnet and reaches Bao's port. Control: a job from a repository outside the
    federated identity cannot join, and a job that has joined still cannot log in without a role.
  - The session token reads one path. Control: a read of a path outside its policy is refused.
  """
end
