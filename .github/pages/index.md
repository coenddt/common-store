---
title: "common-store documentation"
description: "One JSON schema and one MongoDB-style GQL dialect across MongoDB, MySQL, SQLite and PostgreSQL — a shared Rust core with Node.js and Python hosts."
---

# common-store

**One JSON schema and one GQL dialect across MongoDB / MySQL / SQLite / PostgreSQL — Node.js and Python share a single Rust core.** Define each model once as a pure JSON schema, and let nested relations compile into one native backend query instead of hand-written `$lookup` / `JOIN`. RBAC, computed columns and soft delete are built in, and because the semantics are implemented once, Node and Python behaviour cannot drift.

## One-command start

### Node.js
```bash
npx create-store-app myapp
cd myapp && npm install && npm start      # REST on :3000
```

### Python
```bash
npx create-store-app myapp --lang python
cd myapp && pip install -e . && python impl/bootstrap.py
```

> Requires a local MongoDB (default `mongodb://127.0.0.1:27017`, database name = app name). Protocol skins are selected with `--skins rest,graphql,grpc` (at least one, default `rest`).
> ⚠️ The Python path currently depends on `store-gateway-py`, which is **not yet on PyPI** — see Known gaps.

## Layers

| Layer | Component | Responsibility |
|---|---|---|
| Engine | `rust-store-core` | GQL parsing / permissions / computed columns / command planning / SQL dialects; no IO |
| Bindings | `rust-store-node` / `rust-store-py` / `core-ffi` | Expose the engine to each language |
| Hosts | `nodejs-store` / `storepy` / `go-store` | Drive IO, callback injection, placeholder substitution |
| API skins | `store-api` / `store-graphql` / `store-grpc` / `store-mcp` + `store-gateway` | REST / GraphQL / gRPC / MCP surfaces |
| Control plane | `meta-store` | Definition publish / list / rollback |
| Scaffold | `create-store-app` | One-command data-driven app generation |

## Packages

| Component | Node.js | Python | Rust |
|---|---|---|---|
| Engine | — | — | `rust-store-core` 4.0.0 (crates.io) |
| Bindings | `rust-store-node` 4.0.0 (npm) | `rust-store-py` 4.0.0 (PyPI) | `core-ffi` (in-repo, C ABI) |
| Hosts | `nodejs-store` 4.0.0 (npm) | `storepy` 4.0.0 (PyPI, import `py_store`) | `go-store` (in-repo, Go host v0, SQLite) |
| REST skin | `store-api-node` 0.1.0 | `store-api-py` 0.1.0 | — |
| GraphQL skin | `store-graphql-node` 0.1.0 | `store-graphql-py` 0.1.0 | — |
| gRPC skin | `store-grpc-node` 0.1.0 | `store-grpc-py` 0.1.0 | — |
| MCP skin | `store-mcp-node` 0.1.0 | `store-mcp-py` 0.1.0 | — |
| Gateway | `store-gateway-node` 0.1.0 | `store-gateway-py` **not published** | — |
| Scaffold | `create-store-app` 0.2.0 (npm) | same (`--lang python`) | — |

## Host documentation

- [py-store](https://coenddt.github.io/py-store/) — Python asyncio host (`storepy`)
- [rust-store](https://coenddt.github.io/rust-store/) — shared Rust core
- [nodejs-store](https://github.com/coenddt/nodejs-store) — Node.js host (`nodejs-store`)

## Links

- [Overview](readme.html)
- Machine-readable summary: [llms.txt](llms.txt)
