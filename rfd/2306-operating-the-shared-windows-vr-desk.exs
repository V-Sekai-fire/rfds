# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2306, "operating the shared windows vr desk", :discussion do
  flight_level :l2
  feature "the rules an agent follows to pilot, build on and switch the shared Windows VR
desk without taking it from the person who is using it"
  scope "the Windows desk with two GPUs, its SteamVR install, OXRSys and XR Pilot, the Steam
Frame headset, and every agent job that runs there"

  prose ~S"""
  :: hook
  An agent reads the shared VR desk's state before it acts and leaves it as found.
  :: intrigue
  On 2026-10-09 the agent learned these rules by breaking them. A build on
  every core, a recorder, two chat clients and a VR game overloaded the VR GPU,
  and the compositor watchdog killed the compositor twice.
  :: exit
  Before you pilot or switch, read the last `Using existing HMD` line of the SteamVR server
  log.
  :: decision
  The desk is shared, so an agent reads its state before it acts and leaves it
  as it found it. It runs in one of two modes, XR Pilot on OXRSys or SteamVR
  streaming to the headset, and reads the mode from the SteamVR server log
  before it pilots or switches. A streaming headset means a person is in VR:
  the agent asks first. One-shot work runs as a named scheduled task with a
  log, at low priority and with a capped job count; services run as logon
  tasks with restart on failure. Each endpoint has its own SSH key on the
  headset (operator, 2026-10-09).
  :: related
  - RFD66606-2294, agent knowledge lives in RFDs; RFD66606-2305, the credit ledger.
  - RFD66606-2303, the XR requirements; RFD66606-2307, recording the pilot's stream.
  """

  details_title "operating the shared windows vr desk"

  prose ~S"""
  :: details What broke on the first day
  A build started
  with a backgrounded SSH command died with no exit file. The desk swapped to
  streaming mode while the agent assumed pilot mode. None of this was written
  down outside an agent's session.

  :: details The two modes
  SteamVR runs one headset driver at a time and must restart to change it.

  - **XR Pilot.** The OpenXR active runtime is the OXRSys runtime manifest
    under the user's local app data; `steamvr.vrsettings` sets
    `forcedDriver` to `oxrsys`; the OXRSys driver folder is listed in the
    OpenVR paths file's `external_drivers`. The tray's Bind OXRSys sets all
    three. The server log names the HMD `oxrsys.OXRSYS-HMD-0`.
  - **Streaming.** The active runtime is SteamVR's own manifest, with no
    forced driver. SteamVR's built-in `vrlink` driver takes the headset when
    the headset app connects; the log names the HMD `vrlink.<serial>`. The
    tray's runtime menu set to SteamVR hands the headset back and keeps the
    OXRSys driver registered; Unbind OXRSys also removes the registration.
  - With the OXRSys driver registered and no streaming headset, SteamVR falls
    back to the OXRSys HMD even without a forced driver.

  After either switch, restart SteamVR by opening `steam://run/250820` from the
  desktop session. Launching the SteamVR startup binary from the SSH session
  does not start it. The OXRSys driver starts the tray's pilot, which binds the
  runtime's announce port, so close that pilot before an agent's pilot runs.

  :: details Before, during and after piloting
  - **Before.** Read the last `Using existing HMD` line of the server log,
    count `unexpected problem` lines since the last start, list the pilots
    running, and read the user's idle time. If SteamVR reported an unexpected
    problem, restart it.
  - **During.** A plan checks placement at each crucial step: the pilot still
    owns the session and the HMD is still the one it started with.
  - **After.** Close the agent's pilot and restore the mode the desk was in.
  - Closing another person's application is the operator's call. Ask.

  :: details Overload, as it showed on 2026-10-09
  The compositor log showed sync timeouts for two hours, then a watchdog kill
  after a 5 s stall. The VR GPU was at 95%: the recorder, the chat client and
  its clip recorder, the window manager and the pilot's decode. It was also
  power capped and thermally slowed. After the operator dropped the chat
  stream to 720p at 30 fps the GPU sat at 34% and the timeouts stopped.

  - The second GPU is the place for batch GPU work, but the inference server
    holds most of its memory. Read free memory before a job claims it.
  - The pilot's own sparklines had no fault thresholds, so they stayed green
    through the overload. A fault colour needs a threshold per line.

  :: details Jobs on a desk without systemd
  - **One-shot.** A named task, `xrwin-<job>`, that writes a fixed log and an
    exit file; read its state with `Get-ScheduledTaskInfo`. Start it at low
    priority (`start /low`, task priority 7) and cap its parallelism: the
    Windows build takes `-Jobs`. Four jobs held the CPU at 50% with VR up.
  - **Service.** A logon task with restart on failure, for work that needs
    the desktop session, such as the MCP server.
  - Never start a job with a backgrounded SSH command; it dies with the
    connection.

  :: details The desk's login shell
  The SSH shell is Nushell. Two habits fail there:

  - `ssh-keygen -N '""'` sets a passphrase of two quote characters. The key
    is accepted by the server and then cannot sign in batch mode. Make keys
    from PowerShell and test with an empty passphrase.
  - Piping an external SSH client into `complete` from an SSH session hangs.
    Run it from a PowerShell script with redirected streams and `ssh -n`.

  UAC is off, so every process is elevated. The OpenXR loader ignores
  `XR_RUNTIME_JSON` in an elevated process, so a runtime test that relies on
  it runs against the desk's active runtime. One D3D11 test fails that way in
  streaming mode.

  :: details Pairing an endpoint with the headset
  The headset's devkit service pairs a key with a POST to `/register` on port
  32000. It accepts only `ssh-rsa` keys; an Ed25519 key returns 403. Give each
  endpoint its own RSA key with a one-word comment naming the endpoint, so one
  can be revoked alone. If the headset's approve hook refuses an endpoint, a
  paired endpoint can append that endpoint's public key to `authorized_keys`.
  A reflash wipes the keys and changes the host key: confirm the new
  fingerprint with the operator before trusting it.
  """
end
