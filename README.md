# Distributed-storage-with-data-processing-segration-by-ML


# Adaptive Query Routing with Distributed Storage

A 6-node distributed system that uses an ML classifier to route database queries to dedicated compute clusters, all reading from a unified high-performance storage pool built on NVMe-oF, ZFS, and LustreFS.

> Built on hands-on experience with NVMe-oF, SPDK, ZFS, PolarFS, and distributed PostgreSQL deployments across bare-metal and KVM environments.

---

## The Problem

Uniform query execution wastes resources. A simple `SELECT` by ID should not compete with a 5-year sales trend analysis doing 10 joins. This project separates light and heavy workloads at the infrastructure level — not the application level.

---

## Architecture

| Server | Role |
|--------|------|
| Server 1 & 2 | NVMe-oF storage targets — expose SSDs over the network fabric |
| Server 3 | ZFS storage pool aggregator — shared to all nodes via LustreFS |
| Server 4 | Heavy query executor — joins, aggregations, analytical workloads |
| Server 5 | Light query executor — lookups, inserts, small updates |
| Server 6 | ML router + Kafka broker — classifies queries, dispatches to right cluster |




<img width="2027" height="1115" alt="Block_diagram_101" src="https://github.com/user-attachments/assets/dd6bd9bd-18dc-4e9e-8250-559d8f185a91" />


---

## How It Works

1. Query arrives at **Server 6**
2. ML model scores it on join depth, scan size, subquery nesting, and operation type
3. Query is pushed to the **heavy** or **light** Kafka topic
4. Executor node pulls from its queue and runs the query against the **shared LustreFS mount**
5. Execution metrics (latency, CPU, I/O) feed back into retraining the classifier

---

## Stack

- **NVMe-oF** — network-attached NVMe with near-local latency
- **ZFS** — checksummed storage pool with RAIDZ, L2ARC, ZIL tuning
- **LustreFS** — parallel distributed filesystem for concurrent multi-node access
- **Apache Kafka** — decoupled query buffering and backpressure handling
- **PostgreSQL** — query execution layer (compatible with PolarDB read/write split) *Might change a bit
- **ML Classifier** — trained on real execution metrics, retrained continuously

---

## Why This Architecture

Most distributed storage projects stop at getting data to persist. This one goes further — separating the **data plane** (NVMe-oF + ZFS + Lustre), **compute plane** (PostgreSQL clusters), and **control plane** (ML + Kafka) so each layer scales and fails independently. The shared storage model avoids the data sync complexity that plagues multi-primary setups.

## AWS free tier 
AlmaLinux OS 8.10.20251028 x86_64
ami-000c0df4918b9eb8c
