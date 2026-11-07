# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2442, "latency is the metric for 64 Hz entity state", :discussion do
  flight_level :l1

  feature "a 64 Hz 3D state server is judged by tick-to-send time at a held user count."

  scope "the metric, budget, sweep and pass rule for the entity server on one droplet."

  prose ~S"""
  :: hook
  How many users can one shared vCPU serve at 64 Hz before a tick runs late, and what would show
  it?
  :: intrigue
  A feed server that holds 295,000 readers at a p99 of 117 ms spends about seven and a half ticks
  on its tail. It serves reads, so neither its user count nor its latency says anything about a
  tick.
  :: exit
  The first gate: a load generator holds a fixed user count for 5 minutes and prints server-side
  tick-to-send p50, p95 and p99, and a planted slow handler pushes p99 over budget and fails the
  run.
  :: decision
  The user count is whatever 64 Hz allows. Latency is the metric (operator, 2026-11-07).
  - The tick is fixed at 64 Hz, 15,625,000 ns.
  - The primary figure is server-side tick-to-send time, from packet received to batched datagram
    handed to the kernel, at p50, p95 and p99. The proposed budget is p99 under 4 ms, a quarter of
    a tick.
  - Tick overruns, missed deadlines and steal time from the host's CPU counters are recorded
    beside it, so a hypervisor stall is attributed and not blamed on the code.
  - The rule is pass or fail, not rank. Raise users in a sweep to the knee where p99 crosses the
    budget. A run passes with 0% errors over a 5 minute hold.
  - Only bytes derived from the code are stated, and no network figure is measured.
  - A figure stays labelled derived until a measured one replaces it.
  :: related
  - RFD66606-2443, the server that this metric judges.
  - RFD66606-2402, where the ghost servers actually run. The droplet here is the benchmark host.
  """

  details_title "latency is the metric for 64 Hz entity state"

  prose ~S"""
  :: details The problem
  The only public reference is a read-heavy feed benchmark that reports users held and request
  rate. Neither says whether a 15.625 ms tick completes in time.
  :: details Derived figures
  All of these are arithmetic on the reference cost of 26 microseconds per operation, not
  measurements.
  - Operations per second are 128 times the user count: 64 inbound and 64 batched outbound per
    user.
  - One core at 100% does 38,461 operations per second. At 128 users that is 16,384, about 42.6%
    busy. At 150 users it is 49.9%, the floor with tail headroom. At 300 users it is 99.8%.
  - The 26 microseconds include HTTP parsing and SQLite reads, which the tick path drops.
  :: details Bytes
  - An entity packet is 100 bytes, so inbound is 6,400 bytes per second per user.
  - Twelve entities in view make 1,200 bytes of data and 1,248 bytes with IP and UDP headers,
    under the 1,280 byte IPv6 minimum. Sixteen make 1,600 bytes and fragment, so more datagrams
    split them.
  - Outbound is users times entities times 6,400. At 128 users and 12 entities that is 9,830,400
    bytes per second, about 25.5 TB in 30 days. The droplet's transfer allowance is not verified,
    so egress may bind before the CPU, and the entities in view are the main lever.
  :: details Steal time
  A shared vCPU can lose a few milliseconds to the hypervisor, a large share of a tick. Whether
  the droplet is one shared vCPU is assumed and not verified.
  """
end
